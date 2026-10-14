extends Window
## Janela modal de seleção de Classe de Treinador.
## Etapa 1: grade de classes.
## Etapa 2 (só para Pesquisador e Versátil): escolha de perícias.
##
## Sinal: class_chosen(id, choices) — igual a region_chosen.
## choices = {"skills": [Constants.Skill, ...]} ou {} se a classe não pede escolha.

signal class_chosen(id: String, choices: Dictionary)

@onready var grid: GridContainer = $Panel/Margin/VBox/GridContainer
@onready var choice_scroll: ScrollContainer = $Panel/Margin/VBox/ChoiceScroll
@onready var choice_container: VBoxContainer = $Panel/Margin/VBox/ChoiceScroll/ChoiceContainer


var _choice_box: VBoxContainer
var _confirm: Button

# estado da etapa 2
var _current_class_id: String = ""
var _is_radio: bool = false
var _pickers: Array[CheckBox] = []
var _needed: int = 0

func _ready() -> void:
	for cell in grid.get_children():
		var id := String(cell.name)
		var btn: TextureButton = cell.get_node("TextureButton")
		btn.disabled = not TrainersClasses.has_data(id)
		btn.pressed.connect(_on_class_pressed.bind(id))
	close_requested.connect(_on_close_requested)

func _on_close_requested() -> void:
	_reset()
	hide()

func _on_class_pressed(id: String) -> void:
	var choice := TrainersClasses.get_skills_choice(id)
	if choice.is_empty():
		class_chosen.emit(id, {})
		hide()
		return
	_ask_skills(id, choice)

# ---------- etapa 2: escolha de perícias ----------

func _ask_skills(id: String, choice: Dictionary) -> void:
	_current_class_id = id
	_needed = choice.get("count", 1)
	var options_raw = choice.get("options", [])
	_is_radio = (_needed == 1)

	# "all" = todas as perícias disponíveis
	var options: Array
	if options_raw is String and options_raw == "all":
		options = Constants.Skill.values()
	elif options_raw is Array:
		options = options_raw
	else:
		options = []

	var box := _begin_choice(_make_title(id, _needed))
	_pickers.clear()

	# Grupo de botões para o modo radio
	var group := ButtonGroup.new() if _is_radio else null

	for skill in options:
		var cb := CheckBox.new()
		cb.text = Constants.SKILL_DETAILS[skill]["name"]
		cb.set_meta("skill", skill)
		if _is_radio:
			cb.button_group = group
		cb.toggled.connect(_on_picker_toggled)
		box.add_child(cb)
		_pickers.append(cb)

	_confirm = Button.new()
	_confirm.text = "Confirmar (0/%d)" % _needed
	_confirm.disabled = true
	_confirm.pressed.connect(_on_skills_confirmed)
	box.add_child(_confirm)

func _make_title(id: String, count: int) -> String:
	var display := TrainersClasses.get_display_name(id)
	if _is_radio:
		return "%s: escolha 1 perícia" % display
	return "%s: escolha %d perícias" % [display, count]

func _on_picker_toggled(_pressed: bool) -> void:
	var n := _picked_count()
	_confirm.text = "Confirmar (%d/%d)" % [n, _needed]
	_confirm.disabled = n != _needed

	# Radio: o ButtonGroup já garante exclusividade, não trava nada
	if _is_radio:
		return

	# Checkbox: trava os não-marcados quando atinge o limite
	for cb in _pickers:
		cb.disabled = (n >= _needed) and not cb.button_pressed

func _picked_count() -> int:
	var n := 0
	for cb in _pickers:
		if cb.button_pressed:
			n += 1
	return n

func _on_skills_confirmed() -> void:
	var picked := []
	for cb in _pickers:
		if cb.button_pressed:
			picked.append(cb.get_meta("skill"))
	class_chosen.emit(_current_class_id, {"skills": picked})
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
	_pickers.clear()
	_confirm = null
	_current_class_id = ""
	grid.show()
	choice_scroll.hide()
