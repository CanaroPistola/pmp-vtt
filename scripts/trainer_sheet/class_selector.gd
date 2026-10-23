extends ChoiceWindow
## Janela modal de seleção de Classe de Treinador.
## Etapa 1: grade de classes.
## Etapa 2 (só para Pesquisador e Versátil): escolha de perícias.
##
## Sinal: class_chosen(id, choices) — igual a region_chosen.
## choices = {"skills": [Constants.Skill, ...]} ou {} se a classe não pede escolha.

signal class_chosen(id: String, choices: Dictionary)

func _has_data(id: String) -> bool:
	return TrainersClasses.has_data(id)

func _on_cell_pressed(id: String) -> void:
	var choice := TrainersClasses.get_skills_choice(id)
	if choice.is_empty():
		class_chosen.emit(id, {})
		hide()
	else:
		_ask_skills(id, choice)

func _ask_skills(id: String, choice: Dictionary) -> void:
	_needed = choice.get("count", 1)
	var raw = choice.get("options", [])
	var options: Array = Constants.Skill.values() if raw is String and raw == "all" \
			else (raw if raw is Array else [])  # "all" = todas as perícias

	var display := TrainersClasses.get_display_name(id)
	var box := _begin_choice(("%s: escolha 1 perícia" % display) if _needed == 1
			else ("%s: escolha %d perícias" % [display, _needed]))
	var group := ButtonGroup.new() if _needed == 1 else null
	for skill in options:
		_add_option(box, Constants.SKILL_DETAILS[skill]["name"], skill, group)
	_add_confirm(box, func() -> void:
		class_chosen.emit(id, {"skills": _picked_values()})
		_close())
