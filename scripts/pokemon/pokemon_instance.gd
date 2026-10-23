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
## Habilidade passiva escolhida (String vazia = usar a primeira do form_data).
@export var ability: String = ""
## Moves conhecidos (até 4 normalmente, mais se tiver Move Extra etc.).
## Guarda os IDs normalizados (ex: "water_shuriken"), não os nomes bonitos.
@export var known_moves: Array[String] = []
## Todos os Moves aprendíveis no nível atual (IDs normalizados).
@export var learned_moves: Array[String] = []
## PP atual de cada Move conhecido. Chave = id do Move; valor = int.
## Populado por refresh_pp_from_moves() sempre que known_moves muda.
@export var current_pp: Dictionary = {}
@export var held_item: String = ""

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

## Retorna a habilidade passiva efetiva: a escolhida, ou a primeira disponível.
func get_ability() -> String:
	if not ability.is_empty():
		return ability
	var abilities: Array = get_form_data().get("abilities", [])
	if abilities.is_empty():
		return ""
	return String(abilities[0])

func get_effective_attribute(attr: Constants.Attribute) -> int:
	if not get_species(): return 8
	var base_val: int = get_form_data().get("attributes", {}).get(attr, 8)
	if nature != -1:
		if Natures.get_plus(nature) == attr:
			base_val += 2
		if Natures.get_minus(nature) == attr:
			base_val -= 2
	return clampi(base_val, 1, 30)

func get_attribute_modifier(attr: Constants.Attribute) -> int:
	return Constants.get_attribute_modifier(get_effective_attribute(attr))

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

# ---------------------------------------------------------------------------
# Moves aprendíveis
# ---------------------------------------------------------------------------

## Popula `learned_moves` com os IDs normalizados de todos os Moves
## disponíveis no nível atual (Starting + Level + TM + Egg).
## Se `known_moves` estiver vazio, escolhe os 4 primeiros como padrão.
## Também chama `refresh_pp_from_moves()` para alinhar o PP.
func refresh_learnable_moves() -> void:
	var form_data := get_form_data()
	if form_data.is_empty(): return

	learned_moves.clear()

	# Starting Moves
	for m in form_data.get("starting_moves", []):
		_add_normalized_move(m)

	# Level Moves até o nível atual
	for lvl in form_data.get("level_moves", {}):
		if int(lvl) <= level:
			for m in form_data["level_moves"][lvl]:
				_add_normalized_move(m)

	# TMs (já vêm como "tm_N" do importador — o catálogo trata depois)
	for m in form_data.get("tms", []):
		_add_normalized_move(m)

	# Egg Moves
	for m in form_data.get("egg_moves", []):
		_add_normalized_move(m)

	# Se o jogador ainda não escolheu os moves, pega os 4 primeiros
	if known_moves.is_empty():
		for i in range(mini(4, learned_moves.size())):
			known_moves.append(learned_moves[i])

	refresh_pp_from_moves()

## Normaliza um nome de Move (ex: "Water Shuriken" → "water_shuriken")
## e adiciona em `learned_moves` se ainda não estiver.
func _add_normalized_move(raw_name: String) -> void:
	var id := normalize_move_id(raw_name)
	if not id.is_empty() and id not in learned_moves:
		learned_moves.append(id)

## Normaliza um nome/ID de Move para a chave usada pelo PokemonDB.
static func normalize_move_id(raw: String) -> String:
	return raw.strip_edges().to_lower().replace(" ", "_").replace("'", "").replace(".", "")

# ---------------------------------------------------------------------------
# PP por Move
# ---------------------------------------------------------------------------

## Garante que `current_pp` tenha uma entrada para cada Move conhecido.
## Moves novos começam com PP máximo; Moves removidos são apagados.
## Moves que já existiam mantêm o PP atual (não reseta).
func refresh_pp_from_moves() -> void:
	# Remove PP de moves que não são mais conhecidos
	for id in current_pp.keys():
		if id not in known_moves:
			current_pp.erase(id)

	# Adiciona PP máximo para moves novos
	for id in known_moves:
		if not current_pp.has(id):
			var max_pp := get_move_max_pp(id)
			current_pp[id] = max_pp

## Retorna o PP máximo de um Move, ou 0 se o Move não for encontrado.
func get_move_max_pp(move_id: String) -> int:
	var move := PokemonDB.get_move(move_id)
	if move == null:
		push_warning("Move não encontrado no DB: " + move_id)
		return 0
	return move.pp

## Retorna o PP atual do Move (0 se não conhecido).
func get_move_current_pp(move_id: String) -> int:
	return int(current_pp.get(move_id, 0))

## Retorna um dicionário com todos os Moves como recursos MoveData.
## Útil para a futura UI (ficha do Pokémon).
func get_known_moves_data() -> Array[MoveData]:
	var out: Array[MoveData] = []
	for id in known_moves:
		var move := PokemonDB.get_move(id)
		if move != null:
			out.append(move)
	return out

## Tenta gastar `amount` PP de um Move. Retorna true se conseguiu.
## Não deixa o PP ficar negativo.
func spend_pp(move_id: String, amount: int = 1) -> bool:
	if amount <= 0:
		return true
	var current := get_move_current_pp(move_id)
	if current < amount:
		return false
	current_pp[move_id] = current - amount
	return true

## Recupera `amount` PP de um Move, limitado ao máximo.
func restore_pp(move_id: String, amount: int) -> void:
	if amount <= 0:
		return
	var max_pp := get_move_max_pp(move_id)
	var current := get_move_current_pp(move_id)
	current_pp[move_id] = mini(current + amount, max_pp)

## Restaura todo o PP de um único Move.
func restore_all_pp_of_move(move_id: String) -> void:
	current_pp[move_id] = get_move_max_pp(move_id)

## Restaura todo o PP de todos os Moves conhecidos (descanso longo, Centro Pokémon).
func restore_all_pp() -> void:
	for id in known_moves:
		current_pp[id] = get_move_max_pp(id)

## Verdadeiro se o Pokémon não tem PP em nenhum Move conhecido
## (Struggle é sempre possível, então a UI pode usar isso para avisar).
func is_out_of_pp() -> bool:
	for id in known_moves:
		if get_move_current_pp(id) > 0:
			return false
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
		"name": get_display_name(),
		"species": species_id,
		"form": form_name,
		"level": level,
		"nature": Natures.get_display_name(nature) if nature != -1 else "—",
		"ability": get_ability(),
		"ac": get_armor_class(),
		"hp": [current_hp, max_hp],
		"pp_out": is_out_of_pp(),
	}
