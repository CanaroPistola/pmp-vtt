class_name SkillRow
extends HBoxContainer

signal trained_toggled(pressed: bool)
signal expert_toggled(pressed: bool)

@onready var is_trained: CheckBox = $IsTrained
@onready var is_expert: CheckBox = $IsExpert
@onready var skill_bonus: LineEdit = $SkillBonus
@onready var skill_name: Label = $SkillName
@onready var skill_attribute: Label = $SkillAttribute

func _ready() -> void:
	is_trained.toggled.connect(trained_toggled.emit)
	is_expert.toggled.connect(expert_toggled.emit)
	skill_bonus.editable = false  # o bônus é calculado pelo TrainerData

func _text_to_attribute(text: String) -> Constants.Attribute:
	match text:
		"(FOR)": return Constants.Attribute.STR
		"(DES)": return Constants.Attribute.DEX
		"(CON)": return Constants.Attribute.CON
		"(INT)": return Constants.Attribute.INT
		"(SAB)": return Constants.Attribute.WIS
		"(CAR)": return Constants.Attribute.CHA
	return Constants.Attribute.STR

func _attribute_to_text(attribute: Constants.Attribute) -> String:
	match attribute:
		Constants.Attribute.STR: return "(FOR)"
		Constants.Attribute.DEX: return "(DES)"
		Constants.Attribute.CON: return "(CON)"
		Constants.Attribute.INT: return "(INT)"
		Constants.Attribute.WIS: return "(SAB)"
		Constants.Attribute.CHA: return "(CAR)"
	return ""

func get_data() -> Dictionary:
	return {
		"name": skill_name.text,
		"attribute": _text_to_attribute(skill_attribute.text),
		"trained": is_trained.button_pressed,
		"expert": is_expert.button_pressed,
		"bonus": int(skill_bonus.text) if skill_bonus.text.is_valid_int() else 0,
	}

func set_data(data: Dictionary) -> void:
	skill_name.text = data["name"]
	skill_attribute.text = _attribute_to_text(data["attribute"])
	# no_signal: não dispara toggled enquanto a linha só está sendo preenchida
	is_trained.set_pressed_no_signal(data["trained"])
	is_expert.set_pressed_no_signal(data["expert"])
	set_bonus(data["bonus"])

## locked: a proficiência vem da região de origem, então o jogador não pode desmarcar
func set_trained(pressed: bool, locked: bool) -> void:
	is_trained.set_pressed_no_signal(pressed)
	is_trained.disabled = locked
	is_trained.tooltip_text = "Vem de região, jornada ou classe" if locked else ""

func set_bonus(value: int) -> void:
	skill_bonus.text = "%+d" % value
