extends CatalogWindow
## Popup de escolha de espécie: grade de sprites + busca. Ao escolher, mostra
## (se houver) a escolha de forma e depois nível, natureza e habilidade.
##
## Quando a grade está visível, o botão "Cancelar" do footer fecha a janela.
## Quando estamos configurando um Pokémon (forma/nível/etc.), o mesmo botão
## vira "Voltar" e retorna para a grade sem fechar a janela.

signal pokemon_chosen(species_id: String, form_name: String, level: int,
		nature: int, ability: String)

const ICON_SIZE := Vector2(64, 64)
const SPRITE_DIR := "res://assets/pc_sprites/"

var _selected_species: PokemonSpecies = null
var _selected_form := ""
var _config_box: VBoxContainer
var _level_spin: SpinBox
var _nature_option: OptionButton
var _ability_option: OptionButton

## Texto original do botão Cancelar, guardado para restaurar depois.
var _cancel_text_backup := ""
## Se verdadeiro, o cancel_button está conectado a _on_back_pressed.
var _cancel_is_back := false

func _search_placeholder() -> String:
	return "Nome do Pokémon..."

## 7 colunas para caber mais Pokémon por linha (sobrescreve o padrão de 5).
func _grid_columns() -> int:
	return 7

# ---------- Construção ----------

func _build_list() -> void:
	var all_species = PokemonDB.get_all_species()
	if all_species.is_empty():
		return
	all_species.sort_custom(func(a, b): return a.dex_number < b.dex_number)

	var grid := _new_grid("Grid_Pokemons")
	for species in all_species:
		grid.add_child(_make_pokemon_slot(species))
		await _pace()

func _make_pokemon_slot(species: PokemonSpecies) -> Button:
	var btn := _new_slot(species.id, species.display_name, {"species": species})
	var overlay := _new_overlay(btn, 4, 4, 2)

	# Sprite no topo
	var tex = PokemonDB.get_sprite(species.id)
	if tex == null and ResourceLoader.exists(SPRITE_DIR + species.id + ".png"):
		tex = load(SPRITE_DIR + species.id + ".png")
	var texture_rect := TextureRect.new()
	texture_rect.texture = tex
	texture_rect.custom_minimum_size = ICON_SIZE
	texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	overlay.add_child(_ignore_mouse(texture_rect))

	# Nome ocupa o espaço restante, abaixo do sprite
	var name_label := Label.new()
	name_label.text = species.display_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.add_theme_font_size_override("font_size", 11)
	name_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	overlay.add_child(_ignore_mouse(name_label))
	return btn

# ---------- Seleção ----------

func _clear_selection() -> void:
	super()
	_selected_species = null
	_selected_form = ""
	add_button.text = "Adicionar"
	_restore_cancel_button()
	if _config_box:
		_config_box.queue_free()
		_config_box = null

func _on_slot_pressed(id: String) -> void:
	super(id)
	_selected_species = _entries.filter(func(e: Dictionary) -> bool: return e["id"] == id)[0]["species"]
	_selected_form = ""
	if _selected_species.is_variant and not _selected_species.variant_data.is_empty():
		_ask_variant(_selected_species)
	else:
		_ask_config(_selected_species)

## Troca a grade por um painel de escolha, ainda dentro do mesmo Window.
func _new_config_box(title: String) -> void:
	if _config_box:
		_config_box.queue_free()
	list.hide()
	_config_box = VBoxContainer.new()
	var vbox: VBoxContainer = $Panel/Margin/VBox
	vbox.add_child(_config_box)
	vbox.move_child(_config_box, 2)
	var label := Label.new()
	label.text = title
	_config_box.add_child(label)

func _add_config_row(parent: Control, label_text: String, control: Control,
		label_min_width: int = 90) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 6)

	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = label_min_width
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(label)

	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(control)

	parent.add_child(row)
	return row

func _ask_variant(species: PokemonSpecies) -> void:
	add_button.disabled = true
	_turn_cancel_into_back()
	_new_config_box("Escolha a forma de %s:" % species.display_name)
	for form_name in species.variant_data:
		var btn := Button.new()
		btn.text = form_name
		btn.pressed.connect(_on_variant_chosen.bind(form_name))
		_config_box.add_child(btn)

func _on_variant_chosen(form_name: String) -> void:
	_selected_form = form_name
	_ask_config(_selected_species)

func _ask_config(species: PokemonSpecies) -> void:
	var form_data := species.get_form_data(_selected_form)
	_new_config_box("Configurar %s:" % form_data.get("display_name", species.display_name))
	_turn_cancel_into_back()

	# Linha única horizontal: Nível | Natureza | Habilidade
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 16)
	_config_box.add_child(row)

	# --- Nível ---
	_level_spin = SpinBox.new()
	_level_spin.min_value = maxi(1, int(form_data.get("min_level", species.min_level)))
	_level_spin.max_value = 20
	_level_spin.value = _level_spin.min_value
	_level_spin.custom_minimum_size.x = 80
	_add_config_row(row, "Nível:", _level_spin, 60)

	# --- Natureza ---
	_nature_option = OptionButton.new()
	for n in Constants.Nature.values():
		_nature_option.add_item(Natures.get_display_name(n), n)
	_nature_option.select(0)
	_nature_option.custom_minimum_size.x = 180
	_add_config_row(row, "Natureza:", _nature_option, 70)

	# --- Habilidade (inclui oculta) ---
	_ability_option = OptionButton.new()
	var abilities: Array = form_data.get("abilities", [])
	var hidden_ab: String = String(form_data.get("hidden_ability", ""))
	if abilities.is_empty() and hidden_ab.is_empty():
		_ability_option.add_item("(sem habilidade registrada)", 0)
		_ability_option.disabled = true
	else:
		for ab in abilities:
			_ability_option.add_item(String(ab))
		if not hidden_ab.is_empty():
			_ability_option.add_item("%s (Oculta)" % hidden_ab)
	_ability_option.custom_minimum_size.x = 220
	_add_config_row(row, "Habilidade:", _ability_option, 80)

	add_button.disabled = false

# ---------- Botão Cancelar / Voltar ----------

## Faz o botão Cancelar do footer virar "Voltar" para a grade.
func _turn_cancel_into_back() -> void:
	if _cancel_text_backup.is_empty():
		_cancel_text_backup = cancel_button.text
	if not _cancel_is_back:
		if cancel_button.pressed.is_connected(hide):
			cancel_button.pressed.disconnect(hide)
		cancel_button.pressed.connect(_on_back_pressed)
		_cancel_is_back = true
	cancel_button.text = "Voltar"

func _restore_cancel_button() -> void:
	if _cancel_is_back:
		if cancel_button.pressed.is_connected(_on_back_pressed):
			cancel_button.pressed.disconnect(_on_back_pressed)
		if not cancel_button.pressed.is_connected(hide):
			cancel_button.pressed.connect(hide)
		_cancel_is_back = false
	cancel_button.text = _cancel_text_backup if not _cancel_text_backup.is_empty() else "Cancelar"
	_cancel_text_backup = ""

## Volta para a grade de seleção sem fechar a janela.
func _on_back_pressed() -> void:
	_clear_selection()
	list.show()
	_apply_filter(_search_edit.text)

# ---------- Confirmar ----------

func _on_add_pressed() -> void:
	if _selected_species == null:
		return
	var ability := ""
	if _ability_option and not _ability_option.disabled:
		ability = _ability_option.get_item_text(_ability_option.selected)
	pokemon_chosen.emit(
		_selected_species.id,
		_selected_form,
		int(_level_spin.value),
		_nature_option.get_selected_id(),
		ability,
	)
	hide()
