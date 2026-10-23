@tool
extends EditorScript

const INPUT_DIR = "res://data/json_moves/"
const OUTPUT_DIR := "res://data/moves/"

const TYPE_MAP := {
	"normal": Constants.PokemonType.NORMAL,
	"fire": Constants.PokemonType.FIRE,
	"water": Constants.PokemonType.WATER,
	"electric": Constants.PokemonType.ELECTRIC,
	"grass": Constants.PokemonType.GRASS,
	"ice": Constants.PokemonType.ICE,
	"fighting": Constants.PokemonType.FIGHTING,
	"poison": Constants.PokemonType.POISON,
	"ground": Constants.PokemonType.GROUND,
	"flying": Constants.PokemonType.FLYING,
	"psychic": Constants.PokemonType.PSYCHIC,
	"bug": Constants.PokemonType.BUG,
	"rock": Constants.PokemonType.ROCK,
	"ghost": Constants.PokemonType.GHOST,
	"dragon": Constants.PokemonType.DRAGON,
	"dark": Constants.PokemonType.DARK,
	"steel": Constants.PokemonType.STEEL,
	"fairy": Constants.PokemonType.FAIRY,
}

# Aceita tanto as siglas em inglês (campos "Move Power" / "Save" dos JSONs)
# quanto as siglas em português (texto das descrições: "teste de SAB").
const ATTR_MAP := {
	"STR": Constants.Attribute.STR,
	"DEX": Constants.Attribute.DEX,
	"CON": Constants.Attribute.CON,
	"INT": Constants.Attribute.INT,
	"WIS": Constants.Attribute.WIS,
	"CHA": Constants.Attribute.CHA,
	"FOR": Constants.Attribute.STR,
	"DES": Constants.Attribute.DEX,
	"SAB": Constants.Attribute.WIS,
	"CAR": Constants.Attribute.CHA,
}

# Moves que SÃO ataques com rolagem de acerto, mas vêm sem "atk": true no JSON
# (campo ausente ou false). Conferidos um a um na descrição.
const ATTACK_OVERRIDES := [
	"dragon_darts", "dual_wingbeat", "feint_attack", "twin_beam",
	"twineedle", "gear_grind", "aura_wheel",
]

# Tags de efeito sugeridas por regex na descrição (já em minúsculas).
# É heurística: serve de ponto de partida, revise na mão o que for importante.
const TAG_PATTERNS := {
	"drain": "metade do dano[^.]{0,80}(?:cura|convert)",
	"recoil": "recuo",
	"multi_hit": "faça (?:dois|duas|três|quatro|cinco|\\d+) ataques|ataques adicionais|múltiplos ataques",
	"ohko": "desmaiar instantaneamente|cai na fenda",
	"stat_change": "estágio",
	"protect": "evit(?:ar|a) automaticamente",
	"shield": "pv temporários",
	"weather": "air lock|outro clima",
	"terrain": "outro terreno",
	"hazard": "sempre que (?:uma )?criatura[^.]{0,60}(?:entra|passa|começa)",
	"copy": "execute completamente|move aleatório|você imita",
}
const HEAL_PATTERN := "recupera[^.]{0,40}pv|restaura[^.]{0,40}pv|cura[^.]{0,30}pv"
# Condições: ignoradas quando o texto diz "imunidade a ..." (ex.: Substitute).
const CONDITION_PATTERNS := {
	"paralysis": "paralisad|paralisia",
	"burn": "queimad|queimadura",
	"poison": "envenenad|envenenamento",
	"sleep": "adormecid|dormindo|sono",
	"freeze": "congelad|congelamento",
	"confusion": "confus",
	"flinch": "amedrontad|hesit",
	"grapple": "agarrad",
	"prone": "caído",
	"stun": "atordoad",
	"blind": "cego|cegueira",
}

var _rx_cache := {}
var _warnings := 0


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(OUTPUT_DIR)

	if not DirAccess.dir_exists_absolute(INPUT_DIR):
		push_error("Pasta de entrada não encontrada: " + INPUT_DIR)
		return

	var dir = DirAccess.open(INPUT_DIR)
	if not dir:
		push_error("Não foi possível abrir a pasta: " + INPUT_DIR)
		return

	var json_files: Array = Array(dir.get_files()).filter(func(f: String) -> bool:
		return f.ends_with(".json"))

	var imported := 0
	var by_resolution := {}
	_warnings = 0

	for file in json_files:
		var json_path = INPUT_DIR + file
		var data = _load_json(json_path)
		if data.is_empty():
			continue

		var move_id = file.get_basename().to_snake_case()
		var move := MoveData.new()

		move.id = move_id

		# --- Nome ---
		var raw_name := String(data.get("Name", file.get_basename()))
		raw_name = raw_name.replace(" PMP", "").strip_edges()
		move.display_name = raw_name
		var name_match := _rx("^(.*?)\\s*\\((.*)\\)\\s*$").search(raw_name)
		if name_match:
			move.name_en = name_match.get_string(1).strip_edges()
			move.name_pt = name_match.get_string(2).strip_edges()
		else:
			move.name_en = raw_name

		move.pp = int(data.get("PP", 5))
		move.move_time = String(data.get("Move Time", "1 ação"))
		move.description = String(data.get("Description", ""))
		move.scaling_text = String(data.get("Scaling", ""))

		var desc := _norm(move.description)
		var scaling := _norm(move.scaling_text)

		# --- Tipo ---
		var type_str := String(data.get("Type", "Normal")).to_lower()
		move.type = TYPE_MAP.get(type_str, Constants.PokemonType.NORMAL)
		move.type_is_variable = not TYPE_MAP.has(type_str)

		# --- Ativação (Move Time) ---
		var act := _parse_move_time(move.move_time)
		move.activation = act["activation"]
		move.needs_charge = act["needs_charge"]
		move.needs_recharge = act["needs_recharge"]

		# --- Alcance ---
		move.range_text_raw = String(data.get("Range", "Corpo a corpo"))
		var rng := _parse_range(move.range_text_raw)
		move.range_category = rng["category"]
		move.range_distance = rng["distance"]
		move.range_secondary = rng["secondary"]
		if rng["irregular"]:
			_warn(move_id, "Range fora do padrão: \"%s\" (confira)" % move.range_text_raw)
		if move.range_category in [MoveData.RangeCategory.RANGED,
				MoveData.RangeCategory.MELEE,
				MoveData.RangeCategory.MELEE_OR_RANGED]:
			move.target_area_radius = _parse_target_area_radius(desc)

		# --- Duração ---
		move.duration_text_raw = String(data.get("Duration", "Instantânea"))
		var dur := _parse_duration(move.duration_text_raw)
		move.duration_rounds = dur["rounds"]
		move.duration_is_permanent = dur["is_permanent"]
		# Conversão explícita: Array (não tipado) → Array[String]
		var flags: Array[String] = []
		for f in dur["flags"]:
			flags.append(String(f))
		move.duration_flags = flags
		# "carga" também aparece na Duração ("1 rodada, carga" / "carregar")
		if "charge" in flags:
			move.needs_charge = true
		if "recharge" in flags:
			move.needs_recharge = true

		# --- Atributos de Poder + modificador ---
		move.move_power_attributes.clear()
		move.move_power_modifier = 0
		var power_variant = data.get("Move Power")
		if power_variant is Dictionary:
			for key in power_variant:
				if ATTR_MAP.has(key):
					var attr = ATTR_MAP[key]
					if attr not in move.move_power_attributes:
						move.move_power_attributes.append(attr)
					var mod := int(power_variant[key])
					if mod != 0 and move.move_power_modifier == 0:
						move.move_power_modifier = mod
				elif key != "None":
					_warn(move_id, "Atributo desconhecido em Move Power: \"%s\"" % key)

		# --- Dados por nível (dano OU cura) ---
		move.damage_by_level.clear()
		var has_dice := false
		var dmg_variant = data.get("Damage")
		if dmg_variant is Dictionary and not dmg_variant.is_empty():
			has_dice = true
			for lvl_str in dmg_variant:
				var lvl_int = int(lvl_str)
				var dmg_entry: Dictionary = dmg_variant[lvl_str]
				move.damage_by_level[lvl_int] = {
					"amount": int(dmg_entry.get("amount", 1)),
					"dice_max": int(dmg_entry.get("dice_max", 4)),
					"move": bool(dmg_entry.get("move", false))
				}

		# --- Função: dano / cura / utilidade ---
		# Nos JSONs, moves de cura usam a mesma chave "Damage"; só o texto de
		# Scaling ("Os dados de cura...", "dano/cura") revela que é cura.
		if not has_dice:
			move.role = MoveData.Role.UTILITY
		elif "dano/cura" in scaling or "dano e cura" in scaling:
			move.role = MoveData.Role.DAMAGE_AND_HEAL
		elif "cura" in scaling and not ("dano" in scaling):
			move.role = MoveData.Role.HEAL
		else:
			move.role = MoveData.Role.DAMAGE
		move.has_damage = move.role == MoveData.Role.DAMAGE \
				or move.role == MoveData.Role.DAMAGE_AND_HEAL
		move.has_healing = move.role == MoveData.Role.HEAL \
				or move.role == MoveData.Role.DAMAGE_AND_HEAL

		# --- Resolução (ataque / save / rolagem de status / automático) ---
		var res := _parse_resolution(data, move_id, desc)
		move.is_attack = res["is_attack"]
		move.has_save = res["has_save"]
		move.save_attribute = res["save_attribute"]
		move.has_status_roll = res["has_status_roll"]
		move.status_roll_bonus = res["status_roll_bonus"]
		move.status_roll_target_attribute = res["status_roll_target_attribute"]
		move.resolution = res["resolution"]

		# --- Tags de efeito (heurística) ---
		move.effect_tags = _build_tags(desc, move.has_healing)

		# --- Salvar ---
		var out_path = OUTPUT_DIR + move_id + ".tres"
		var err = ResourceSaver.save(move, out_path)
		if err == OK:
			imported += 1
			var rname: String = MoveData.Resolution.keys()[move.resolution]
			by_resolution[rname] = int(by_resolution.get(rname, 0)) + 1
		else:
			push_error("Falha ao salvar %s: %s" % [out_path, error_string(err)])

	print("Importação de Moves concluída: %d Moves salvos (%d avisos)." % [imported, _warnings])
	print("Por resolução: ", by_resolution)


# ---------- Utilidades ----------

func _rx(pattern: String) -> RegEx:
	if not _rx_cache.has(pattern):
		var re := RegEx.new()
		var err := re.compile(pattern)
		if err != OK:
			push_error("Regex inválida: " + pattern)
		_rx_cache[pattern] = re
	return _rx_cache[pattern]

# minúsculas + espaços colapsados (os JSONs têm textos como "p ara", "  (4,5 metros)")
func _norm(text: String) -> String:
	return _rx("\\s+").sub(text.strip_edges().to_lower(), " ", true)

func _warn(move_id: String, msg: String) -> void:
	_warnings += 1
	push_warning("[%s] %s" % [move_id, msg])

func _extract_meters(t: String) -> float:
	# Extrai metros e pés (pés → metros: 1 ft ≈ 0,3 m)
	var m := _rx("([0-9]+(?:[.,][0-9]+)?)\\s*m(?:etros)?").search(t)
	if m:
		return m.get_string(1).replace(",", ".").to_float()
	var ft := _rx("([0-9]+(?:[.,][0-9]+)?)\\s*(?:ft|p[ée]s)").search(t)
	if ft:
		return ft.get_string(1).replace(",", ".").to_float() * 0.3
	return 0.0


# ---------- Parser: Move Time (ativação) ----------

func _parse_move_time(text: String) -> Dictionary:
	# Valores reais: "1 ação", "1 reação", "1 ação / reação", "1 reação / ação",
	# "1 ação bônus", "1 ação, recarga", "1 ação, carga" (+ variações de escrita)
	var t := _norm(text)
	var result := {
		"activation": MoveData.Activation.ACTION,
		"needs_charge": false,
		"needs_recharge": false,
	}
	if t.is_empty():
		return result

	# "recarga" contém "carga": checar recarga primeiro
	if "recarga" in t:
		result["needs_recharge"] = true
	elif "carga" in t or "carreg" in t:
		result["needs_charge"] = true

	if "bônus" in t or "bonus" in t:
		result["activation"] = MoveData.Activation.BONUS_ACTION
		return result

	# "reação" contém "ação": tirar "reaç" antes de procurar a ação
	var has_reaction := "reaç" in t
	var has_action := "aç" in t.replace("reaç", "")
	if has_reaction and has_action:
		result["activation"] = MoveData.Activation.ACTION_OR_REACTION
	elif has_reaction:
		result["activation"] = MoveData.Activation.REACTION
	return result


# ---------- Parser: Duration ----------

func _parse_duration(text: String) -> Dictionary:
	var t := _norm(text)
	var flags: Array[String] = []

	# Resultado padrão: Instantânea (0 rodadas), não permanente
	var result := {"rounds": 0, "is_permanent": false, "flags": flags}

	# 1. Se estiver vazio, é instantâneo
	if t.is_empty():
		return result

	# 2. Flags: concentração, carga ("carga"/"carregar"), recarga, variável
	if "concentra" in t:
		flags.append("concentration")
	if "recarga" in t:
		flags.append("recharge")
	elif "carga" in t or "carreg" in t:
		flags.append("charge")
	if "variável" in t or "variavel" in t or "variable" in t:
		flags.append("variable")

	# 3. "Até o início do próximo turno" → 1 rodada
	if "próximo turno" in t or "proximo turno" in t or "next turn" in t:
		result["rounds"] = 1
		return result

	# 4. Durações por estado: "Enquanto ativo", "Enquanto agarrado",
	#    "Até ser acionada", "Até que a criatura acorde" e combinações com
	#    "Instantânea, ..." (efeito instantâneo + estado persistente).
	if "enquanto" in t or "até" in t or "while" in t or "until" in t:
		result["is_permanent"] = true
		if not ("enquanto ativo" in t):
			flags.append("conditional") # termina por evento, não por "ficar ativo"
		return result

	# 5. Durações numéricas: "5 rodadas", "4 turnos", "2-3 rodadas" (usa o maior),
	#    "Instantânea, 3 rodadas."
	var m := _rx("([0-9]+)\\s*(?:-\\s*([0-9]+))?\\s*(?:rodadas?|rounds?|turnos?|turns?)").search(t)
	if m:
		var upper := m.get_string(2)
		result["rounds"] = int(upper) if not upper.is_empty() else int(m.get_string(1))
		return result

	# 6. "Variável", "Instantânea" e qualquer texto não mapeado: instantâneo
	return result


# ---------- Parser: Range (forma + distância) ----------

func _parse_range(text: String) -> Dictionary:
	var t := _norm(text)

	# Padrão: Corpo a corpo
	var result := {
		"category": MoveData.RangeCategory.MELEE,
		"distance": 1.5,
		"secondary": 0.0,
		"irregular": false,
	}

	if t.is_empty():
		return result

	# Textos fora do padrão que precisam de conferência manual
	result["irregular"] = "+" in t or ";" in t or "situacional" in t \
			or "deslocamento" in t \
			or ("corpo a corpo" in t and ("cone" in t or "linha" in t))

	# Textos dinâmicos ("Variável") não têm distância fixa
	if "variável" in t or "variavel" in t or "variable" in t:
		result["category"] = MoveData.RangeCategory.SPECIAL
		result["distance"] = 0.0
		return result

	var dist := _extract_meters(t)
	var is_melee := "corpo a corpo" in t
	var is_self := t.begins_with("pessoal") or t == "self"

	# A forma da área vem ANTES de "Pessoal": "Pessoal (cone de 12 metros)" é um
	# cone que sai do usuário, não um move apenas pessoal.
	if "cone" in t:
		result["category"] = MoveData.RangeCategory.CONE
		result["distance"] = dist
	elif "linha" in t:
		result["category"] = MoveData.RangeCategory.LINE
		result["distance"] = dist
	elif "raio" in t or "semicírculo" in t:
		result["category"] = MoveData.RangeCategory.RADIUS
		result["distance"] = dist
	elif is_self:
		if dist > 0.0:
			# "Pessoal / (6 metros)": em si mesmo ou em alguém a até 6 m
			result["category"] = MoveData.RangeCategory.SELF_OR_RANGED
			result["distance"] = dist
		else:
			result["category"] = MoveData.RangeCategory.SELF
			result["distance"] = 0.0
	elif is_melee:
		if dist > 0.0:
			# "Corpo a corpo (9 metros)" / "Corpo a corpo / (12 metros)"
			result["category"] = MoveData.RangeCategory.MELEE_OR_RANGED
			result["distance"] = dist
			result["secondary"] = 1.5
		else:
			result["category"] = MoveData.RangeCategory.MELEE
			result["distance"] = 1.5
	else:
		result["category"] = MoveData.RangeCategory.RANGED
		result["distance"] = dist

	return result


# Área circular centrada num ponto escolhido dentro do alcance. O JSON só diz
# isso na descrição: "...em um raio de 20 pés (6 metros), centrado em um ponto..."
func _parse_target_area_radius(desc: String) -> float:
	var m := _rx("raio de[^()]{0,20}\\(\\s*([0-9]+(?:[.,][0-9]+)?)\\s*metros?\\)[^.]{0,80}centrad[oa] em um ponto").search(desc)
	if m:
		return m.get_string(1).replace(",", ".").to_float()
	return 0.0


# ---------- Parser: Resolução ----------

func _parse_resolution(data: Dictionary, move_id: String, desc: String) -> Dictionary:
	var out := {
		"is_attack": false,
		"has_save": false,
		"save_attribute": Constants.Attribute.DEX,
		"has_status_roll": false,
		"status_roll_bonus": 0,
		"status_roll_target_attribute": Constants.Attribute.WIS,
		"resolution": MoveData.Resolution.AUTOMATIC,
	}

	# Ataque: "atk" (ou "Atk", que aparece em Shadow Punch) + correções manuais
	out["is_attack"] = bool(data.get("atk", false)) or bool(data.get("Atk", false)) \
			or ATTACK_OVERRIDES.has(move_id)

	# Save: campo "Save" do JSON; se ausente, tenta achar "teste de XXX contra a CD"
	var save_key := String(data.get("Save", "")).to_upper()
	if ATTR_MAP.has(save_key):
		out["has_save"] = true
		out["save_attribute"] = ATTR_MAP[save_key]
	else:
		var ms := _rx("teste de (for|des|con|int|sab|car)\\w*[^.]{0,40}?(?:cd|contra)").search(desc)
		if ms:
			out["has_save"] = true
			out["save_attribute"] = ATTR_MAP[ms.get_string(1).to_upper()]

	# Rolagem de status: "Role 1d20 + MOVE + 9 e compare com 10 + SAB do alvo"
	var mr := _rx("1d20\\s*\\+\\s*move\\s*(?:([+-])\\s*(\\d+))?\\s*e compare[^.]{0,60}?10\\s*\\+\\s*(for|des|con|int|sab|car)").search(desc)
	if mr:
		out["has_status_roll"] = true
		var bonus := int(mr.get_string(2)) if not mr.get_string(2).is_empty() else 0
		if mr.get_string(1) == "-":
			bonus = -bonus
		out["status_roll_bonus"] = bonus
		out["status_roll_target_attribute"] = ATTR_MAP[mr.get_string(3).to_upper()]

	# Resolução principal (prioridade: ataque+save > ataque > save > status > auto)
	if out["is_attack"] and out["has_save"]:
		out["resolution"] = MoveData.Resolution.ATTACK_AND_SAVE
	elif out["is_attack"]:
		out["resolution"] = MoveData.Resolution.ATTACK_ROLL
	elif out["has_save"]:
		out["resolution"] = MoveData.Resolution.SAVE
	elif out["has_status_roll"]:
		out["resolution"] = MoveData.Resolution.STATUS_ROLL
	return out


# ---------- Tags de efeito (heurística) ----------

func _build_tags(desc: String, has_healing: bool) -> Array[String]:
	var tags: Array[String] = []
	if has_healing or _rx(HEAL_PATTERN).search(desc):
		tags.append("heal")
	for tag in TAG_PATTERNS:
		if _rx(TAG_PATTERNS[tag]).search(desc):
			tags.append(tag)
	if not ("imunidade a" in desc):
		for tag in CONDITION_PATTERNS:
			if _rx(CONDITION_PATTERNS[tag]).search(desc):
				tags.append(tag)
	return tags


func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Arquivo JSON não encontrado: " + path)
		return {}
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
	var content = file.get_as_text()
	file.close()
	# Alguns JSONs (Crafty Shield, Feint, Nihil Light) têm quebras de linha
	# literais dentro de strings, o que é JSON inválido. Trocar por espaço é
	# seguro: fora de strings já era espaço em branco.
	content = content.replace("\r", " ").replace("\n", " ").replace("\t", " ")
	var json = JSON.new()
	var err = json.parse(content)
	if err != OK:
		push_error("Erro ao fazer parse do JSON %s: %s" % [path, json.get_error_message()])
		return {}
	if not (json.data is Dictionary):
		return {}
	return json.data
