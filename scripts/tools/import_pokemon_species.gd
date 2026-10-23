@tool
extends EditorScript

const INPUT_DIR = "res://data/json_pokemons/"
const OUTPUT_DIR = "res://data/pokemon/"
const EVOLVE_MAP_PATH = "res://data/json/evolve.json"

const TYPE_MAP := {
	"normal": Constants.PokemonType.NORMAL,
	"fogo": Constants.PokemonType.FIRE, "fire": Constants.PokemonType.FIRE,
	"agua": Constants.PokemonType.WATER, "water": Constants.PokemonType.WATER,
	"eletrico": Constants.PokemonType.ELECTRIC, "electric": Constants.PokemonType.ELECTRIC,
	"grama": Constants.PokemonType.GRASS, "planta": Constants.PokemonType.GRASS,
	"grass": Constants.PokemonType.GRASS,
	"gelo": Constants.PokemonType.ICE, "ice": Constants.PokemonType.ICE,
	"lutador": Constants.PokemonType.FIGHTING, "luta": Constants.PokemonType.FIGHTING,
	"fighting": Constants.PokemonType.FIGHTING,
	"venenoso": Constants.PokemonType.POISON, "veneno": Constants.PokemonType.POISON,
	"poison": Constants.PokemonType.POISON,
	"terra": Constants.PokemonType.GROUND, "terrestre": Constants.PokemonType.GROUND,
	"ground": Constants.PokemonType.GROUND,
	"voador": Constants.PokemonType.FLYING, "flying": Constants.PokemonType.FLYING,
	"psiquico": Constants.PokemonType.PSYCHIC, "psychic": Constants.PokemonType.PSYCHIC,
	"inseto": Constants.PokemonType.BUG, "bug": Constants.PokemonType.BUG,
	"pedra": Constants.PokemonType.ROCK, "rock": Constants.PokemonType.ROCK,
	"fantasma": Constants.PokemonType.GHOST, "ghost": Constants.PokemonType.GHOST,
	"dragao": Constants.PokemonType.DRAGON, "dragon": Constants.PokemonType.DRAGON,
	"sombrio": Constants.PokemonType.DARK, "noturno": Constants.PokemonType.DARK,
	"dark": Constants.PokemonType.DARK,
	"aco": Constants.PokemonType.STEEL, "steel": Constants.PokemonType.STEEL,
	"fada": Constants.PokemonType.FAIRY, "fairy": Constants.PokemonType.FAIRY,
}

const ACCENTS := {
	"á": "a", "à": "a", "â": "a", "ã": "a", "ä": "a", "é": "e", "è": "e", "ê": "e", "ë": "e",
	"í": "i", "ì": "i", "î": "i", "ï": "i", "ó": "o", "ò": "o", "ô": "o", "õ": "o", "ö": "o",
	"ú": "u", "ù": "u", "û": "u", "ü": "u", "ç": "c", "ñ": "n",
}

const SKILL_MAP := {
	"Acrobatics": Constants.Skill.ACROBACIA, "Athletics": Constants.Skill.ATLETISMO,
	"Nature": Constants.Skill.NATUREZA, "Deception": Constants.Skill.ENGANACAO,
	"Insight": Constants.Skill.INTUICAO, "Perception": Constants.Skill.PERCEPCAO,
	"Persuasion": Constants.Skill.PERSUASAO, "Stealth": Constants.Skill.FURTIVIDADE,
	"Animal Handling": Constants.Skill.ADESTRAR_ANIMAIS, "Arcana": Constants.Skill.ARCANISMO,
	"History": Constants.Skill.HISTORIA, "Investigation": Constants.Skill.INVESTIGACAO,
	"Medicine": Constants.Skill.MEDICINA, "Religion": Constants.Skill.RELIGIAO,
	"Survival": Constants.Skill.SOBREVIVENCIA, "Intimidation": Constants.Skill.INTIMIDACAO,
	"Performance": Constants.Skill.ATUACAO, "Sleight of Hand": Constants.Skill.PRESTIDIGITACAO
}

const SR_FRACTIONS := {0.125: "1/8", 0.25: "1/4", 0.5: "1/2"}

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(OUTPUT_DIR)

	if not FileAccess.file_exists(EVOLVE_MAP_PATH):
		push_error("evolve.json não encontrado em: " + EVOLVE_MAP_PATH)
		return

	if not DirAccess.dir_exists_absolute(INPUT_DIR):
		push_error("Pasta de entrada não encontrada: " + INPUT_DIR)
		return

	var evolve_by_name := {}
	var evolve_raw := _load_json(EVOLVE_MAP_PATH)
	for evo_key in evolve_raw:
		evolve_by_name[_norm(evo_key)] = evolve_raw[evo_key]

	var dir = DirAccess.open(INPUT_DIR)
	if not dir:
		push_error("Não foi possível abrir a pasta: " + INPUT_DIR)
		return

	var json_files: Array = Array(dir.get_files()).filter(func(f: String) -> bool:
		return f.ends_with(".json"))
	var name_to_id := {}
	for file in json_files:
		name_to_id[_norm(file.get_basename())] = file.get_basename().to_snake_case()

	var imported := 0
	var without_types: Array[String] = []
	for file in json_files:
		var json_path = INPUT_DIR + file
		var data = _load_json(json_path)
		if data.is_empty():
			continue

		var species_id = file.get_basename().to_snake_case()
		var species = PokemonSpecies.new()

		species.id = species_id
		species.dex_number = int(data.get("index", 0))
		species.display_name = file.get_basename()

		species.types.clear()
		for t in _parse_types(data.get("Type", data.get("Types", [])), file):
			species.types.append(t)
		if species.types.is_empty():
			without_types.append(file)

		var sr_val := float(data.get("SR", 0))
		species.sr = SR_FRACTIONS.get(sr_val, str(int(sr_val)))

		species.armor_class = int(data.get("AC", 10))
		species.hit_points = int(data.get("HP", 1))
		species.hit_dice = "d" + str(int(data.get("Hit Dice", 6)))
		species.min_level = int(data.get("MIN LVL FD", 1))

		var size_str: String = data.get("size", "")
		var regex_size := RegEx.new()
		regex_size.compile("([A-Za-zÀ-ÿ]+)\\s*\\(([0-9,.]+)\\s*m\\)")
		var match_size = regex_size.search(size_str)
		if match_size:
			species.size_category = match_size.get_string(1).to_lower()
			species.size_meters = match_size.get_string(2).replace(",", ".").to_float()

		var attrs: Dictionary = data.get("attributes", {})
		for k in attrs:
			match k:
				"STR": species.attributes[Constants.Attribute.STR] = int(attrs[k])
				"DEX": species.attributes[Constants.Attribute.DEX] = int(attrs[k])
				"CON": species.attributes[Constants.Attribute.CON] = int(attrs[k])
				"INT": species.attributes[Constants.Attribute.INT] = int(attrs[k])
				"WIS": species.attributes[Constants.Attribute.WIS] = int(attrs[k])
				"CHA": species.attributes[Constants.Attribute.CHA] = int(attrs[k])

		species.skills.clear()
		for s in data.get("Skill", []):
			if SKILL_MAP.has(s):
				species.skills.append(SKILL_MAP[s])

		species.movement.clear()
		_apply_movement(species.movement, data)

		species.senses.clear()
		for s in data.get("Senses", []):
			var sense_dict := _parse_sense(s)
			if sense_dict.get("type", -1) != -1:
				species.senses.append(sense_dict)

		species.abilities.clear()
		for a in data.get("Abilities", []):
			species.abilities.append(String(a))
		species.hidden_ability = String(data.get("Hidden Ability", ""))

		species.level_moves.clear()
		var moves_data: Dictionary = data.get("Moves", {})
		_apply_moves(species, moves_data)

		_apply_evolution(species, data, evolve_by_name.get(_norm(species.display_name), {}),
				name_to_id, file)

		# ---------- Variantes ----------
		species.is_variant = false
		species.variant_data.clear()
		if data.has("variant_data"):
			species.is_variant = true
			_import_variants(species, data, file)

		var out_path = OUTPUT_DIR + species_id + ".tres"
		var err = ResourceSaver.save(species, out_path)
		if err == OK:
			imported += 1
		else:
			push_error("Falha ao salvar %s: %s" % [out_path, error_string(err)])

	print("Importação concluída: %d espécies salvas." % imported)
	if not without_types.is_empty():
		push_warning("%d espécies ficaram SEM tipo: %s" % [without_types.size(), without_types])


# ---------- Variantes ----------

## Importa variant_data do JSON para o formato que PokemonSpecies._apply_diff()
## entende. Cada variante é armazenada como {"display_name", "diff"} e o
## `diff` é normalizado: as chaves crus do JSON ("Abilities", "Type", "Moves",
## "Senses", etc.) são convertidas para as chaves normalizadas usadas no
## form_data ("abilities", "types", "level_moves", "senses", etc.).
##
## Regras:
##   - `variants[default]` normalmente não tem `diff` → é a forma base, sem overrides.
##   - Se o `diff` de uma variante tiver "Moves", ele pode conter "Level",
##     "Starting Moves", "TM", "egg" — todos mesclados/substituídos conforme a regra
##     de PokemonSpecies._apply_diff().
##   - Se o `diff` NÃO tiver uma chave, o campo herda do base (comportamento do _apply_diff).
func _import_variants(species: PokemonSpecies, data: Dictionary, source: String) -> void:
	var vd: Dictionary = data["variant_data"]
	var variants: Dictionary = vd.get("variants", {})
	var default_key: String = String(vd.get("default", ""))

	for var_key in variants:
		var raw: Dictionary = variants[var_key]
		var display_name := String(raw.get("display", var_key))

		# A variante "default" (Greninja, Raticate) é a própria forma base.
		# Só guardamos ela se tiver um `diff` de fato (raro, mas possível).
		var raw_diff: Dictionary = raw.get("diff", {})
		var normalized := {}
		if not raw_diff.is_empty():
			normalized = _normalize_variant_diff(raw_diff, "%s / %s" % [source, var_key])

		species.variant_data[var_key] = {
			"display_name": display_name,
			"diff": normalized,
			"is_default": var_key == default_key,
		}


## Converte um `diff` cru (formato JSON) para o formato do `form_data`
## que PokemonSpecies._apply_diff() sabe aplicar.
func _normalize_variant_diff(raw: Dictionary, source: String) -> Dictionary:
	var out := {}

	# Grupos de chaves que são tratados juntas
	var movement_keys := ["WSp", "FSp", "SwSp", "Ssp", "ClSp",
			"Climbing Speed", "Swimming Speed", "Flying Speed"]

	for key in raw:
		if key in movement_keys:
			if not out.has("movement"):
				out["movement"] = {}
			_apply_movement(out["movement"], {key: raw[key]})
			continue

		match key:
			"Type", "Types":
				out["types"] = _parse_types(raw[key], source)
			"Abilities":
				var abs_arr: Array = []
				for a in raw[key]:
					abs_arr.append(String(a))
				out["abilities"] = abs_arr
			"Hidden Ability":
				out["hidden_ability"] = String(raw[key])
			"MIN LVL FD":
				out["min_level"] = int(raw[key])
			"AC":
				out["armor_class"] = int(raw[key])
			"HP":
				out["hit_points"] = int(raw[key])
			"Hit Dice":
				out["hit_dice"] = "d" + str(int(raw[key]))
			"SR":
				out["sr"] = SR_FRACTIONS.get(float(raw[key]), str(int(raw[key])))
			"attributes":
				var attrs := {}
				for k in raw[key]:
					attrs[k] = int(raw[key][k])
				out["attributes"] = attrs
			"Skill":
				var skills: Array = []
				for s in raw[key]:
					if SKILL_MAP.has(s):
						skills.append(SKILL_MAP[s])
				out["skills"] = skills
			"Senses":
				var senses: Array = []
				for s in raw[key]:
					var sense_dict := _parse_sense(s)
					if sense_dict.get("type", -1) != -1:
						senses.append(sense_dict)
				out["senses"] = senses
			"Moves":
				out["moves_diff"] = _normalize_variant_moves(raw[key])
			"size":
				var size_str := String(raw[key])
				var re := RegEx.new()
				re.compile("([A-Za-zÀ-ÿ]+)\\s*\\(([0-9,.]+)\\s*m\\)")
				var m = re.search(size_str)
				if m:
					out["size_meters"] = m.get_string(2).replace(",", ".").to_float()
			_:
				# Chave já normalizada (ex.: de um JSON antigo) → repassa como está.
				out[key] = raw[key]

	return out

## Normaliza o bloco "Moves" de uma variante. Diferente do Pokémon base,
## o `Moves` da variante pode trazer "Level", "Starting Moves", "TM" e "egg"
## diretamente no nível de `Moves` (sem o wrapper `Moves.Starting Moves`).
## Retornamos sempre no formato {"level_moves", "starting_moves", "tms", "egg_moves"},
## e só as chaves PRESENTES — o que não está presente herda do base via _apply_diff.
func _normalize_variant_moves(raw_moves: Dictionary) -> Dictionary:
	var out := {}

	if raw_moves.has("Level"):
		var lv: Dictionary = raw_moves["Level"]
		var lv_out := {}
		for lvl in lv:
			var arr: Array = []
			for m in lv[lvl]:
				arr.append(String(m))
			lv_out[int(lvl)] = arr
		out["level_moves"] = lv_out

	# Aceita tanto "Starting Moves" direto quanto dentro de "Moves.Starting Moves"
	if raw_moves.has("Starting Moves"):
		var sm: Array = []
		for m in raw_moves["Starting Moves"]:
			sm.append(String(m))
		out["starting_moves"] = sm

	if raw_moves.has("TM"):
		var tms: Array = []
		for tm in raw_moves["TM"]:
			tms.append("tm_" + str(int(tm)))
		out["tms"] = tms

	if raw_moves.has("egg"):
		var eggs: Array = []
		for em in raw_moves["egg"]:
			eggs.append(String(em))
		out["egg_moves"] = eggs

	return out


# ---------- Helpers reutilizáveis ----------

## Aplica movimento de um dicionário cru (JSON) num `movement` de PokemonSpecies.
## Aceita tanto as chaves abreviadas do JSON principal ("WSp", "FSp", "SwSp",
## "ClSp") quanto nomes por extenso ("Climbing Speed", "Swimming Speed", etc.).
func _apply_movement(movement: Dictionary, src: Dictionary) -> void:
	if src.has("WSp"):
		movement[Constants.Movement.WALKING] = float(src["WSp"]) * 0.3
	if src.has("FSp") or src.has("Flying Speed"):
		movement[Constants.Movement.FLYING] = float(src.get("FSp", src.get("Flying Speed", 0))) * 0.3
	if src.has("SwSp") or src.has("Ssp") or src.has("Swimming Speed"):
		var v = src.get("SwSp", src.get("Ssp", src.get("Swimming Speed", 0)))
		movement[Constants.Movement.SWIMMING] = float(v) * 0.3
	if src.has("ClSp") or src.has("Climbing Speed"):
		var v = src.get("ClSp", src.get("Climbing Speed", 0))
		movement[Constants.Movement.CLIMBING] = float(v) * 0.3


func _apply_moves(species: PokemonSpecies, moves_data: Dictionary) -> void:
	for lvl in moves_data.get("Level", {}):
		var level_int: int = int(lvl)
		var moves_arr: Array = []
		for m in moves_data["Level"][lvl]:
			moves_arr.append(String(m))
		species.level_moves[level_int] = moves_arr

	species.starting_moves.clear()
	for m in moves_data.get("Starting Moves", []):
		species.starting_moves.append(String(m))

	species.tms.clear()
	for tm in moves_data.get("TM", []):
		species.tms.append("tm_" + str(int(tm)))

	species.egg_moves.clear()
	for em in moves_data.get("egg", []):
		species.egg_moves.append(String(em))


func _parse_sense(s: String) -> Dictionary:
	var sense_dict := {"type": -1, "range_m": 0.0}
	var range_val := 0
	if "Darkvision" in s:
		sense_dict["type"] = Constants.Senses.DARK
		range_val = _extract_ft(s)
	elif "Blindsight" in s:
		sense_dict["type"] = Constants.Senses.SONAR
		range_val = _extract_ft(s)
	elif "Tremorsense" in s:
		sense_dict["type"] = Constants.Senses.SEISMIC
		range_val = _extract_ft(s)
	elif "Truesight" in s:
		sense_dict["type"] = Constants.Senses.TRUE
		range_val = _extract_ft(s)
	if sense_dict["type"] != -1:
		sense_dict["range_m"] = range_val * 0.3
	return sense_dict


func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Arquivo JSON não encontrado: " + path)
		return {}
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
	var content = file.get_as_text()
	file.close()
	var json = JSON.new()
	var err = json.parse(content)
	if err != OK:
		push_error("Erro ao fazer parse do JSON %s: %s" % [path, json.get_error_message()])
		return {}
	return json.data


func _extract_ft(s: String) -> int:
	var regex := RegEx.new()
	regex.compile("(\\d+)\\s*ft")
	var m = regex.search(s)
	if m:
		return int(m.get_string(1))
	return 0


func _norm(text: String) -> String:
	var out := ""
	for ch in text.to_lower():
		out += ACCENTS.get(ch, ch)
	var re := RegEx.new()
	re.compile("[^a-z0-9]")
	return re.sub(out, "", true)


func _parse_types(value, source: String) -> Array:
	var out: Array = []
	var word_re := RegEx.new()
	word_re.compile("[A-Za-zÀ-ÿ]+")
	for part in (value if value is Array else [value]):
		for m in word_re.search_all(str(part)):
			var word := m.get_string()
			var key := _norm(word)
			if not TYPE_MAP.has(key):
				push_warning("Tipo desconhecido '%s' em %s" % [word, source])
			elif TYPE_MAP[key] not in out:
				out.append(TYPE_MAP[key])
	return out


func _apply_evolution(species: PokemonSpecies, data: Dictionary, evo: Dictionary,
		name_to_id: Dictionary, source: String) -> void:
	if evo.is_empty():
		push_warning("%s: nome não encontrado no evolve.json (usando só o campo Evolve)." % source)
	species.evolves_to.clear()
	species.evolution_level = -1
	species.evolution_stage = int(evo.get("current_stage", 0))
	species.evolution_points = int(evo.get("points", 0))

	var targets: Array = evo.get("into", [])
	if targets.is_empty():
		var raw = data.get("Evolve", "")
		targets = raw if raw is Array else ([raw] if str(raw) != "" else [])

	for target in targets:
		var target_id: String = name_to_id.get(_norm(str(target)), "")
		if target_id.is_empty():
			push_warning("%s evolui para '%s', que não tem JSON na pasta de entrada." % [source, target])
			target_id = str(target).to_snake_case()
		if target_id not in species.evolves_to:
			species.evolves_to.append(target_id)

	if not species.evolves_to.is_empty() and evo.has("level"):
		species.evolution_level = int(evo["level"])
