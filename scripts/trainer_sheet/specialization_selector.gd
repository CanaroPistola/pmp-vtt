extends ChoiceWindow
## Janela modal de seleção de Especialização.
## Etapa 1: grade de especializações.
## Etapa 2 (se pedir): escolha de perícia OU atributo (nunca os dois juntos).
##
## Sinal: specialization_chosen(id, choices)
## choices = {"skill": int, "attribute": int} — os que não se aplicam ficam -1.

signal specialization_chosen(id: String, choices: Dictionary)

func _has_data(id: String) -> bool:
	return Specializations.has_data(id)

func _on_cell_pressed(id: String) -> void:
	var skill_choice := Specializations.get_skill_choice(id)
	var attr_choice := Specializations.get_attribute_choice(id)
	if not skill_choice.is_empty():
		_ask_single(id, "skill", skill_choice)
	elif not attr_choice.is_empty():
		_ask_single(id, "attribute", attr_choice)
	else:
		specialization_chosen.emit(id, {"skill": -1, "attribute": -1})
		hide()

## mode: "skill" | "attribute". options: índices de Skill ou Attribute.
func _ask_single(id: String, _mode: String, options: Array) -> void:
	_needed = 1
	var is_skill := _mode == "skill"
	var display := Specializations.get_display_name(id)
	var box := _begin_choice(("%s: escolha uma perícia" if is_skill
			else "%s: escolha um atributo para +1") % display)
	var group := ButtonGroup.new()
	for value in options:
		var label: String = Constants.SKILL_DETAILS[value]["name"] if is_skill \
				else Regions.ATTR_LABELS[value]
		_add_option(box, label, value, group)
	_add_confirm(box, func() -> void:
		var result := {"skill": -1, "attribute": -1}
		result[mode] = _picked_values()[0]
		specialization_chosen.emit(id, result)
		_close())
