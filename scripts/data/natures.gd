class_name Natures
extends RefCounted

const DATA := {
	Constants.Nature.ARROGANTE: { "name": "Arrogante", "plus": Constants.Attribute.STR, "minus": Constants.Attribute.DEX },
	Constants.Nature.IMPULSIVO: { "name": "Impulsivo", "plus": Constants.Attribute.STR, "minus": Constants.Attribute.CON },
	Constants.Nature.CORAJOSO: { "name": "Corajoso", "plus": Constants.Attribute.STR, "minus": Constants.Attribute.WIS },
	Constants.Nature.SERIO: { "name": "Sério", "plus": Constants.Attribute.STR, "minus": Constants.Attribute.CHA },
	Constants.Nature.DETERMINADO: { "name": "Determinado", "plus": Constants.Attribute.DEX, "minus": Constants.Attribute.STR },
	Constants.Nature.APRESSADO: { "name": "Apressado", "plus": Constants.Attribute.DEX, "minus": Constants.Attribute.CON },
	Constants.Nature.ENERGETICO: { "name": "Energético", "plus": Constants.Attribute.DEX, "minus": Constants.Attribute.CHA },
	Constants.Nature.CURIOSO: { "name": "Curioso", "plus": Constants.Attribute.DEX, "minus": Constants.Attribute.WIS },
	Constants.Nature.SERENO: { "name": "Sereno", "plus": Constants.Attribute.CON, "minus": Constants.Attribute.DEX },
	Constants.Nature.TEIMOSO: { "name": "Teimoso", "plus": Constants.Attribute.CON, "minus": Constants.Attribute.WIS },
	Constants.Nature.APATICO: { "name": "Apático", "plus": Constants.Attribute.CON, "minus": Constants.Attribute.CHA },
	Constants.Nature.PREGUICOSO: { "name": "Preguiçoso", "plus": Constants.Attribute.CON, "minus": Constants.Attribute.STR },
	Constants.Nature.PRUDENTE: { "name": "Prudente", "plus": Constants.Attribute.WIS, "minus": Constants.Attribute.STR },
	Constants.Nature.SABIO: { "name": "Sábio", "plus": Constants.Attribute.WIS, "minus": Constants.Attribute.CON },
	Constants.Nature.TRAVESSO: { "name": "Travesso", "plus": Constants.Attribute.WIS, "minus": Constants.Attribute.CHA },
	Constants.Nature.ALEGRE: { "name": "Alegre", "plus": Constants.Attribute.CHA, "minus": Constants.Attribute.STR },
	Constants.Nature.SOCIAVEL: { "name": "Sociável", "plus": Constants.Attribute.CHA, "minus": Constants.Attribute.DEX },
	Constants.Nature.INGENUO: { "name": "Ingênuo", "plus": Constants.Attribute.CHA, "minus": Constants.Attribute.WIS },
	Constants.Nature.TIMIDO: { "name": "Tímido", "plus": -1, "minus": Constants.Attribute.DEX, "ac_bonus": 1 },
	Constants.Nature.ASTUTO: { "name": "Astuto", "plus": -1, "minus": Constants.Attribute.STR, "ac_bonus": 1 },
}

static func get_display_name(nature: int) -> String:
	return DATA.get(nature, {}).get("name", "Desconhecida")

static func get_plus(nature: int) -> int:
	return DATA.get(nature, {}).get("plus", -1)

static func get_minus(nature: int) -> int:
	return DATA.get(nature, {}).get("minus", -1)

static func get_ac_bonus(nature: int) -> int:
	return DATA.get(nature, {}).get("ac_bonus", 0)
