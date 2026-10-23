extends ChoiceWindow
## Janela modal de seleção de região de origem.
## Etapa 1: grade de regiões. Etapa 2: escolhas (radio/checkbox) na ChoiceContainer.
##
## Regiões sem dados em Regions (Paldea) ficam desabilitadas.
## Regiões com escolha (Kanto, Unova, Galar) trocam a grade por uma segunda etapa
## dentro do próprio Window, sem abrir outra janela.

signal region_chosen(id: String, choices: Dictionary)

# Kanto: 2 grupos de radio independentes (podem coincidir = +2)
var _kanto_groups: Array[ButtonGroup] = []

func _has_data(id: String) -> bool:
	return Regions.has_data(id)

func _on_cell_pressed(id: String) -> void:
	var options := Regions.get_options(id)
	if Regions.get_free_points(id) > 0:
		_ask_free_points(id)
	elif Regions.get_free_skills(id) > 0:
		_ask_free_skills(id)
	elif options.size() > 1:
		_ask_option(id, options)
	else:
		_finish(id, {"attr_bonus": _default_bonus(id)})

## Pacote de bônus único da região ({} se não houver).
func _default_bonus(id: String) -> Dictionary:
	var options := Regions.get_options(id)
	return options[0] if not options.is_empty() else {}

# ---------- etapa 2: escolhas ----------

## Galar: dois combos fixos, radio mutuamente exclusivo
func _ask_option(id: String, options: Array) -> void:
	_needed = 1
	var box := _begin_choice("%s: escolha um pacote de bônus" % id)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 24)
	box.add_child(row)

	var group := ButtonGroup.new()
	for opt in options:
		_add_option(row, Regions.describe(opt), opt, group)
	_add_confirm(box, func() -> void:
		_finish(id, {"attr_bonus": _picked_values()[0]}))

## Kanto: N pontos livres. Um grupo de radio por ponto; coincidir = +2.
## Confirmar só habilita quando todos os grupos tiverem um radio marcado.
func _ask_free_points(id: String) -> void:
	var points := Regions.get_free_points(id)
	var box := _begin_choice(
			"%s: distribua %d pontos (o mesmo atributo duas vezes = +2)" % [id, points])
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
			_add_option(row, Regions.ATTR_LABELS[i], i, group, _on_kanto_toggled)
		box.add_child(row)

	_add_confirm(box, func() -> void:
		var bonus := {}
		for g in _kanto_groups:
			var idx: int = g.get_pressed_button().get_meta("value")
			bonus[idx] = bonus.get(idx, 0) + 1
		_finish(id, {"attr_bonus": bonus}))

func _on_kanto_toggled(_pressed: bool) -> void:
	_confirm.disabled = _kanto_groups.any(func(g: ButtonGroup) -> bool:
		return g.get_pressed_button() == null)

## Unova: N perícias, CheckBoxes com contador. A perícia fixa da região
## NÃO aparece na lista (já vem treinada automaticamente).
func _ask_free_skills(id: String) -> void:
	_needed = Regions.get_free_skills(id)
	var fixed: int = Regions.get_skill(id)
	var box := _begin_choice("%s: escolha %d perícias" % [id, _needed])

	var fixed_lbl := Label.new()
	fixed_lbl.text = "Fixa da região: %s" % Constants.SKILL_DETAILS[fixed]["name"]
	fixed_lbl.modulate = Color(0.7, 0.7, 0.7)
	box.add_child(fixed_lbl)

	for skill in Constants.Skill.values():
		if skill != fixed:
			_add_option(box, Constants.SKILL_DETAILS[skill]["name"], skill)
	_add_confirm(box, func() -> void:
		_finish(id, {"attr_bonus": _default_bonus(id), "skills": _picked_values()}))

func _finish(id: String, choices: Dictionary) -> void:
	region_chosen.emit(id, choices)
	_close()

func _reset() -> void:
	super()
	_kanto_groups.clear()
