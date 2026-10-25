extends Control
## Aba "Trainer Card": nome, nível, controle de S/R, CA, proficiência, PV, espec. e time.

const SPECIALIZATION_SELECTOR := preload("res://scenes/trainer_sheet/specialization_selector.tscn")
const SPECIALIZATION_POPUP := preload("res://scenes/trainer_sheet/specialization_popup.tscn")
const POKEMON_PICKER := preload("res://scenes/pokemon/pokemon_picker_popup.tscn")

var _spec_selector: Window
var _spec_popup: Window
var _pokemon_picker: Window

@onready var name_edit: LineEdit = $NomeContainer/NomeEdit
@onready var level_edit: LineEdit = $NivelExpContainer/NivelContainer/NivelEdit
@onready var sr_edit: LineEdit = $NivelExpContainer/MaxSRContainer/SREdit
@onready var ac_edit: LineEdit = $ACPanel/LineEdit
@onready var prof_edit: LineEdit = $ProfficiencyPanel/LineEdit
@onready var hp_panel: Panel = $HPPanel
@onready var portrait_button: Button = $TrainerImage/ImageChange
@onready var region_button: Button = $RegiaoContainer/SelectRegion
@onready var journey_button: Button = $JornadaContainer/SelectJourney
@onready var class_button: Button = $ClassContainer/SelectClass
@onready var team_container: HBoxContainer = $TeamContainer

@onready var specialty_buttons: Array[Button] = [
	$SpecialtyContainer/Specialty1/Button,
	$SpecialtyContainer/Specialty2/Button,
	$SpecialtyContainer/Specialty3/Button,
]

var data: TrainerData

func _ready() -> void:
	# Campos calculados: só exibição
	for le in [sr_edit, ac_edit, prof_edit]:
		le.editable = false

	name_edit.text_submitted.connect(_on_name_submitted)
	name_edit.focus_exited.connect(_on_name_focus_exited)

	level_edit.text_changed.connect(_on_digits_only.bind(level_edit))
	level_edit.text_submitted.connect(_apply_level)
	level_edit.focus_exited.connect(_on_level_focus_exited)
	
	_spec_selector = SPECIALIZATION_SELECTOR.instantiate()
	add_child(_spec_selector)
	_spec_selector.hide()
	_spec_selector.specialization_chosen.connect(_on_specialization_chosen)

	_spec_popup = SPECIALIZATION_POPUP.instantiate()
	add_child(_spec_popup)
	_spec_popup.hide()
	_spec_popup.change_requested.connect(_on_specialization_change)
	_spec_popup.remove_requested.connect(_on_specialization_remove)

	_pokemon_picker = POKEMON_PICKER.instantiate()
	add_child(_pokemon_picker)
	_pokemon_picker.hide()
	_pokemon_picker.pokemon_chosen.connect(_on_pokemon_chosen)

func setup(trainer: TrainerData) -> void:
	data = trainer
	data.changed.connect(_refresh)
	hp_panel.setup(data)
	region_button.region_chosen.connect(data.set_region)
	journey_button.journey_chosen.connect(data.set_journey)

	portrait_button.image_selected.connect(data.set_portrait)
	portrait_button.show_image(data.get_portrait())
	class_button.class_chosen.connect(data.set_class)
	
	for i in specialty_buttons.size():
		var btn := specialty_buttons[i]
		btn.pressed.connect(_on_specialty_slot_pressed.bind(i))
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.clip_text = true
		btn.add_theme_font_size_override("font_size", 11)
		btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
		btn.custom_minimum_size.y = 44 

	_refresh()

# ---------- UI -> dados ----------

func _on_name_submitted(text: String) -> void:
	data.set_aname(text.strip_edges())

func _on_name_focus_exited() -> void:
	data.set_aname(name_edit.text.strip_edges())

func _on_level_focus_exited() -> void:
	_apply_level(level_edit.text)

func _apply_level(text: String) -> void:
	if text.is_valid_int():
		data.set_level(int(text))
	_refresh()

func _on_digits_only(new_text: String, line_edit: LineEdit) -> void:
	var filtered := ""
	for c in new_text:
		if c.is_valid_int():
			filtered += c
	if filtered != new_text:
		var caret_pos := line_edit.caret_column
		line_edit.text = filtered
		line_edit.caret_column = caret_pos - (new_text.length() - filtered.length())

# ---------- dados -> UI ----------

func _refresh() -> void:
	if name_edit.text != data.aname:
		name_edit.text = data.aname
	level_edit.text = str(data.level)
	sr_edit.text = data.max_sr
	ac_edit.text = str(data.armor_class)
	prof_edit.text = "%+d" % data.profficiency_bonus
	region_button.text = data.region if not data.region.is_empty() else "Escolha uma região"
	journey_button.text = data.journey if not data.journey.is_empty() else "Escolha uma jornada"
	class_button.disabled = data.level < 2
	if data.trainer_class.is_empty():
		class_button.text = "Escolha uma classe (nível 2)"
	else:
		class_button.text = TrainersClasses.get_display_name(data.trainer_class)
	_refresh_specialty_slots()
	_refresh_team()
	
func _refresh_specialty_slots() -> void:
	var slot_levels := [1, 7, 18]
	for i in specialty_buttons.size():
		var btn := specialty_buttons[i]
		var slot_level: int = slot_levels[i]
		var unlocked := data.level >= slot_level
		var spec := data.get_specialization(i)

		btn.disabled = not unlocked
		btn.custom_minimum_size.y = 48
		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		
		if not unlocked:
			btn.text = "Nível %d" % slot_level
		elif spec.is_empty() or spec.get("id", "").is_empty():
			btn.text = "+"
		else:
			var display_name := Specializations.get_display_name(spec["id"])
			if display_name.length() > 12:
				var partes := display_name.split(" ", true, 1)
				btn.text = partes[0] + "\n" + partes[1]
			else:
				btn.text = display_name

func _refresh_team() -> void:
	if not team_container: return
	var slots = team_container.get_children()
	
	for i in range(mini(slots.size(), 6)):
		var slot_panel = slots[i]
		var tex: TextureRect = slot_panel.get_node_or_null("TextureRect")
		var btn: Button = slot_panel.get_node_or_null("Button")
		
		if not btn: continue
		
		# Desconecta para não duplicar
		if btn.pressed.is_connected(_on_slot_pressed):
			btn.pressed.disconnect(_on_slot_pressed)
		btn.pressed.connect(_on_slot_pressed.bind(i))
		
		var unlocked_count: int = data.POKESLOTS[data.level]
		var unlocked := i < unlocked_count
		
		btn.disabled = not unlocked
		
		# Limpa estilos anteriores
		btn.remove_theme_stylebox_override("normal")
		btn.remove_theme_stylebox_override("hover")
		btn.remove_theme_stylebox_override("disabled")
		
		if not unlocked:
			# Bloqueado
			var sb = StyleBoxFlat.new()
			sb.bg_color = Color(0.1, 0.1, 0.1, 1)
			btn.add_theme_stylebox_override("disabled", sb)
			if tex: tex.texture = null
			btn.tooltip_text = "Slot bloqueado"
			
		elif i < data.pokemons.size():
			var pkmn: PokemonInstance = data.pokemons[i]
			var tex_sprite := PokemonDB.get_sprite(pkmn.species_id)
			if tex:
				tex.texture = tex_sprite
			btn.tooltip_text = "%s\nNv. %d" % [pkmn.get_display_name(), pkmn.level]
			btn.text = ""
			
		else:
			# Vazio
			if tex: tex.texture = null
			btn.text = "+"
			btn.tooltip_text = "Clique para adicionar um Pokémon"

func _on_slot_pressed(slot_index: int) -> void:
	if slot_index >= data.pokemons.size():
		# Abre o picker
		_pokemon_picker.open()
	else:
		# O slot já tem Pokémon. Por enquanto, apenas printa no console.
		var pkmn = data.pokemons[slot_index]
		print("Clicou no Pokémon: ", pkmn.get_display_name())

func _on_pokemon_chosen(species_id: String, form: String, level: int,
		nature: int, ability: String, known_moves: Array[String],
		evs: Dictionary = {}, capture_level: int = 1) -> void:
	var pkmn = PokemonInstance.new()
	pkmn.setup(species_id, form, level, nature, ability)
	pkmn.capture_level = capture_level
	for attr in evs:
		pkmn.evs[attr] = int(evs[attr])
	
	# Define os moves escolhidos no seletor
	if not known_moves.is_empty():
		pkmn.known_moves = known_moves.duplicate()
	
	pkmn.recalculate()
	pkmn.refresh_learnable_moves()
	pkmn.recalculate()
	# EVs em CON mudam o PV máximo: um Pokémon novo começa com PV cheio.
	pkmn.current_hp = pkmn.max_hp
	
	data.add_pokemon(pkmn)

# ---------- Especializações ----------

var _active_slot: int = -1

func _on_specialty_slot_pressed(slot_index: int) -> void:
	_active_slot = slot_index
	var spec := data.get_specialization(slot_index)
	if spec.is_empty() or spec.get("id", "").is_empty():
		_spec_selector.popup_centered()
	else:
		_spec_popup.show_for(slot_index, spec["id"], Specializations.get_feature(spec["id"]))

func _on_specialization_chosen(id: String, choices: Dictionary) -> void:
	if _active_slot < 0: return
	data.set_specialization(_active_slot, id, choices)
	_active_slot = -1

func _on_specialization_change(slot_index: int) -> void:
	_active_slot = slot_index
	_spec_selector.popup_centered()

func _on_specialization_remove(slot_index: int) -> void:
	data.remove_specialization(slot_index)
