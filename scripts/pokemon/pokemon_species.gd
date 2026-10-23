class_name PokemonSpecies
extends Resource

@export var dex_number: int = 0
@export var display_name: String = ""
@export var id: String = ""

@export var types: Array[Constants.PokemonType] = []
@export var sr: String = ""
@export var size_category: String = ""
@export var size_meters: float = 0.0
@export var min_level: int = 1
@export var egg_groups: Array[String] = []
@export var gender_male_pct: int = 50
@export var gender_female_pct: int = 50
@export var evolution_stage: int = 0
@export var armor_class: int = 10
@export var hit_points: int = 1
@export var hit_dice: String = "d6"
@export var movement: Dictionary = {}
@export var attributes: Dictionary = {}
@export var skills: Array[Constants.Skill] = []
@export var senses: Array[Dictionary] = []
@export var abilities: Array[String] = []
@export var hidden_ability: String = ""

@export var evolves_to: Array[String] = []
@export var evolution_level: int = -1
@export var evolution_points: int = 0

@export var level_moves: Dictionary = {}
@export var starting_moves: Array[String] = []
@export var tms: Array[String] = []
@export var egg_moves: Array[String] = []

@export var is_variant: bool = false
@export var variant_data: Dictionary = {}

func get_form_data(form_name: String = "") -> Dictionary:
	var base_data = {
		"display_name": display_name,
		"types": types.duplicate(),
		"attributes": attributes.duplicate(true),
		"movement": movement.duplicate(true),
		"level_moves": level_moves.duplicate(true),
		"starting_moves": starting_moves.duplicate(),
		"size_meters": size_meters,
		"armor_class": armor_class,
		"hit_points": hit_points,
		"hit_dice": hit_dice,
		"tms": tms.duplicate(),
		"egg_moves": egg_moves.duplicate(),
		"senses": senses.duplicate(true),
		"abilities": abilities.duplicate(),
		"hidden_ability": hidden_ability,
		"min_level": min_level,
		"skills": skills.duplicate(),
		"sr": sr,
	}

	if is_variant and variant_data.has(form_name):
		var diff: Dictionary = variant_data[form_name].get("diff", {})
		_apply_diff(base_data, diff)
		base_data["display_name"] = variant_data[form_name].get("display_name", display_name)

	return base_data

func _apply_diff(base: Dictionary, diff: Dictionary) -> void:
	for key in diff:
		match key:
			"types":
				base["types"] = diff["types"].duplicate()
			"abilities":
				base["abilities"] = diff["abilities"].duplicate()
			"hidden_ability":
				base["hidden_ability"] = String(diff["hidden_ability"])
			"attributes":
				for attr_key in diff["attributes"]:
					base["attributes"][attr_key] = int(diff["attributes"][attr_key])
			"movement":
				for mov_key in diff["movement"]:
					base["movement"][mov_key] = diff["movement"][mov_key]
			"senses":
				base["senses"] = diff["senses"].duplicate(true)
			"skills":
				base["skills"] = diff["skills"].duplicate()
			"min_level":
				base["min_level"] = int(diff["min_level"])
			"armor_class":
				base["armor_class"] = int(diff["armor_class"])
			"hit_points":
				base["hit_points"] = int(diff["hit_points"])
			"hit_dice":
				base["hit_dice"] = String(diff["hit_dice"])
			"size_meters":
				base["size_meters"] = float(diff["size_meters"])
			"sr":
				base["sr"] = String(diff["sr"])
			"moves_diff":
				_apply_moves_diff(base, diff["moves_diff"])
			"level_moves":
				# Compatibilidade com um diff já normalizado por fora
				for lvl in diff["level_moves"]:
					base["level_moves"][int(lvl)] = diff["level_moves"][lvl]
			"starting_moves":
				base["starting_moves"] = diff["starting_moves"].duplicate()
			"tms":
				base["tms"] = diff["tms"].duplicate()
			"egg_moves":
				base["egg_moves"] = diff["egg_moves"].duplicate()
			_:
				# Fallback: chave desconhecida → copia cru
				base[key] = diff[key]

func _apply_moves_diff(base: Dictionary, moves_diff: Dictionary) -> void:
	# Level: mescla (níveis novos sobrepõem, níveis ausentes herdam do base)
	if moves_diff.has("level_moves"):
		for lvl in moves_diff["level_moves"]:
			base["level_moves"][int(lvl)] = moves_diff["level_moves"][lvl].duplicate()

	# Starting Moves: substituição total (a variante redefine a lista inteira)
	if moves_diff.has("starting_moves"):
		base["starting_moves"] = moves_diff["starting_moves"].duplicate()

	# TM / egg: substituição total (a variante redefine a lista inteira)
	if moves_diff.has("tms"):
		base["tms"] = moves_diff["tms"].duplicate()
	if moves_diff.has("egg_moves"):
		base["egg_moves"] = moves_diff["egg_moves"].duplicate()
