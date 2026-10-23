class_name MoveData
extends Resource

# =============================================================================
# Taxonomia dos Moves (derivada da análise dos ~830 JSONs)
#
#  1. Resolução  -> como o move é resolvido (ataque, save, rolagem de status...)
#  2. Ativação   -> quanto custa usar (ação, reação, ação bônus, carga/recarga)
#  3. Alcance    -> forma e distância (pessoal, corpo a corpo, cone, linha, raio...)
#  4. Duração    -> instantânea, N rodadas, enquanto ativo, concentração...
#  5. Função     -> dano, cura, utilidade (+ tags de efeito sugeridas)
#
# IMPORTANTE: os valores novos dos enums foram sempre ADICIONADOS NO FIM, para
# não quebrar .tres antigos. De qualquer forma, rode o import_moves.gd de novo.
# =============================================================================

enum RangeCategory {
	SELF,
	MELEE,
	RANGED,
	CONE,
	LINE,
	RADIUS,
	SPECIAL,
	MELEE_OR_RANGED, # "Corpo a corpo / (12 metros)": pode ser usado em melee ou à distância
	SELF_OR_RANGED,  # "Pessoal / (6 metros)": em si mesmo ou em alguém no alcance
}

enum Resolution {
	AUTOMATIC,       # sem rolagem: buffs, cura, clima, proteção, dano que não erra
	ATTACK_ROLL,     # "Faça um ataque corpo a corpo/à distância" (compara com CA)
	SAVE,            # o alvo faz um teste de resistência contra a CD do Move
	ATTACK_AND_SAVE, # acerta com ataque e depois exige save (efeito secundário)
	STATUS_ROLL,     # 1d20 + MOVE + N contra 10 + atributo do alvo (moves sem dano)
}

enum Activation {
	ACTION,
	REACTION,
	BONUS_ACTION,
	ACTION_OR_REACTION, # "1 ação / reação" e "1 reação / ação"
}

enum Role {
	DAMAGE,
	HEAL,
	DAMAGE_AND_HEAL, # ex.: Pollen Puff (dano em inimigo / cura em aliado)
	UTILITY,         # sem dados: buff/debuff, status, campo, proteção etc.
}

@export var id: String = ""
@export var display_name: String = ""   # nome original do JSON: "Absorb (Absorver)"
@export var name_en: String = ""        # "Absorb"
@export var name_pt: String = ""        # "Absorver" (vazio se o JSON não traz)
@export var type: Constants.PokemonType = Constants.PokemonType.NORMAL
@export var type_is_variable: bool = false # Type = "Variável" (o tipo muda em jogo)
@export var pp: int = 10
@export var move_time: String = ""      # texto bruto do JSON
@export var is_attack: bool = false     # compat: usa rolagem de ataque

# --- 1. Resolução ---
@export var resolution: Resolution = Resolution.AUTOMATIC
@export var has_save: bool = false
@export var save_attribute: Constants.Attribute = Constants.Attribute.DEX
# Rolagem de status: 1d20 + MOVE + bônus  vs  10 + atributo do alvo
@export var has_status_roll: bool = false
@export var status_roll_bonus: int = 0
@export var status_roll_target_attribute: Constants.Attribute = Constants.Attribute.WIS

# --- 2. Ativação ---
@export var activation: Activation = Activation.ACTION
@export var needs_charge: bool = false    # "1 ação, carga" / "1 rodada, carga"
@export var needs_recharge: bool = false  # "1 ação, recarga" (ex.: Hyper Beam)

# --- 3. Alcance / área ---
@export var range_category: RangeCategory = RangeCategory.MELEE
# RANGED/CONE/LINE/RADIUS/SELF_OR_RANGED/MELEE_OR_RANGED: distância em metros.
@export var range_distance: float = 1.5
# MELEE_OR_RANGED: alcance corpo a corpo (1.5). Demais categorias: 0.
@export var range_secondary: float = 0.0
# Raio de área centrada num PONTO ESCOLHIDO dentro do alcance (Draco Meteor,
# Spikes, Poison Gas...). 0 = o move não tem área centrada no alvo.
@export var target_area_radius: float = 0.0

# --- 4. Duração ---
@export var duration_rounds: int = 0
@export var duration_is_permanent: bool = false
# Flags possíveis: "concentration", "charge", "recharge", "variable", "conditional"
@export var duration_flags: Array[String] = []

# --- Textos descritivos ---
@export var description: String = ""
@export var scaling_text: String = ""
@export var range_text_raw: String = ""
@export var duration_text_raw: String = ""

# --- 5. Função / poder / dados ---
@export var role: Role = Role.UTILITY
@export var move_power_attributes: Array[Constants.Attribute] = []
# Penalidade ao MOVE (os JSONs usam 0, -1, -2, -3 e -5). Vale p/ todos os atributos.
@export var move_power_modifier: int = 0
# has_damage = os dados causam DANO. has_healing = os dados (ou o move) CURAM.
@export var has_damage: bool = false
@export var has_healing: bool = false
# Dados por nível. Para moves de cura (role HEAL), os dados aqui são de CURA.
# Formato: { nível:int -> { "amount":int, "dice_max":int, "move":bool } }
@export var damage_by_level: Dictionary = {}
# Tags sugeridas automaticamente pelo importer (heurística — revise na mão):
# heal, drain, recoil, multi_hit, ohko, stat_change, protect, shield, weather,
# terrain, hazard, copy, paralysis, burn, poison, sleep, freeze, confusion,
# flinch, grapple, prone, stun, blind
@export var effect_tags: Array[String] = []


# ---------- Dados / dano ----------

func _get_dice_entry(level: int) -> Dictionary:
	if damage_by_level.is_empty():
		return {}
	var keys := damage_by_level.keys()
	keys.sort()
	var best_level = keys[0]
	for k in keys:
		if level >= k:
			best_level = k
		else:
			break
	return damage_by_level[best_level]

func get_damage_string(level: int) -> String:
	if damage_by_level.is_empty():
		return ""
	var data := _get_dice_entry(level)
	return "%dd%d" % [data.get("amount", 1), data.get("dice_max", 4)]

# "2d6 + MOVE" (dano ou cura, conforme o role)
func get_damage_formula(level: int) -> String:
	var dice := get_damage_string(level)
	if dice.is_empty():
		return ""
	if _get_dice_entry(level).get("move", false):
		return dice + " + MOVE"
	return dice


# ---------- Poder ----------

static func _attr_short(attr: int) -> String:
	match attr:
		Constants.Attribute.STR: return "FOR"
		Constants.Attribute.DEX: return "DES"
		Constants.Attribute.CON: return "CON"
		Constants.Attribute.INT: return "INT"
		Constants.Attribute.WIS: return "SAB"
		Constants.Attribute.CHA: return "CAR"
	return "?"

func get_move_power_string() -> String:
	if move_power_attributes.is_empty():
		return "Nenhum"
	var names := []
	for attr in move_power_attributes:
		names.append(_attr_short(attr))
	var text := "/".join(names)
	if move_power_modifier != 0:
		text += " (%d)" % move_power_modifier
	return text


# ---------- Resolução ----------

func uses_attack_roll() -> bool:
	return resolution == Resolution.ATTACK_ROLL or resolution == Resolution.ATTACK_AND_SAVE

func requires_save() -> bool:
	return has_save

func get_save_string() -> String:
	return _attr_short(save_attribute) if has_save else ""

func get_resolution_display() -> String:
	var status := ""
	if has_status_roll:
		status = "1d20 + MOVE%s vs 10 + %s" % [
			("" if status_roll_bonus == 0 else " %+d" % status_roll_bonus),
			_attr_short(status_roll_target_attribute)]
	match resolution:
		Resolution.ATTACK_ROLL: return "Rolagem de ataque"
		Resolution.SAVE: return "Teste de %s" % get_save_string()
		Resolution.ATTACK_AND_SAVE: return "Ataque + teste de %s" % get_save_string()
		Resolution.STATUS_ROLL: return status
	return "Automático"


# ---------- Ativação ----------

func is_reaction() -> bool:
	return activation == Activation.REACTION or activation == Activation.ACTION_OR_REACTION

func get_activation_display() -> String:
	var text := "1 ação"
	match activation:
		Activation.REACTION: text = "1 reação"
		Activation.BONUS_ACTION: text = "1 ação bônus"
		Activation.ACTION_OR_REACTION: text = "1 ação / reação"
	if needs_charge:
		text += ", carga"
	if needs_recharge:
		text += ", recarga"
	return text


# ---------- Alcance ----------

static func _fmt_m(v: float) -> String:
	return "%sm" % String.num(v)

func get_range_display() -> String:
	match range_category:
		RangeCategory.SELF: return "Pessoal"
		RangeCategory.MELEE: return "Corpo a corpo"
		RangeCategory.RANGED:
			var text := _fmt_m(range_distance)
			if target_area_radius > 0.0:
				text += " (raio %s)" % _fmt_m(target_area_radius)
			return text
		RangeCategory.CONE: return "Cone de %s" % _fmt_m(range_distance)
		RangeCategory.LINE: return "Linha de %s" % _fmt_m(range_distance)
		RangeCategory.RADIUS: return "Raio de %s" % _fmt_m(range_distance)
		RangeCategory.MELEE_OR_RANGED: return "Corpo a corpo / %s" % _fmt_m(range_distance)
		RangeCategory.SELF_OR_RANGED: return "Pessoal / %s" % _fmt_m(range_distance)
	return range_text_raw

# Moves que nascem no usuário (cone/linha/raio saem de "Pessoal" nos JSONs).
func is_self_origin_area() -> bool:
	return range_category in [RangeCategory.CONE, RangeCategory.LINE, RangeCategory.RADIUS]

func is_area() -> bool:
	return is_self_origin_area() or target_area_radius > 0.0


# ---------- Duração ----------

func requires_concentration() -> bool:
	return "concentration" in duration_flags

func get_duration_display() -> String:
	var text := ""
	if duration_is_permanent:
		text = "Enquanto ativo"
	elif duration_rounds == 0:
		text = "Instantânea"
	else:
		text = "%d rodada%s" % [duration_rounds, "" if duration_rounds == 1 else "s"]
	if requires_concentration():
		text += ", Concentração"
	return text


# ---------- Tags ----------

func has_tag(tag: String) -> bool:
	return tag in effect_tags
