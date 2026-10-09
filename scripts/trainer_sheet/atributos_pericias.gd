extends Control

const RadarGraph = preload("res://addons/godot_radar_graph/radar_graph.gd")
const SKILL_SCENE := preload("res://scenes/skill_row.tscn")

# Mesma ordem dos LineEdits (FOR, DEX, CON, INT, WIS, CHA) e dos itens do radar
const ATTR_ORDER := [
	Constants.Attribute.STR,
	Constants.Attribute.DEX,
	Constants.Attribute.CON,
	Constants.Attribute.INT,
	Constants.Attribute.WIS,
	Constants.Attribute.CHA,
]

@onready var radar_graph: RadarGraph = $Atributos
@onready var attributes: Array[LineEdit] = [
	$Atributos/FOR,
	$Atributos/DEX,
	$Atributos/CON,
	$Atributos/INT,
	$Atributos/WIS,
	$Atributos/CHA ]
@onready var skills_container = $Skills/VBoxContainer
@onready var saving_rows: Array[HBoxContainer] = [
	$SavingThrows/Saving1, $SavingThrows/Saving2, $SavingThrows/Saving3,
	$SavingThrows/Saving4, $SavingThrows/Saving5, $SavingThrows/Saving6 ]  # mesma ordem de ATTR_ORDER
@onready var perception_panel: Panel = $Perception
@onready var initiative_panel: Panel = $Iniciative

var data: TrainerData
var skill_rows: Array[SkillRow] = []
var saving_checks: Array[CheckBox] = []
var saving_labels: Array[Label] = []
var saving_names: Array[String] = []
var perception_value: Label
var initiative_value: Label

func _ready() -> void:
	for i in attributes.size():
		var le := attributes[i]
		le.text_submitted.connect(_on_line_edit_text_submitted.bind(i))
		le.text_changed.connect(_on_line_edit_text_changed.bind(le))
		le.focus_exited.connect(_on_line_edit_focus_exited.bind(le, i))

## Chamado pela TrainerSheet depois que o TrainerData existe
func setup(trainer: TrainerData) -> void:
	data = trainer
	data.attribute_changed.connect(_on_data_attribute_changed)
	data.changed.connect(_on_data_changed)

	# Salvaguardas: o nome base ("Força") vem do texto atual do label
	for i in saving_rows.size():
		var check: CheckBox = saving_rows[i].get_node("IsTrained")
		var label: Label = saving_rows[i].get_node("AttributeLabel")
		check.toggled.connect(_on_saving_toggled.bind(i))
		saving_checks.append(check)
		saving_labels.append(label)
		saving_names.append(label.text.get_slice(" (", 0))

	perception_value = _get_value_label(perception_panel)
	initiative_value = _get_value_label(initiative_panel)
	_refresh_derived()

	for i in ATTR_ORDER.size():
		_refresh_attribute(i, false)

	for i in Constants.Skill.size():
		var row: SkillRow = SKILL_SCENE.instantiate()
		skills_container.add_child(row)  # primeiro entra na árvore, depois set_data
		row.set_data({
			"name": Constants.SKILL_DETAILS[i]["name"],
			"attribute": Constants.SKILL_DETAILS[i]["attribute"],
			"trained": i in data.trained_skills,
			"expert": i in data.expert_skills,
			"bonus": data.get_skill_bonus(i),
		})
		row.trained_toggled.connect(_on_row_trained_toggled.bind(i))
		row.expert_toggled.connect(_on_row_expert_toggled.bind(i))
		skill_rows.append(row)

# ---------- UI -> dados ----------

func _on_line_edit_text_changed(new_text: String, line_edit: LineEdit) -> void:
	var filtered := ""
	for c in new_text:
		if c.is_valid_int():
			filtered += c

	if filtered != new_text:
		var caret_pos := line_edit.caret_column
		line_edit.text = filtered
		line_edit.caret_column = caret_pos - (new_text.length() - filtered.length())

func _on_line_edit_text_submitted(new_text: String, index: int) -> void:
	_apply_value(new_text, index)

func _on_line_edit_focus_exited(line_edit: LineEdit, index: int) -> void:
	_apply_value(line_edit.text, index)

func _apply_value(new_text: String, index: int) -> void:
	if not new_text.is_valid_int():
		_refresh_attribute(index, false)  # campo vazio: volta ao valor salvo
		return
	data.set_attribute(ATTR_ORDER[index], int(new_text))  # só escreve no recurso

func _on_saving_toggled(pressed: bool, index: int) -> void:
	data.set_saving_throw_trained(ATTR_ORDER[index], pressed)

func _on_row_trained_toggled(pressed: bool, skill: int) -> void:
	data.set_skill_trained(skill as Constants.Skill, pressed)

func _on_row_expert_toggled(pressed: bool, skill: int) -> void:
	data.set_skill_expert(skill as Constants.Skill, pressed)

# ---------- dados -> UI ----------

func _on_data_attribute_changed(attr: Constants.Attribute, _value: int) -> void:
	_refresh_attribute(ATTR_ORDER.find(attr), true)

func _refresh_attribute(index: int, animate: bool) -> void:
	var value: int = data.attributes[ATTR_ORDER[index]]
	attributes[index].text = str(value)

	var mod := Constants.get_attribute_modifier(value)
	var base_name: String = radar_graph.get_item(index)["title"].get_slice(" (", 0)
	var sign_str := "+" if mod >= 0 else ""
	radar_graph.set_item_title(index, "%s (%s%d)" % [base_name, sign_str, mod])

	if animate:
		create_tween().tween_property(
			radar_graph, "items/key_%d/value" % index, float(value), 0.4)
	else:
		radar_graph.set_item_value(index, float(value))

func _refresh_skill_bonuses() -> void:
	for i in skill_rows.size():
		skill_rows[i].set_bonus(data.get_skill_bonus(i))

func _on_data_changed() -> void:
	_refresh_skill_bonuses()
	_refresh_derived()

## Salvaguardas, iniciativa e percepção passiva
func _refresh_derived() -> void:
	for i in ATTR_ORDER.size():
		var attr: Constants.Attribute = ATTR_ORDER[i]
		saving_checks[i].set_pressed_no_signal(attr in data.saving_throws)
		saving_labels[i].text = "%s (%+d)" % [saving_names[i], data.get_saving_throw_bonus(attr)]
	perception_value.text = str(data.get_passive_perception())
	initiative_value.text = "%+d" % data.initiative

## Usa o Label "Value" do painel, se você criar um no editor; senão cria um por código
func _get_value_label(panel: Panel) -> Label:
	var existing := panel.get_node_or_null("Value")
	if existing is Label:
		return existing
	var label := Label.new()
	label.name = "Value"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 28)
	panel.add_child(label)
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.offset_bottom = -26  # deixa o título ("Iniciativa") visível embaixo
	return label
