class_name PokemonSpecies
extends Resource
## Dados de UMA espécie de Pokémon (não é um Pokémon instanciado).
## Espelha os campos do JSON de origem.
##
## Decisões:
##  - `types` é Array[Constants.PokemonType] (enum)
##  - `level_moves` é Dictionary com chave int -> Array[String]
##  - `sr` é String ("1/2", "5", "13") igual ao TrainerData.MAX_SR
##  - `movement` é Dictionary {Constants.Movement: float metros}
##  - `attributes` é Dictionary {Constants.Attribute: int}

@export var dex_number: int = 0
@export var display_name: String = ""
@export var id: String = ""

@export var types: Array[Constants.PokemonType] = []
@export var sr: String = ""

## {"category": "pequeno"|"medio"|..., "meters": float}
@export var size_category: String = ""
@export var size_meters: float = 0.0

@export var min_level: int = 1

@export var egg_groups: Array[String] = []

## [macho_pct, femea_pct]
@export var gender_male_pct: int = 50
@export var gender_female_pct: int = 50

## 0 = estágio base, 1 = primeira evolução, etc.
@export var evolution_stage: int = 0

@export var armor_class: int = 10
@export var hit_points: int = 1
@export var hit_dice: String = "d6"

## {Constants.Movement: float metros}
@export var movement: Dictionary = {}

## {Constants.Attribute: int}
@export var attributes: Dictionary = {}

## Array[Constants.Skill]
@export var skills: Array[Constants.Skill] = []

## Sentidos especiais (texto, ex.: "visão no escuro 18m"). Sem enum por enquanto.
@export var senses: Array[String] = []

## Habilidades passivas não ocultas (ids minúsculos, ex.: "overgrow").
@export var abilities: Array[String] = []
## Habilidade oculta (id minúsculo) ou "".
@export var hidden_ability: String = ""

## Id da próxima evolução ou "".
@export var evolves_to: String = ""
## Nível de evolução ou -1 (sem evolução).
@export var evolution_level: int = -1

## {int level: Array[String move_id]}
@export var level_moves: Dictionary = {}

@export var tms: Array[String] = []
@export var egg_moves: Array[String] = []


## Junta os Moves aprendidos até um nível (inclusive).
func get_moves_at_level(level: int) -> Array:
	var result := []
	var levels := level_moves.keys()
	levels.sort()
	for lvl in levels:
		if lvl <= level:
			for move_id in level_moves[lvl]:
				if not result.has(move_id):
					result.append(move_id)
	return result
