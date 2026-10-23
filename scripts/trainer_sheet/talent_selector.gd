extends ChoiceWindow
## Janela modal de seleção de Talento.
## Sinal: talent_chosen(id, choices) — choices = {"attribute": int}, {"skills": [...]},
## {"pokemon_type": int} ou {} se o talento não pede escolha.

signal talent_chosen(id: String, choices: Dictionary)

var _allowed_types: Array[int] = []

func set_allowed_types(types: Array[int]) -> void:
	_allowed_types = types

func _has_data(id: String) -> bool:
	return TrainersTalents.has_data(id)

func _on_cell_pressed(id: String) -> void:
	var display := TrainersTalents.get_display_name(id)
	var bonus := TrainersTalents.get_attribute_bonus(id)
	if bonus.has("choice"):
		_ask(id, "attribute", "%s: escolha um atributo para +1" % display, bonus["choice"], 1,
				func(a): return Regions.ATTR_LABELS[a])
	elif id == "perito":
		_ask(id, "skills", "%s: escolha 3 perícias" % display, Constants.Skill.values(), 3,
				func(s): return Constants.SKILL_DETAILS[s]["name"])
	elif id == "mestre_do_tipo":
		var types: Array = _allowed_types if not _allowed_types.is_empty() \
				else Constants.PokemonType.values()
		_ask(id, "pokemon_type", "%s: escolha um tipo entre suas especializações" % display,
				types, 1, func(t): return Constants.PokemonType.keys()[t].capitalize())
	else:
		talent_chosen.emit(id, {})
		hide()

## Pede `needed` opções de `options` e emite {key: valor} (ou {key: [valores]} se needed > 1).
func _ask(id: String, key: String, _title: String, options: Array, needed: int,
		label: Callable) -> void:
	_needed = needed
	var box := _begin_choice(_title)
	var group := ButtonGroup.new() if needed == 1 else null
	for value in options:
		_add_option(box, label.call(value), value, group)
	_add_confirm(box, func() -> void:
		var picked := _picked_values()
		talent_chosen.emit(id, {key: picked if needed > 1 else picked[0]})
		_close())
