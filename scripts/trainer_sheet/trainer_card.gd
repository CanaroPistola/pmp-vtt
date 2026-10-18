extends Control
## Aba "Trainer Card": nome, nível, controle de S/R, CA, proficiência e PV.
## Anexe este script ao node TabContainer/TrainerCard.

const SPECIALIZATION_SELECTOR := preload("res://scenes/trainer_sheet/specialization_selector.tscn")
const SPECIALIZATION_POPUP := preload("res://scenes/trainer_sheet/specialization_popup.tscn")

var _spec_selector: Window
var _spec_popup: Window

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

func setup(trainer: TrainerData) -> void:
	data = trainer
	data.changed.connect(_refresh)
	hp_panel.setup(data)
	region_button.region_chosen.connect(data.set_region)
	journey_button.journey_chosen.connect(data.set_journey)

	portrait_button.image_selected.connect(data.set_portrait)
	portrait_button.show_image(data.get_portrait())
	class_button.class_chosen.connect(data.set_class)
	
	# --- Configura os botões de especialização ---
	for i in specialty_buttons.size():
		var btn := specialty_buttons[i]
		btn.pressed.connect(_on_specialty_slot_pressed.bind(i))
		
		# Configuração visual
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.clip_text = true
		btn.add_theme_font_size_override("font_size", 11) # Fonte menor
		btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
		# Garante que o botão tenha espaço vertical pra 2-3 linhas
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
		data.set_level(int(text))  # recalcula SR, proficiência, PV, CA, perícias
	_refresh()  # campo vazio/inválido volta ao valor salvo

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
	# Bloqueia escolha de classe até o nível 2
	class_button.disabled = data.level < 2
	if data.trainer_class.is_empty():
		class_button.text = "Escolha uma classe (nível 2)"
	else:
		class_button.text = TrainersClasses.get_display_name(data.trainer_class)
	_refresh_specialty_slots()
	
func _refresh_specialty_slots() -> void:
	var slot_levels := [1, 7, 18]
	for i in specialty_buttons.size():
		var btn := specialty_buttons[i]
		var slot_level: int = slot_levels[i]
		var unlocked := data.level >= slot_level
		var spec := data.get_specialization(i)

		btn.disabled = not unlocked
		
		# Garante que o botão tenha altura para 2 linhas
		btn.custom_minimum_size.y = 48
		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		
		if not unlocked:
			btn.text = "Nível %d" % slot_level
		elif spec.is_empty() or spec.get("id", "").is_empty():
			btn.text = "+"
		else:
			var display_name := Specializations.get_display_name(spec["id"])
			# Força a quebra de linha substituindo o espaço por \n
			# Isso garante que o nome longo caiba no botão.
			if display_name.length() > 12:
				# Pega a primeira palavra e coloca o resto na segunda linha
				var partes := display_name.split(" ", true, 1)
				btn.text = partes[0] + "\n" + partes[1]
			else:
				btn.text = display_name

var _active_slot: int = -1

func _on_specialty_slot_pressed(slot_index: int) -> void:
	_active_slot = slot_index
	var spec := data.get_specialization(slot_index)
	if spec.is_empty() or spec.get("id", "").is_empty():
		# vazio → abre o seletor
		_spec_selector.popup_centered()
	else:
		# preenchido → abre o popup
		_spec_popup.show_for(slot_index, spec["id"], Specializations.get_feature(spec["id"]))

func _on_specialization_chosen(id: String, choices: Dictionary) -> void:
	if _active_slot < 0:
		return
	data.set_specialization(_active_slot, id, choices)
	_active_slot = -1

func _on_specialization_change(slot_index: int) -> void:
	_active_slot = slot_index
	_spec_selector.popup_centered()

func _on_specialization_remove(slot_index: int) -> void:
	data.remove_specialization(slot_index)
