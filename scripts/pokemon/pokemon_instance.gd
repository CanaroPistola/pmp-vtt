class_name PokemonInstance
extends Resource

@export var species_id: String = ""
@export var form_name: String = ""
@export var nickname: String = ""
@export var level: int = 1

@export var max_hp: int = 1
@export var current_hp: int = 1
@export var temp_hp: int = 0

@export var nature: int = -1
@export var ability: String = ""
@export var known_moves: Array[String] = []
@export var learned_moves: Array[String] = []
@export var current_pp: Dictionary = {}
@export var held_item: String = ""

@export var stab: int = 1

## Pontos de Esforço (EVs). Máximo de 4 por atributo.
@export var evs: Dictionary = {
	Constants.Attribute.STR: 0, Constants.Attribute.DEX: 0,
	Constants.Attribute.CON: 0, Constants.Attribute.INT: 0,
	Constants.Attribute.WIS: 0, Constants.Attribute.CHA: 0
}

## Nível em que o Pokémon foi obtido. 1 = acompanha o treinador desde o início
## (progressão normal de EVs). Valores maiores redistribuem os EVs "perdidos"
## entre os níveis pares restantes (ver calc_ev_progression).
@export var capture_level: int = 1

## Valores Individuais (IVs). Variam de -2 a +2. (Serão rolados na criação de ovos).
@export var ivs: Dictionary = {
	Constants.Attribute.STR: 0, Constants.Attribute.DEX: 0,
	Constants.Attribute.CON: 0, Constants.Attribute.INT: 0,
	Constants.Attribute.WIS: 0, Constants.Attribute.CHA: 0
}

## Regras de EV
const EV_MAX_TOTAL := 10     # total de pontos ao longo da vida do Pokémon
const EV_MAX_PER_ATTR := 4   # máximo investido em um único atributo
const EV_MAX_LEVEL := 20     # nível em que o último ponto é recebido

const STAB_BONUS := {
	1: 1,  2: 1,  3: 1,  4: 1,
	5: 2,  6: 2,  7: 2,  8: 2,  9: 2,
	10: 3, 11: 3, 12: 3, 13: 3, 14: 3,
	15: 4, 16: 4, 17: 4, 18: 4, 19: 4,
	20: 5
}

var _species: PokemonSpecies

func setup(p_species_id: String, p_form: String = "", p_level: int = 1,
		p_nature: int = -1, p_ability: String = "") -> void:
	species_id = p_species_id
	form_name = p_form
	level = p_level
	nature = p_nature
	ability = p_ability
	_load_species()
	refresh_learnable_moves()
	recalculate()

func _load_species() -> void:
	_species = PokemonDB.get_species(species_id)
	if not _species:
		push_error("Espécie não encontrada: " + species_id)

func get_species() -> PokemonSpecies:
	if _species == null and not species_id.is_empty():
		_load_species()
	return _species

func get_form_data() -> Dictionary:
	var sp := get_species()
	if not sp: return {}
	return sp.get_form_data(form_name)

func get_ability() -> String:
	if not ability.is_empty():
		return ability
	var abilities: Array = get_form_data().get("abilities", [])
	if abilities.is_empty():
		return ""
	return String(abilities[0])

## Retorna o valor total (Base + Natureza + IV + EV).
func get_effective_attribute(attr: Constants.Attribute) -> int:
	if not get_species(): return 8
	
	# 1. Base da espécie
	var base_val: int = int(get_form_data().get("attributes", {}).get(attr, 8))
	
	# 2. Natureza (+2 / -2)
	if nature != -1:
		if Natures.get_plus(nature) == attr: base_val += 2
		if Natures.get_minus(nature) == attr: base_val -= 2
		
	# 3. IVs (-2 a +2)
	var iv_val = int(ivs.get(attr, 0))
	base_val += iv_val
	
	# 4. EVs (até 4)
	var ev_val = int(evs.get(attr, 0))
	base_val += ev_val
	
	return clampi(base_val, 1, 30)

func get_attribute_modifier(attr: Constants.Attribute) -> int:
	return Constants.get_attribute_modifier(get_effective_attribute(attr))

## Retorna o número total de EVs gastos.
func get_total_evs_spent() -> int:
	var total = 0
	for val in evs.values():
		total += int(val)
	return total

## Pontos de EV que o Pokémon recebe em cada nível par, de acordo com o nível de captura.
## Retorna { nível_par:int -> pontos:int }. Vazio se capturado no nível 20 ou acima:
## não há níveis restantes, então todos os 10 pontos ficam disponíveis na captura.
##
## Regra: os pontos dos níveis pares até o nível de captura (inclusive) são
## "perdidos" e divididos igualmente entre os níveis pares restantes. A sobra
## vai para os níveis mais altos, em ordem decrescente a partir do nível 20.
## Ex.: capturado no nível 8 -> perde 4 pontos; restam 10,12,14,16,18,20 ->
## { 10:1, 12:1, 14:2, 16:2, 18:2, 20:2 }.
static func calc_ev_progression(p_capture_level: int) -> Dictionary:
	var lost := 0
	var remaining: Array[int] = []
	for lvl in range(2, EV_MAX_LEVEL + 1, 2):
		if lvl <= p_capture_level:
			lost += 1
		else:
			remaining.append(lvl)

	var result := {}
	if remaining.is_empty():
		return result

	var base_extra := lost / remaining.size()
	var leftover := lost % remaining.size()
	for lvl in remaining:
		result[lvl] = 1 + base_extra
	for i in range(leftover):
		result[remaining[remaining.size() - 1 - i]] += 1
	return result

## Total de pontos de EV a que o Pokémon tem direito no nível atual.
func get_max_evs_allowed() -> int:
	# Capturado no nível 20: sem níveis restantes, os 10 pontos já estão disponíveis.
	if capture_level >= EV_MAX_LEVEL:
		return EV_MAX_TOTAL
	var total := 0
	var progression := calc_ev_progression(capture_level)
	for lvl in progression:
		if lvl <= level:
			total += int(progression[lvl])
	return mini(total, EV_MAX_TOTAL)

## Pontos de EV ainda não investidos. Devem ser investidos obrigatoriamente.
func get_unspent_evs() -> int:
	return maxi(get_max_evs_allowed() - get_total_evs_spent(), 0)


func get_armor_class() -> int:
	if not get_species(): return 10
	var base_ac: int = int(get_form_data().get("armor_class", 10))
	var nature_bonus: int = Natures.get_ac_bonus(nature) if nature != -1 else 0
	return base_ac + nature_bonus

func recalculate() -> void:
	if not get_species(): return
	var form_data := get_form_data()
	var con_mod := get_attribute_modifier(Constants.Attribute.CON)
	var hit_dice_max := int(form_data.get("hit_dice", "d6").replace("d", "").to_int())
	var hp_gain_per_level := (hit_dice_max / 2) + 1 + con_mod
	max_hp = hit_dice_max + con_mod + ((level - 1) * hp_gain_per_level)
	current_hp = clampi(current_hp, 0, max_hp) if current_hp > 0 else max_hp
	stab = STAB_BONUS.get(level, 1)

# ---------------------------------------------------------------------------
# Moves aprendíveis
# ---------------------------------------------------------------------------

func refresh_learnable_moves() -> void:
	var form_data := get_form_data()
	if form_data.is_empty(): return

	learned_moves.clear()

	for m in form_data.get("starting_moves", []):
		_add_normalized_move(m)

	for lvl in form_data.get("level_moves", {}):
		if int(lvl) <= level:
			for m in form_data["level_moves"][lvl]:
				_add_normalized_move(m)

	for m in form_data.get("tms", []):
		_add_normalized_move(m)

	for m in form_data.get("egg_moves", []):
		_add_normalized_move(m)

	if known_moves.is_empty():
		for i in range(mini(4, learned_moves.size())):
			known_moves.append(learned_moves[i])

	refresh_pp_from_moves()

## Retorna um dicionário com todos os moves disponíveis baseados nas restrições
func get_available_moves() -> Dictionary:
	var form_data := get_form_data()
	var available := {
		"level": [],
		"egg": [],
		"tm": []
	}
	
	for lvl in form_data.get("level_moves", {}):
		if int(lvl) <= level:
			for m in form_data["level_moves"][lvl]:
				var id := normalize_move_id(m)
				if id not in available["level"]:
					available["level"].append(id)
					
	for m in form_data.get("egg_moves", []):
		var id := normalize_move_id(m)
		if id not in available["egg"]:
			available["egg"].append(id)
			
	for m in form_data.get("tms", []):
		available["tm"].append(m) 
		
	return available

## Tenta aprender uma TM (número de 1 a 321). Retorna true se conseguiu.
func learn_tm(tm_number: int, slot_index: int = -1) -> bool:
	var form_data = get_form_data()
	var tm_string = "tm_" + str(tm_number)
	
	var can_learn = false
	for tm in form_data.get("tms", []):
		if String(tm) == tm_string or String(tm) == "tm_0" + str(tm_number):
			can_learn = true
			break
			
	if not can_learn:
		return false
		
	var move_id = TmData.get_move_id(tm_number)
	if move_id == "": return false
	
	if slot_index == -1:
		if known_moves.size() < 4:
			known_moves.append(move_id)
		else:
			return false
	else:
		if slot_index >= 0 and slot_index < known_moves.size():
			known_moves[slot_index] = move_id
		else:
			return false
			
	refresh_pp_from_moves()
	return true

func _add_normalized_move(raw_name: String) -> void:
	var id := normalize_move_id(raw_name)
	if not id.is_empty() and id not in learned_moves:
		learned_moves.append(id)

## Normaliza o nome do Move substituindo espaços e hifens por underline (_).
## Ex: "Double-Edge" -> "double_edge", "Water Shuriken" -> "water_shuriken"
static func normalize_move_id(raw: String) -> String:
	return raw.strip_edges().to_lower().replace(" ", "_").replace("-", "_").replace("'", "").replace(".", "")

# ---------------------------------------------------------------------------
# PP por Move
# ---------------------------------------------------------------------------

func refresh_pp_from_moves() -> void:
	for id in current_pp.keys():
		if id not in known_moves:
			current_pp.erase(id)

	for id in known_moves:
		if not current_pp.has(id):
			var max_pp := get_move_max_pp(id)
			current_pp[id] = max_pp

func get_move_max_pp(move_id: String) -> int:
	var move := PokemonDB.get_move(move_id)
	if move == null: return 0
	return move.pp

func get_move_current_pp(move_id: String) -> int:
	return int(current_pp.get(move_id, 0))

func get_known_moves_data() -> Array[MoveData]:
	var out: Array[MoveData] = []
	for id in known_moves:
		var move := PokemonDB.get_move(id)
		if move != null:
			out.append(move)
	return out

func spend_pp(move_id: String, amount: int = 1) -> bool:
	if amount <= 0: return true
	var current := get_move_current_pp(move_id)
	if current < amount: return false
	current_pp[move_id] = current - amount
	return true

func restore_pp(move_id: String, amount: int) -> void:
	if amount <= 0: return
	var max_pp := get_move_max_pp(move_id)
	var current := get_move_current_pp(move_id)
	current_pp[move_id] = mini(current + amount, max_pp)

func restore_all_pp_of_move(move_id: String) -> void:
	current_pp[move_id] = get_move_max_pp(move_id)

func restore_all_pp() -> void:
	for id in known_moves:
		current_pp[id] = get_move_max_pp(id)

func is_out_of_pp() -> bool:
	for id in known_moves:
		if get_move_current_pp(id) > 0: return false
	return true

# ---------------------------------------------------------------------------
# Nome e sprite
# ---------------------------------------------------------------------------

func get_display_name() -> String:
	if not nickname.is_empty(): return nickname
	var sp := get_species()
	var nm := sp.display_name if sp else species_id
	if not form_name.is_empty(): nm += " (" + form_name + ")"
	return nm

func get_sprite() -> Texture2D:
	return PokemonDB.get_sprite(species_id)

func get_full_info() -> Dictionary:
	var form_data := get_form_data()
	return {
		"name": get_display_name(), "species": species_id, "form": form_name,
		"level": level, "nature": Natures.get_display_name(nature) if nature != -1 else "—",
		"ability": get_ability(), "ac": get_armor_class(),
		"hp": [current_hp, max_hp], "pp_out": is_out_of_pp()
	}
