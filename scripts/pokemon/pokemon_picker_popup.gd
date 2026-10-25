extends CatalogWindow

signal pokemon_chosen(species_id: String, form_name: String, level: int,
		nature: int, ability: String, known_moves: Array[String],
		evs: Dictionary, capture_level: int)

const ICON_SIZE := Vector2(64, 64)
const SPRITE_DIR := "res://assets/pc_sprites/"
const SLOT_SELECTOR_SCENE := preload("res://scenes/pokemon/move_slot_selector.tscn")

var _selected_species: PokemonSpecies = null
var _selected_form := ""
var _config_box: VBoxContainer
var _level_spin: SpinBox
var _nature_option: OptionButton
var _ability_option: OptionButton

var _chosen_moves: Array[String] = []
var _temp_pkmn: PokemonInstance
var _slots_ui: Array[MoveSlotSelector] = []

var _move_select_box: VBoxContainer
var _active_slot_index: int = -1
var _search_move_edit: LineEdit
var _all_move_buttons: Array[Button] = []

# Referências diretas aos labels de EV (ficam aninhados em Panel/VBox/HBox,
# então get_node_or_null("Val_0") a partir do grid NÃO os encontra).
var _ev_counter_label: Label = null
var _ev_hint_label: Label = null
var _capture_spin: SpinBox = null
var _ev_val_labels: Dictionary = {}   # Constants.Attribute -> Label
var _ev_name_labels: Dictionary = {}  # Constants.Attribute -> Label

var _cancel_text_backup := ""
var _cancel_is_back := false

func _search_placeholder() -> String: return "Nome do Pokémon..."
func _grid_columns() -> int: return 7

func _build_list() -> void:
	var all_species = PokemonDB.get_all_species()
	if all_species.is_empty(): return
	all_species.sort_custom(func(a, b): return a.dex_number < b.dex_number)
	var grid := _new_grid("Grid_Pokemons")
	for species in all_species:
		grid.add_child(_make_pokemon_slot(species))
		await _pace()

func _make_pokemon_slot(species: PokemonSpecies) -> Button:
	var btn := _new_slot(species.id, species.display_name, {"species": species})
	var overlay := _new_overlay(btn, 4, 4, 2)
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

	var name_label := Label.new()
	name_label.text = species.display_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.add_theme_font_size_override("font_size", 11)
	name_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	overlay.add_child(_ignore_mouse(name_label))
	return btn

# ---------- Controle de Telas ----------

func _clear_selection() -> void:
	super()
	_selected_species = null
	_selected_form = ""
	_chosen_moves.clear()
	add_button.text = "Adicionar"
	_restore_cancel_button()
	_ev_counter_label = null
	_ev_hint_label = null
	_capture_spin = null
	_ev_val_labels.clear()
	_ev_name_labels.clear()
	if _config_box: _config_box.queue_free(); _config_box = null
	if _move_select_box: _move_select_box.queue_free(); _move_select_box = null
	list.show()

func _on_slot_pressed(id: String) -> void:
	super(id)
	_selected_species = _entries.filter(func(e: Dictionary) -> bool: return e["id"] == id)[0]["species"]
	_selected_form = ""
	_chosen_moves.clear()
	
	if _selected_species.is_variant and not _selected_species.variant_data.is_empty():
		_ask_variant(_selected_species)
	else:
		_ask_config(_selected_species)

## --- AQUI ESTÁ A CORREÇÃO DO SCROLL ---
func _new_config_box(title: String) -> void:
	if _config_box: _config_box.queue_free()
	if _move_select_box: _move_select_box.queue_free(); _move_select_box = null
	list.hide()
	
	# Pega o ScrollContainer original da cena (que envolve a lista)
	var scroll: ScrollContainer = $Panel/Margin/VBox/Scroll
	
	# Garante que a lista de pokémons está escondida lá dentro
	list.hide()
	
	# Cria a _config_box DENTRO do scroll
	_config_box = VBoxContainer.new()
	_config_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_config_box)
	
	var label := Label.new()
	label.text = title
	_config_box.add_child(label)

func _add_config_row(parent: Control, label_text: String, control: Control, label_min_width: int = 90) -> HBoxContainer:
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

	# O Pokémon começa no nível mínimo da forma. Esse também é o nível de captura
	# padrão: ele não "recebeu" os EVs dos níveis pares anteriores a ele.
	var min_lvl := maxi(1, int(form_data.get("min_level", species.min_level)))
	_temp_pkmn = PokemonInstance.new()
	_temp_pkmn.setup(_selected_species.id, _selected_form, min_lvl)
	_temp_pkmn.capture_level = min_lvl

	var row1 := HBoxContainer.new()
	row1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row1.add_theme_constant_override("separation", 16)
	_config_box.add_child(row1)

	_level_spin = SpinBox.new()
	_level_spin.min_value = min_lvl
	_level_spin.max_value = 20
	_level_spin.value = _temp_pkmn.level
	_level_spin.custom_minimum_size.x = 60
	_level_spin.value_changed.connect(_on_level_changed)
	_add_config_row(row1, "Nível:", _level_spin, 50)

	_nature_option = OptionButton.new()
	_nature_option.add_item("Sem Natureza (Neutro)", -1)
	for n in Constants.Nature.values():
		var nature_name = Natures.get_display_name(n)
		var plus_attr = Natures.get_plus(n)
		var minus_attr = Natures.get_minus(n)
		var text = nature_name
		if plus_attr != -1 and minus_attr != -1:
			text += " (+%s / -%s)" % [Regions.ATTR_LABELS[plus_attr], Regions.ATTR_LABELS[minus_attr]]
		elif plus_attr == -1 and minus_attr != -1:
			text += " (+CA / -%s)" % Regions.ATTR_LABELS[minus_attr]
		_nature_option.add_item(text, n)
	_nature_option.select(0)
	_nature_option.custom_minimum_size.x = 220
	_nature_option.item_selected.connect(_on_nature_changed)
	_add_config_row(row1, "Natureza:", _nature_option, 70)

	var row2 := HBoxContainer.new()
	row2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row2.add_theme_constant_override("separation", 16)
	_config_box.add_child(row2)

	_ability_option = OptionButton.new()
	var abilities: Array = form_data.get("abilities", [])
	var hidden_ab: String = String(form_data.get("hidden_ability", ""))
	if abilities.is_empty() and hidden_ab.is_empty():
		_ability_option.add_item("(sem habilidade)", 0)
		_ability_option.disabled = true
	else:
		for ab in abilities: _ability_option.add_item(String(ab))
		if not hidden_ab.is_empty(): _ability_option.add_item("%s (Oculta)" % hidden_ab)
	_ability_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_add_config_row(row2, "Habilidade:", _ability_option, 70)

	var row3 := HBoxContainer.new()
	row3.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row3.add_theme_constant_override("separation", 16)
	_config_box.add_child(row3)

	_capture_spin = SpinBox.new()
	_capture_spin.min_value = min_lvl  # não pode ser capturado abaixo do nível mínimo da forma
	_capture_spin.max_value = _temp_pkmn.level
	_capture_spin.value = min_lvl
	_capture_spin.custom_minimum_size.x = 60
	_capture_spin.tooltip_text = "Nível em que o Pokémon foi capturado.\nPadrão = nível mínimo da forma. Capturas em nível mais alto redistribuem os EVs perdidos."
	_capture_spin.value_changed.connect(_on_capture_level_changed)
	_add_config_row(row3, "Capturado no nível:", _capture_spin, 130)

	_build_ev_ui()

	var lbl_moves := Label.new()
	lbl_moves.text = "Moves Iniciais:"
	lbl_moves.add_theme_font_size_override("font_size", 14)
	_config_box.add_child(lbl_moves)
	
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_config_box.add_child(grid)
	
	_slots_ui.clear()
	var starting = form_data.get("starting_moves", [])
	for i in range(4):
		var slot_ui = SLOT_SELECTOR_SCENE.instantiate()
		slot_ui.custom_minimum_size = Vector2(180, 50)
		slot_ui.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		grid.add_child(slot_ui)
		slot_ui.pressed.connect(_on_move_slot_clicked.bind(i))
		_slots_ui.append(slot_ui)
		
		if i < starting.size():
			var move = PokemonDB.get_move(starting[i])
			if move:
				_chosen_moves.append(move.id)
				slot_ui.setup_with_move(move)
		else:
			slot_ui.setup_empty()

	add_button.disabled = false
	_update_ev_display() # trava o botão se sobrarem pontos de EV

func _build_ev_ui() -> void:
	_config_box.add_child(HSeparator.new())
	_ev_val_labels.clear()
	_ev_name_labels.clear()
	
	var ev_header := HBoxContainer.new()
	ev_header.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var ev_counter := Label.new()
	ev_counter.name = "EVCounter"
	_ev_counter_label = ev_counter
	ev_counter.add_theme_font_size_override("font_size", 16)
	ev_counter.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	ev_header.add_child(ev_counter)
	
	_config_box.add_child(ev_header)

	_ev_hint_label = Label.new()
	_ev_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_ev_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ev_hint_label.add_theme_font_size_override("font_size", 11)
	_ev_hint_label.modulate = Color(1, 1, 1, 0.7)
	_ev_hint_label.visible = false
	_config_box.add_child(_ev_hint_label)

	var ev_grid := GridContainer.new()
	ev_grid.name = "EVGrid"
	ev_grid.columns = 2
	ev_grid.add_theme_constant_override("h_separation", 16)
	ev_grid.add_theme_constant_override("v_separation", 8)
	_config_box.add_child(ev_grid)

	var attr_names := {
		Constants.Attribute.STR: "FORÇA",
		Constants.Attribute.DEX: "DESTREZA",
		Constants.Attribute.CON: "CONSTITUIÇÃO",
		Constants.Attribute.INT: "INTELIGÊNCIA",
		Constants.Attribute.WIS: "SABEDORIA",
		Constants.Attribute.CHA: "CARISMA"
	}

	for attr in Constants.Attribute.values():
		var panel := PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.12, 0.12, 0.12) 
		style.border_color = Color(0.3, 0.3, 0.3)
		style.set_border_width_all(1)
		style.set_corner_radius_all(8)
		style.content_margin_left = 10
		style.content_margin_right = 10
		style.content_margin_top = 5
		style.content_margin_bottom = 5
		panel.add_theme_stylebox_override("panel", style)
		
		var vbox := VBoxContainer.new()
		panel.add_child(vbox)
		
		var center_row := HBoxContainer.new()
		center_row.alignment = BoxContainer.ALIGNMENT_CENTER
		
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color(0.2, 0.2, 0.2)
		btn_style.set_corner_radius_all(4)
		btn_style.content_margin_left = 4
		btn_style.content_margin_right = 4
		btn_style.content_margin_top = 2
		btn_style.content_margin_bottom = 2
		
		var btn_hover = btn_style.duplicate()
		btn_hover.bg_color = Color(0.3, 0.3, 0.3)

		var btn_minus := Button.new()
		btn_minus.text = "-"
		btn_minus.add_theme_color_override("font_color", Color(1, 1, 1))
		btn_minus.add_theme_stylebox_override("normal", btn_style)
		btn_minus.add_theme_stylebox_override("hover", btn_hover)
		btn_minus.pressed.connect(_on_ev_change.bind(attr, -1))
		center_row.add_child(btn_minus)
		
		var lbl_val := Label.new()
		lbl_val.name = "Val_%d" % attr
		_ev_val_labels[attr] = lbl_val
		lbl_val.text = "10"
		lbl_val.add_theme_font_size_override("font_size", 28)
		lbl_val.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
		lbl_val.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_val.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		center_row.add_child(lbl_val)
		
		var btn_plus := Button.new()
		btn_plus.text = "+"
		btn_plus.add_theme_color_override("font_color", Color(1, 1, 1))
		btn_plus.add_theme_stylebox_override("normal", btn_style)
		btn_plus.add_theme_stylebox_override("hover", btn_hover)
		btn_plus.pressed.connect(_on_ev_change.bind(attr, 1))
		center_row.add_child(btn_plus)
		
		vbox.add_child(center_row)
		
		var lbl_bottom := Label.new()
		lbl_bottom.name = "Bottom_%d" % attr
		_ev_name_labels[attr] = lbl_bottom
		lbl_bottom.text = attr_names[attr]
		lbl_bottom.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_bottom.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		vbox.add_child(lbl_bottom)

		ev_grid.add_child(panel)

## Atualiza contador e atributos mostrados. A fonte única do valor é o próprio
## PokemonInstance (base da forma + natureza + IV + EV), igual à ficha final.
func _update_ev_display() -> void:
	if not _temp_pkmn: return

	var pontos_sobrando := _temp_pkmn.get_unspent_evs()
	if is_instance_valid(_ev_counter_label):
		_ev_counter_label.text = "Pontos de EV Sobrando: %d" % pontos_sobrando
		# Âmbar enquanto houver pontos a distribuir (são obrigatórios); verde quando zerar.
		var cor := Color(0.95, 0.7, 0.2) if pontos_sobrando > 0 else Color(0.5, 0.85, 0.5)
		_ev_counter_label.add_theme_color_override("font_color", cor)
	add_button.disabled = pontos_sobrando > 0

	for attr in Constants.Attribute.values():
		var val_lbl = _ev_val_labels.get(attr)
		var bottom_lbl = _ev_name_labels.get(attr)
		if not is_instance_valid(val_lbl) or not is_instance_valid(bottom_lbl):
			continue

		var ev_val := int(_temp_pkmn.evs.get(attr, 0))
		val_lbl.text = str(_temp_pkmn.get_effective_attribute(attr))

		var base_text: String = bottom_lbl.text.split(" (")[0]
		if ev_val > 0:
			bottom_lbl.text = "%s (+%d)" % [base_text, ev_val]
		else:
			bottom_lbl.text = base_text

func _on_ev_change(attr: Constants.Attribute, amount: int) -> void:
	if not _temp_pkmn: return
	var current_ev = int(_temp_pkmn.evs.get(attr, 0))

	if amount > 0:
		if _temp_pkmn.get_unspent_evs() > 0 and current_ev < PokemonInstance.EV_MAX_PER_ATTR:
			_temp_pkmn.evs[attr] = current_ev + 1
	elif amount < 0:
		if current_ev > 0:
			_temp_pkmn.evs[attr] = current_ev - 1
	_update_ev_display()

func _on_level_changed(value: float) -> void:
	if not _temp_pkmn: return
	_temp_pkmn.level = int(value)
	# O nível de captura nunca passa do nível atual.
	if _capture_spin:
		_capture_spin.max_value = _temp_pkmn.level
		if _temp_pkmn.capture_level > _temp_pkmn.level:
			_capture_spin.set_value_no_signal(_temp_pkmn.level)
			_temp_pkmn.capture_level = _temp_pkmn.level
	_trim_evs_to_max()
	_update_ev_display()

func _on_capture_level_changed(value: float) -> void:
	if not _temp_pkmn: return
	_temp_pkmn.capture_level = int(value)
	_trim_evs_to_max()
	_update_ev_display()

## Se o limite de EVs diminuiu (nível ou nível de captura mudou), remove pontos
## começando pelo atributo com mais EVs.
func _trim_evs_to_max() -> void:
	var max_ev := _temp_pkmn.get_max_evs_allowed()
	while _temp_pkmn.get_total_evs_spent() > max_ev:
		var most_ev_attr = Constants.Attribute.STR
		var max_val := 0
		for a in _temp_pkmn.evs:
			if int(_temp_pkmn.evs[a]) > max_val:
				max_val = int(_temp_pkmn.evs[a])
				most_ev_attr = a
		if max_val == 0: break
		_temp_pkmn.evs[most_ev_attr] = max_val - 1

func _on_nature_changed(index: int) -> void:
	if _temp_pkmn:
		_temp_pkmn.nature = _nature_option.get_item_id(index)
		_update_ev_display()

# ---------- Tela de Seleção de Moves ----------

func _on_move_slot_clicked(slot_index: int) -> void:
	_active_slot_index = slot_index
	_config_box.hide()
	_turn_cancel_into_back()

	_move_select_box = VBoxContainer.new()
	_move_select_box.custom_minimum_size = Vector2(600, 400)
	_move_select_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var vbox: VBoxContainer = $Panel/Margin/VBox
	vbox.add_child(_move_select_box)
	vbox.move_child(_move_select_box, 2)
	
	var title = Label.new()
	title.text = "Escolha um Move para o Slot %d" % (slot_index + 1)
	title.add_theme_font_size_override("font_size", 16)
	_move_select_box.add_child(title)
	
	var search_row := HBoxContainer.new()
	var search_lbl := Label.new()
	search_lbl.text = "Buscar:"
	search_row.add_child(search_lbl)
	
	_search_move_edit = LineEdit.new()
	_search_move_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_search_move_edit.placeholder_text = "Digite o nome do move..."
	_search_move_edit.text_changed.connect(_on_search_move_changed)
	search_row.add_child(_search_move_edit)
	_move_select_box.add_child(search_row)
	
	var tabs := TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_move_select_box.add_child(tabs)
	
	var form_data = _selected_species.get_form_data(_selected_form)
	var current_level = int(_level_spin.value)
	
	var level_moves = []
	for m in form_data.get("starting_moves", []):
		var id = PokemonInstance.normalize_move_id(m)
		if id not in level_moves: level_moves.append(id)
		
	for lvl in form_data.get("level_moves", {}):
		if int(lvl) <= current_level:
			for m in form_data["level_moves"][lvl]:
				var id = PokemonInstance.normalize_move_id(m)
				if id not in level_moves: level_moves.append(id)
	
	var egg_moves = []
	for m in form_data.get("egg_moves", []):
		var id = PokemonInstance.normalize_move_id(m)
		if id not in egg_moves: egg_moves.append(id)

	var tm_moves = []
	for m in form_data.get("tms", []):
		var id = str(m).to_lower()
		if not id.begins_with("tm_"):
			id = "tm_" + id
		var real_move_id = TmData.get_move_id(int(id.replace("tm_", "")))
		if real_move_id != "" and real_move_id not in tm_moves:
			tm_moves.append(real_move_id)

	_all_move_buttons.clear()
	_build_move_tab(tabs, "Nível", level_moves)
	_build_move_tab(tabs, "Egg", egg_moves)
	_build_move_tab(tabs, "TM", tm_moves)

func _build_move_tab(tabs: TabContainer, tab_name: String, move_ids: Array) -> void:
	var scroll := ScrollContainer.new()
	scroll.name = tab_name
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	
	var list_vbox := VBoxContainer.new()
	list_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_vbox.add_theme_constant_override("separation", 6)
	scroll.add_child(list_vbox)
	tabs.add_child(scroll)
	
	if move_ids.is_empty():
		var lbl := Label.new()
		lbl.text = "Nenhum move disponível."
		lbl.modulate = Color(0.5, 0.5, 0.5)
		list_vbox.add_child(lbl)
		return
		
	for id in move_ids:
		if id in _chosen_moves: continue 
		var move = PokemonDB.get_move(id)
		if not move: continue
		
		var btn := Button.new()
		btn.text = move.name_en
		btn.set_meta("move_name", move.name_en.to_lower())
		btn.custom_minimum_size.y = 45
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var type_color = MoveSlot.TYPE_COLORS.get(move.type, Color.WHITE)
		btn.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
		
		var style = StyleBoxFlat.new()
		style.bg_color = type_color.lightened(0.2)
		style.border_color = type_color.darkened(0.4)
		style.set_border_width_all(2)
		style.set_corner_radius_all(4)
		btn.add_theme_stylebox_override("normal", style)
		
		var style_hover = style.duplicate()
		style_hover.bg_color = type_color.lightened(0.3)
		btn.add_theme_stylebox_override("hover", style_hover)
		
		btn.pressed.connect(_on_move_selected.bind(id, move))
		list_vbox.add_child(btn)
		_all_move_buttons.append(btn)

func _on_search_move_changed(new_text: String) -> void:
	var query = new_text.strip_edges().to_lower()
	for btn in _all_move_buttons:
		var move_name = btn.get_meta("move_name", "")
		btn.visible = query.is_empty() or move_name.contains(query)

func _on_move_selected(move_id: String, move: MoveData) -> void:
	var existing_idx = _chosen_moves.find(move_id)
	if existing_idx != -1 and existing_idx != _active_slot_index:
		if existing_idx < _chosen_moves.size():
			_chosen_moves[existing_idx] = ""
			_slots_ui[existing_idx].setup_empty()

	if _active_slot_index >= 0 and _active_slot_index < _chosen_moves.size():
		_chosen_moves[_active_slot_index] = move_id
		_slots_ui[_active_slot_index].setup_with_move(move)
	elif _active_slot_index == _chosen_moves.size():
		_chosen_moves.append(move_id)
		_slots_ui[_active_slot_index].setup_with_move(move)
		
	_close_move_selector()

func _close_move_selector() -> void:
	if _move_select_box:
		_move_select_box.queue_free()
		_move_select_box = null
	_config_box.show()
	_active_slot_index = -1

# ---------- Navegação / Finalizar ----------

func _turn_cancel_into_back() -> void:
	if _cancel_text_backup.is_empty(): _cancel_text_backup = cancel_button.text
	if not _cancel_is_back:
		if cancel_button.pressed.is_connected(hide): cancel_button.pressed.disconnect(hide)
		cancel_button.pressed.connect(_on_back_pressed)
		_cancel_is_back = true
	cancel_button.text = "Voltar"

func _restore_cancel_button() -> void:
	if _cancel_is_back:
		if cancel_button.pressed.is_connected(_on_back_pressed): cancel_button.pressed.disconnect(_on_back_pressed)
		if not cancel_button.pressed.is_connected(hide): cancel_button.pressed.connect(hide)
		_cancel_is_back = false
	cancel_button.text = _cancel_text_backup if not _cancel_text_backup.is_empty() else "Cancelar"
	_cancel_text_backup = ""

func _on_back_pressed() -> void:
	if _move_select_box:
		_close_move_selector()
		return
	_clear_selection()

func _on_add_pressed() -> void:
	if _selected_species == null: return
	var ability := ""
	if _ability_option and not _ability_option.disabled:
		ability = _ability_option.get_item_text(_ability_option.selected).replace(" (Oculta)", "")
	
	var final_moves: Array[String] = []
	for m in _chosen_moves:
		if not m.is_empty():
			final_moves.append(m)
			
	# Os Pontos de EV são obrigatórios: não adiciona com pontos sobrando.
	if _temp_pkmn and _temp_pkmn.get_unspent_evs() > 0:
		return

	pokemon_chosen.emit(
		_selected_species.id,
		_selected_form,
		int(_level_spin.value),
		_nature_option.get_selected_id(),
		ability,
		final_moves,
		_temp_pkmn.evs.duplicate() if _temp_pkmn else {},
		_temp_pkmn.capture_level if _temp_pkmn else 1
	)
	hide()
