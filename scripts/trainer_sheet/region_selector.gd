extends Window
## Janela modal de seleção de região de origem.
## Etapa 1: grade de regiões. Etapa 2: escolhas (radio/checkbox) na ChoiceContainer.
##
## Regiões sem dados em Regions (Paldea) ficam desabilitadas.
## Regiões com escolha (Kanto, Unova, Galar) trocam a grade por uma segunda etapa
## dentro do próprio Window, sem abrir outra janela.

signal region_chosen(id: String, choices: Dictionary)

@onready var grid: GridContainer = $Panel/Margin/VBox/GridContainer
@onready var choice_scroll: ScrollContainer = $Panel/Margin/VBox/ChoiceScroll
@onready var choice_container: VBoxContainer = $Panel/Margin/VBox/ChoiceScroll/ChoiceContainer

var _choice_box: VBoxContainer
var _confirm: Button

# Kanto: 2 grupos de radio independentes (podem coincidir = +2)
var _kanto_groups: Array[ButtonGroup] = []

# Unova: checkboxes de perícia
var _unova_checks: Array[CheckBox] = []
var _unova_needed: int = 0

func _ready() -> void:
	for cell in grid.get_children():
		var id := String(cell.name)
		var btn: TextureButton = cell.get_node("TextureButton")
		btn.disabled = not Regions.has_data(id)
		btn.pressed.connect(_on_region_pressed.bind(id))
	close_requested.connect(_on_close_requested)

func _on_close_requested() -> void:
	_reset()
	hide()

func _on_region_pressed(id: String) -> void:
	var options := Regions.get_options(id)
	if Regions.get_free_points(id) > 0:
		_ask_free_points(id)
	elif Regions.get_free_skills(id) > 0:
		_ask_free_skills(id)
	elif options.size() > 1:
		_ask_option(id, options)
	else:
		_finish(id, {"attr_bonus": options[0] if not options.is_empty() else {}})

# ---------- etapa 2: escolhas ----------

## Galar: dois combos fixos, radio mutuamente exclusivo
func _ask_option(id: String, options: Array) -> void:
	var box := _begin_choice("%s: escolha um pacote de bônus" % id)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 24)
	box.add_child(row)

	var group := ButtonGroup.new()
	for opt in options:
		var rb := CheckBox.new()
		rb.text = Regions.describe(opt)
		rb.button_group = group
		rb.set_meta("opt", opt)
		row.add_child(rb)

	_confirm = Button.new()
	_confirm.text = "Confirmar"
	_confirm.disabled = true
	group.pressed.connect(func(_btn: BaseButton) -> void:
		_confirm.disabled = false)
	_confirm.pressed.connect(func() -> void:
		var pressed := group.get_pressed_button()
		if pressed:
			_finish(id, {"attr_bonus": pressed.get_meta("opt")}))
	box.add_child(_confirm)

## Kanto: N pontos livres. Um grupo de radio por ponto; coincidir = +2.
## Confirmar só habilita quando todos os grupos tiverem um radio marcado.
func _ask_free_points(id: String) -> void:
	var points := Regions.get_free_points(id)
	var box := _begin_choice(
		"%s: distribua %d pontos (o mesmo atributo duas vezes = +2)" % [id, points]
	)
	_kanto_groups.clear()

	for p in points:
		var row := HBoxContainer.new()
		var lbl := Label.new()
		lbl.text = "Ponto %d:" % (p + 1)
		lbl.custom_minimum_size.x = 70
		row.add_child(lbl)

		var group := ButtonGroup.new()
		_kanto_groups.append(group)
		for i in Regions.ATTR_LABELS.size():
			var rb := CheckBox.new()
			rb.text = Regions.ATTR_LABELS[i]
			rb.button_group = group
			rb.set_meta("attr_index", i)
			rb.toggled.connect(_on_kanto_toggled)
			row.add_child(rb)
		box.add_child(row)

	_confirm = Button.new()
	_confirm.text = "Confirmar"
	_confirm.disabled = true
	_confirm.pressed.connect(_on_free_points_confirmed.bind(id))
	box.add_child(_confirm)

func _on_kanto_toggled(_pressed: bool) -> void:
	# Habilita confirmar quando todos os grupos têm um botão marcado
	for group in _kanto_groups:
		if group.get_pressed_button() == null:
			_confirm.disabled = true
			return
	_confirm.disabled = false

func _on_free_points_confirmed(id: String) -> void:
	var bonus := {}
	for group in _kanto_groups:
		var pressed := group.get_pressed_button()
		if pressed == null:
			continue  # não deve acontecer: Confirmar está desabilitado
		var idx: int = pressed.get_meta("attr_index")
		bonus[idx] = bonus.get(idx, 0) + 1
	_finish(id, {"attr_bonus": bonus})

## Unova: N perícias, CheckBoxes com contador. A perícia fixa da região
## NÃO aparece na lista (já vem treinada automaticamente).
func _ask_free_skills(id: String) -> void:
	_unova_needed = Regions.get_free_skills(id)
	var fixed: int = Regions.get_skill(id)
	var box := _begin_choice("%s: escolha %d perícias" % [id, _unova_needed])
	_unova_checks.clear()

	var fixed_lbl := Label.new()
	fixed_lbl.text = "Fixa da região: %s" % Constants.SKILL_DETAILS[fixed]["name"]
	fixed_lbl.modulate = Color(0.7, 0.7, 0.7)
	box.add_child(fixed_lbl)

	for skill in Constants.Skill.values():
		if skill == fixed:
			continue  # fixa da região: não entra na escolha
		var cb := CheckBox.new()
		cb.text = Constants.SKILL_DETAILS[skill]["name"]
		cb.set_meta("skill", skill)
		cb.toggled.connect(_on_unova_toggled)
		box.add_child(cb)
		_unova_checks.append(cb)

	_confirm = Button.new()
	_confirm.text = "Confirmar (0/%d)" % _unova_needed
	_confirm.disabled = true
	_confirm.pressed.connect(_on_free_skills_confirmed.bind(id))
	box.add_child(_confirm)

func _on_unova_toggled(_pressed: bool) -> void:
	var chosen := _unova_checks.filter(func(c: CheckBox) -> bool:
		return c.button_pressed)
	var n := chosen.size()
	_confirm.text = "Confirmar (%d/%d)" % [n, _unova_needed]
	_confirm.disabled = n != _unova_needed
	# Trava os não-marcados se já atingiu o limite
	for cb in _unova_checks:
		cb.disabled = (n >= _unova_needed) and not cb.button_pressed

func _on_free_skills_confirmed(id: String) -> void:
	var picked := []
	for cb in _unova_checks:
		if cb.button_pressed and not cb.disabled:
			picked.append(cb.get_meta("skill"))
	var options := Regions.get_options(id)
	_finish(id, {
		"attr_bonus": options[0] if not options.is_empty() else {},
		"skills": picked,
	})

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

func _finish(id: String, choices: Dictionary) -> void:
	region_chosen.emit(id, choices)
	_reset()
	hide()

func _reset() -> void:
	if _choice_box:
		_choice_box.queue_free()
		_choice_box = null
	_kanto_groups.clear()
	_unova_checks.clear()
	_confirm = null
	grid.show()
	choice_scroll.hide()
