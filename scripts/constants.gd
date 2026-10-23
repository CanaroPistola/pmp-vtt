extends Node

enum Attribute{
	STR, 
	DEX, 
	CON, 
	INT, 
	WIS, 
	CHA
}

enum Skill{
	ACROBACIA, 
	ADESTRAR_ANIMAIS, 
	ARCANISMO, 
	ATLETISMO,
	ATUACAO, 
	ENGANACAO, 
	FURTIVIDADE, 
	HISTORIA, 
	INTIMIDACAO,
	INTUICAO, 
	INVESTIGACAO, 
	MEDICINA, 
	NATUREZA, 
	PERCEPCAO,
	PERSUASAO, 
	PRESTIDIGITACAO, 
	RELIGIAO, 
	SOBREVIVENCIA
}

const SKILL_DETAILS := {
	Skill.ACROBACIA: {"name": "Acrobacia", "attribute": Attribute.DEX},
	Skill.ADESTRAR_ANIMAIS: {"name": "Adestrar Animais", "attribute": Attribute.WIS},
	Skill.ARCANISMO: {"name": "Arcanismo", "attribute": Attribute.INT},
	Skill.ATLETISMO: {"name": "Atletismo", "attribute": Attribute.STR},
	Skill.ATUACAO: {"name": "Atuação", "attribute": Attribute.CHA},
	Skill.ENGANACAO: {"name": "Enganação", "attribute": Attribute.CHA},
	Skill.FURTIVIDADE: {"name": "Furtividade", "attribute": Attribute.DEX},
	Skill.HISTORIA: {"name": "História", "attribute": Attribute.INT},
	Skill.INTIMIDACAO: {"name": "Intimidação", "attribute": Attribute.CHA},
	Skill.INTUICAO: {"name": "Intuição", "attribute": Attribute.WIS},
	Skill.INVESTIGACAO: {"name": "Investigação", "attribute": Attribute.INT},
	Skill.MEDICINA: {"name": "Medicina", "attribute": Attribute.WIS},
	Skill.NATUREZA: {"name": "Natureza", "attribute": Attribute.INT},
	Skill.PERCEPCAO: {"name": "Percepção", "attribute": Attribute.WIS},
	Skill.PERSUASAO: {"name": "Persuasão", "attribute": Attribute.CHA},
	Skill.PRESTIDIGITACAO: {"name": "Prestidigitação", "attribute": Attribute.DEX},
	Skill.RELIGIAO: {"name": "Religião", "attribute": Attribute.INT},
	Skill.SOBREVIVENCIA: {"name": "Sobrevivência", "attribute": Attribute.WIS}
}

enum Movement {
	WALKING, 
	SWIMMING, 
	CLIMBING, 
	FLYING,
	DIGGING
}

enum Senses {
	DARK,
	SEISMIC,
	TRUE,
	SONAR
}

enum PokemonType {
	NORMAL,
	FIRE,
	WATER,
	ELECTRIC,
	GRASS,
	ICE,
	FIGHTING,
	POISON,
	GROUND,
	FLYING,
	PSYCHIC,
	BUG,
	ROCK,
	GHOST,
	DRAGON,
	DARK,
	STEEL,
	FAIRY
}

const TYPE_FROM_STRING := {
	"normal": PokemonType.NORMAL,
	"fire": PokemonType.FIRE,
	"water": PokemonType.WATER,
	"electric": PokemonType.ELECTRIC,
	"grass": PokemonType.GRASS,
	"ice": PokemonType.ICE,
	"fighting": PokemonType.FIGHTING,
	"poison": PokemonType.POISON,
	"ground": PokemonType.GROUND,
	"flying": PokemonType.FLYING,
	"psychic": PokemonType.PSYCHIC,
	"bug": PokemonType.BUG,
	"rock": PokemonType.ROCK,
	"ghost": PokemonType.GHOST,
	"dragon": PokemonType.DRAGON,
	"dark": PokemonType.DARK,
	"steel": PokemonType.STEEL,
	"fairy": PokemonType.FAIRY,
}

enum Nature {
	ARROGANTE,
	IMPULSIVO,
	CORAJOSO,
	SERIO,
	DETERMINADO,
	APRESSADO,
	ENERGETICO,
	CURIOSO,
	SERENO,
	TEIMOSO,
	APATICO,
	PREGUICOSO,
	PRUDENTE,
	SABIO,
	TRAVESSO,
	ALEGRE,
	SOCIAVEL,
	INGENUO,
	TIMIDO,
	ASTUTO
}

func get_attribute_modifier(value: int) -> int:
	return floori((value - 10) / 2.0)

const PROFFICIENCY_BONUS := {
	1: 2, 2: 2, 3: 2, 4: 2,
	5: 3, 6: 3, 7: 3, 8: 3,
	9: 4, 10: 4, 11: 4, 12: 4,
	13: 5, 14: 5, 15: 5, 16: 5,
	17: 6, 18: 6, 19: 6, 20: 6
}
