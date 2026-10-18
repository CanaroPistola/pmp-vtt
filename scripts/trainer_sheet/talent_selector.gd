extends Window
signal talent_chosen(id: String, choices: Dictionary)

@onready var grid: GridContainer = $Panel/Margin/VBox/GridContainer
@onready var choice_scroll: ScrollContainer = $Panel/Margin/VBox/ChoiceScroll
@onready var choice_container: VBoxContainer = $Panel/Margin/VBox/ChoiceScroll/ChoiceContainer

var _current_id := ""
var _mode := "" # "attribute" | "skill"
var _needed := 0
var _pickers: Array[CheckBox] = []
var _confirm: Button
var _choice_box: VBoxContainer
var _allowed_types: Array[int] = []

func set_allowed_types(types: Array[int]) -> void:
	_allowed_types = types

func _ready() -> void:
	for cell in grid.get_children():
		var id := String(cell.name)
		var btn: TextureButton = cell.get_node("TextureButton")
		btn.disabled = not TrainersTalents.has_data(id)
		btn.pressed.connect(_on_talent_pressed.bind(id))
	close_requested.connect(_reset_and_hide)

func _on_talent_pressed(id: String) -> void:
	_current_id = id
	var b := TrainersTalents.get_attribute_bonus(id)
	
	if b.has("choice"):
		_ask_attribute(id, b["choice"])
	elif id == "perito":
		_ask_skills(id, 3)
	elif id == "mestre_do_tipo":
		_ask_pokemon_type(id)
	else:
		talent_chosen.emit(id, {})
		hide()

func _ask_attribute(id: String, options: Array) -> void:
	_mode = "attribute"
	_needed = 1
	_pickers.clear()
	var box := _begin_choice("%s: escolha um atributo para +1" % TrainersTalents.get_display_name(id))
	var group := ButtonGroup.new()
	for attr in options:
		var rb := CheckBox.new()
		rb.text = Regions.ATTR_LABELS[attr]
		rb.button_group = group
		rb.set_meta("value", attr)
		rb.toggled.connect(_on_picker_toggled)
		box.add_child(rb)
		_pickers.append(rb)
	_confirm = Button.new()
	_confirm.text = "Confirmar"
	_confirm.disabled = true
	_confirm.pressed.connect(_on_confirmed)
	box.add_child(_confirm)

func _ask_skills(id: String, count: int) -> void:
	_mode = "skill"
	_needed = count
	_pickers.clear()
	var box := _begin_choice("%s: escolha %d perícias" % [TrainersTalents.get_display_name(id), count])
	for skill in Constants.Skill.values():
		var cb := CheckBox.new()
		cb.text = Constants.SKILL_DETAILS[skill]["name"]
		cb.set_meta("value", skill)
		cb.toggled.connect(_on_picker_toggled)
		box.add_child(cb)
		_pickers.append(cb)
	_confirm = Button.new()
	_confirm.text = "Confirmar (0/%d)" % _needed
	_confirm.disabled = true
	_confirm.pressed.connect(_on_confirmed)
	box.add_child(_confirm)

func _on_picker_toggled(_pressed: bool) -> void:
	var n := 0
	for cb in _pickers:
		if cb.button_pressed: n += 1
	if _mode == "attribute":
		_confirm.disabled = (n == 0)
	else:
		_confirm.text = "Confirmar (%d/%d)" % [n, _needed]
		_confirm.disabled = n != _needed
		for cb in _pickers:
			cb.disabled = (n >= _needed) and not cb.button_pressed

func _on_confirmed() -> void:
	var result := {}
	if _mode == "attribute":
		for cb in _pickers:
			if cb.button_pressed:
				result["attribute"] = cb.get_meta("value")
				break
	elif _mode == "skill":
		var picked := []
		for cb in _pickers:
			if cb.button_pressed:
				picked.append(cb.get_meta("value"))
		result["skills"] = picked
	elif _mode == "pokemon_type":
		for cb in _pickers:
			if cb.button_pressed:
				result["pokemon_type"] = cb.get_meta("value")
				break
				
	talent_chosen.emit(_current_id, result)
	_reset_and_hide()

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

func _reset_and_hide() -> void:
	if _choice_box:
		_choice_box.queue_free()
		_choice_box = null
	_pickers.clear()
	_confirm = null
	_current_id = ""
	_mode = ""
	grid.show()
	choice_scroll.hide()
	hide()

func _ask_pokemon_type(id: String) -> void:
	_mode = "pokemon_type"
	_needed = 1
	_pickers.clear()
	
	if _allowed_types.is_empty():
		# Se por algum motivo não tiver especialização, mostra todos (fallback)
		_allowed_types = Constants.PokemonType.values()
		
	var box := _begin_choice("%s: escolha um tipo entre suas especializações" % TrainersTalents.get_display_name(id))
	var group := ButtonGroup.new()
	
	for type_id in _allowed_types:
		var rb := CheckBox.new()
		# Pega o nome do Enum (ex: "DRAGON") e formata
		var type_name = Constants.PokemonType.keys()[type_id].capitalize()
		rb.text = type_name
		rb.button_group = group
		rb.set_meta("value", type_id)
		rb.toggled.connect(_on_picker_toggled)
		box.add_child(rb)
		_pickers.append(rb)
		
	_confirm = Button.new()
	_confirm.text = "Confirmar"
	_confirm.disabled = true
	_confirm.pressed.connect(_on_confirmed)
	box.add_child(_confirm)
