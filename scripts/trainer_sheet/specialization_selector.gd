extends Window
## Janela modal de seleção de Especialização.
## Etapa 1: grade de especializações.
## Etapa 2 (se pedir): escolha de perícia OU atributo (nunca os dois juntos).
##
## Sinal: specialization_chosen(id, choices)
## choices = {"skill": int, "attribute": int} — os que não se aplicam ficam -1.

signal specialization_chosen(id: String, choices: Dictionary)

@onready var grid: GridContainer = $Panel/Margin/VBox/GridContainer
@onready var choice_scroll: ScrollContainer = $Panel/Margin/VBox/ChoiceScroll
@onready var choice_container: VBoxContainer = $Panel/Margin/VBox/ChoiceScroll/ChoiceContainer

var _choice_box: VBoxContainer
var _confirm: Button

var _current_id: String = ""
var _mode: String = ""            # "skill" | "attribute" | ""
var _options: Array = []          # índices de Skill ou Attribute
var _picked_index: int = -1

func _ready() -> void:
	for cell in grid.get_children():
		var id := String(cell.name)
		var btn: TextureButton = cell.get_node("TextureButton")
		btn.disabled = not Specializations.has_data(id)
		btn.pressed.connect(_on_spec_pressed.bind(id))
	close_requested.connect(_on_close_requested)

func _on_close_requested() -> void:
	_reset()
	hide()

func _on_spec_pressed(id: String) -> void:
	var skill_choice := Specializations.get_skill_choice(id)
	var attr_choice := Specializations.get_attribute_choice(id)

	if not skill_choice.is_empty():
		_ask_single(id, "skill", skill_choice)
	elif not attr_choice.is_empty():
		_ask_single(id, "attribute", attr_choice)
	else:
		specialization_chosen.emit(id, {"skill": -1, "attribute": -1})
		hide()

# ---------- etapa 2 ----------

func _ask_single(id: String, modo: String, options: Array) -> void:
	_current_id = id
	_mode = modo
	_options = options
	_picked_index = -1

	var display := Specializations.get_display_name(id)
	var prompt := ""
	if modo == "skill":
		prompt = "%s: escolha uma perícia" % display
	else:
		prompt = "%s: escolha um atributo para +1" % display

	var box := _begin_choice(prompt)
	var group := ButtonGroup.new()

	for i in options.size():
		var rb := CheckBox.new()
		rb.text = _label_for(modo, options[i])
		rb.button_group = group
		rb.set_meta("index", i)
		rb.toggled.connect(_on_radio_toggled)
		box.add_child(rb)

	_confirm = Button.new()
	_confirm.text = "Confirmar"
	_confirm.disabled = true
	_confirm.pressed.connect(_on_confirmed)
	box.add_child(_confirm)

func _label_for(modo: String, value: int) -> String:
	if modo == "skill":
		return Constants.SKILL_DETAILS[value]["name"]
	else:
		return Regions.ATTR_LABELS[value]

func _on_radio_toggled(pressed: bool) -> void:
	if not pressed:
		return
	_confirm.disabled = false

func _on_confirmed() -> void:
	# Descobre qual botão está marcado
	var picked := -1
	for cb in _choice_box.get_children():
		if cb is CheckBox and cb.button_pressed:
			picked = _options[cb.get_meta("index")]
			break

	var result := {"skill": -1, "attribute": -1}
	if _mode == "skill":
		result["skill"] = picked
	else:
		result["attribute"] = picked

	specialization_chosen.emit(_current_id, result)
	_reset()
	hide()

# ---------- infraestrutura ----------

func _begin_choice(titulo: String) -> VBoxContainer:
	grid.hide()
	choice_scroll.show()
	_choice_box = VBoxContainer.new()
	choice_container.add_child(_choice_box)

	var label := Label.new()
	label.text = titulo
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_choice_box.add_child(label)
	return _choice_box

func _reset() -> void:
	if _choice_box:
		_choice_box.queue_free()
		_choice_box = null
	_confirm = null
	_current_id = ""
	_mode = ""
	_options = []
	_picked_index = -1
	grid.show()
	choice_scroll.hide()
