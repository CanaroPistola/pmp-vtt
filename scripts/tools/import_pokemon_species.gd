@tool
extends EditorScript
## Importa um JSON de espécies de Pokémon para res://data/pokemon_species/<id>.tres
##
## Uso:
##   1. Coloque seu JSON em res://data/pokemon_species.json
##   2. Abra este script no editor, clique em "File > Run" (ou Ctrl+Shift+X)
##   3. Os .tres são gerados em res://data/pokemon_species/
##
## O JSON deve ser um ARRAY de objetos no formato do Bulbasaur que você mandou.

const INPUT_JSON := "res://data/pokemon_species.json"
const OUTPUT_DIR := "res://data/pokemon_species/"

# Mapeamentos de string do JSON -> enum.
# O JSON usa "Constants.Attributes.X" e "Constants.Skills.X" (plural);
# nosso Constants usa singular. Normalizamos aqui.
const ATTR_FROM_JSON := {
	"Constants.Attributes.STR": Constants.Attribute.STR,
	"Constants.Attributes.DEX": Constants.Attribute.DEX,
	"Constants.Attributes.CON": Constants.Attribute.CON,
	"Constants.Attributes.INT": Constants.Attribute.INT,
	"Constants.Attributes.WIS": Constants.Attribute.WIS,
	"Constants.Attributes.CHA": Constants.Attribute.CHA,
}
const SKILL_FROM_JSON := {
	"Constants.Skills.ACROBACIA": Constants.Skill.ACROBACIA,
	"Constants.Skills.ADESTRAR_ANIMAIS": Constants.Skill.ADESTRAR_ANIMAIS,
	"Constants.Skills.ARCANISMO": Constants.Skill.ARCANISMO,
	"Constants.Skills.ATLETISMO": Constants.Skill.ATLETISMO,
	"Constants.Skills.ATUACAO": Constants.Skill.ATUACAO,
	"Constants.Skills.ENGANACAO": Constants.Skill.ENGANACAO,
	"Constants.Skills.FURTIVIDADE": Constants.Skill.FURTIVIDADE,
	"Constants.Skills.HISTORIA": Constants.Skill.HISTORIA,
	"Constants.Skills.INTIMIDACAO": Constants.Skill.INTIMIDACAO,
	"Constants.Skills.INTUICAO": Constants.Skill.INTUICAO,
	"Constants.Skills.INVESTIGACAO": Constants.Skill.INVESTIGACAO,
	"Constants.Skills.MEDICINA": Constants.Skill.MEDICINA,
	"Constants.Skills.NATUREZA": Constants.Skill.NATUREZA,
	"Constants.Skills.PERCEPCAO": Constants.Skill.PERCEPCAO,
	"Constants.Skills.PERSUASAO": Constants.Skill.PERSUASAO,
	"Constants.Skills.PRESTIDIGITACAO": Constants.Skill.PRESTIDIGITACAO,
	"Constants.Skills.RELIGIAO": Constants.Skill.RELIGIAO,
	"Constants.Skills.SOBREVIVENCIA": Constants.Skill.SOBREVIVENCIA,
}
const MOVEMENT_FROM_JSON := {
	"Constants.Movement.WALKING": Constants.Movement.WALKING,
	"Constants.Movement.SWIMMING": Constants.Movement.SWIMMING,
	"Constants.Movement.CLIMBING": Constants.Movement.CLIMBING,
	"Constants.Movement.FLYING": Constants.Movement.FLYING,
}


func _run() -> void:
	print("=== Importando espécies de Pokémon ===")
	if not FileAccess.file_exists(INPUT_JSON):
		push_error("JSON não encontrado: %s" % INPUT_JSON)
		return

	var file := FileAccess.open(INPUT_JSON, FileAccess.READ)
	var raw := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_ARRAY:
		push_error("JSON inválido: esperado um array na raiz.")
		return

	DirAccess.make_dir_recursive_absolute(OUTPUT_DIR)

	var total = parsed.size()
	var ok := 0
	var failed := 0

	for i in range(total):
		var entry: Dictionary = parsed[i]
		var species_id: String = entry.get("id", "")
		if species_id.is_empty():
			push_warning("[%d/%d] entrada sem id, pulando." % [i + 1, total])
			failed += 1
			continue

		var species := _species_from_dict(entry)
		var path := OUTPUT_DIR + species_id + ".tres"
		var err := ResourceSaver.save(species, path)
		if err != OK:
			push_error("[%d/%d] falhou ao salvar %s: %s" % [i + 1, total, path, error_string(err)])
			failed += 1
		else:
			ok += 1
			if (i + 1) % 25 == 0 or (i + 1) == total:
				print("[%d/%d] %s.tres" % [i + 1, total, species_id])

	print("=== Importação concluída: %d ok, %d falha(s) ===" % [ok, failed])


func _species_from_dict(d: Dictionary) -> PokemonSpecies:
	var s := PokemonSpecies.new()
	s.dex_number = int(d.get("dex_number", 0))
	s.display_name = String(d.get("display_name", ""))
	s.id = String(d.get("id", ""))
	s.sr = String(d.get("sr", ""))

	# Tipos
	s.types.clear()
	for t in d.get("types", []):
		if Constants.TYPE_FROM_STRING.has(t):
			s.types.append(Constants.TYPE_FROM_STRING[t])
		else:
			push_warning("Tipo desconhecido em %s: %s" % [s.id, t])

	# Tamanho
	var size: Dictionary = d.get("size", {})
	s.size_category = String(size.get("category", ""))
	s.size_meters = float(size.get("meters", 0.0))

	s.min_level = int(d.get("min_level", 1))

	# Grupos de ovos
	s.egg_groups.clear()
	for g in d.get("egg_groups", []):
		s.egg_groups.append(String(g))

	# Gênero
	var gender: Array = d.get("gender_ratio", [50, 50])
	if gender.size() >= 2:
		s.gender_male_pct = int(gender[0])
		s.gender_female_pct = int(gender[1])

	s.evolution_stage = int(d.get("evolution_stage", 0))

	s.armor_class = int(d.get("armor_class", 10))
	s.hit_points = int(d.get("hit_points", 1))
	s.hit_dice = String(d.get("hit_dice", "d6"))

	# Movimento
	s.movement.clear()
	for k in d.get("movement", {}):
		if MOVEMENT_FROM_JSON.has(k):
			s.movement[MOVEMENT_FROM_JSON[k]] = float(d["movement"][k])
		else:
			push_warning("Movement desconhecido em %s: %s" % [s.id, k])

	# Atributos
	s.attributes.clear()
	for k in d.get("attributes", {}):
		if ATTR_FROM_JSON.has(k):
			s.attributes[ATTR_FROM_JSON[k]] = int(d["attributes"][k])
		else:
			push_warning("Atributo desconhecido em %s: %s" % [s.id, k])

	# Perícias
	s.skills.clear()
	for k in d.get("skills", []):
		if SKILL_FROM_JSON.has(k):
			s.skills.append(SKILL_FROM_JSON[k])
		else:
			push_warning("Perícia desconhecida em %s: %s" % [s.id, k])

	# Sentidos (texto cru)
	s.senses.clear()
	for x in d.get("senses", []):
		s.senses.append(String(x))

	# Habilidades
	s.abilities.clear()
	for x in d.get("abilities", []):
		s.abilities.append(String(x))
	s.hidden_ability = String(d.get("hidden_ability", ""))

	# Evolução
	s.evolves_to = String(d.get("evolves_to", ""))
	var evo_lvl = d.get("evolution_level", null)
	s.evolution_level = int(evo_lvl) if evo_lvl != null else -1

	# Moves por nível (chave int)
	s.level_moves.clear()
	for lvl_str in d.get("level_moves", {}):
		var lvl := int(lvl_str)
		var moves: Array = []
		for m in d["level_moves"][lvl_str]:
			moves.append(String(m))
		s.level_moves[lvl] = moves

	# TMs
	s.tms.clear()
	for x in d.get("tms", []):
		s.tms.append(String(x))

	# Egg moves
	s.egg_moves.clear()
	for x in d.get("egg_moves", []):
		s.egg_moves.append(String(x))

	return s
