class_name Regions
extends RefCounted
## Regras da Região de Origem do Treinador (Livro de Regras, "Região de Origem").
## Cada região tem 3 habilidades: bônus de atributo, perícia e uma habilidade própria.
## Os ids são os mesmos nomes dos nós do popup region_selector.tscn.
##
## Chaves de cada entrada:
##   attributes   -> lista de opções de bônus (1 opção = automática, 2+ = o jogador escolhe)
##   free_points  -> pontos livres de atributo (Kanto): o mesmo atributo duas vezes = +2
##   skill        -> perícia fixa
##   free_skills  -> perícias escolhidas livremente (Unova)
##   ac_bonus     -> bônus na CA (Sinnoh)
##   saving_throws-> salvaguardas treinadas (Sinnoh)
##   feature      -> habilidade própria principal (só texto, mostrada na última aba)
##   extra_features -> habilidades próprias adicionais (Paldea): lista de {title, text}

const ATTR_LABELS := ["FOR", "DES", "CON", "INT", "SAB", "CAR"]  # ordem de Constants.Attribute

const DATA := {
	"Alola": {
		"attributes": [{Constants.Attribute.INT: 2, Constants.Attribute.CHA: 1}],
		"skill": Constants.Skill.NATUREZA,
		"feature": {
			"title": "Uma conexão diferente",
			"text": "Vantagem em testes de perícia para entender o que um Pokémon expressa ou quer dizer.",
		},
	},
	"Hoenn": {
		"attributes": [{Constants.Attribute.WIS: 2, Constants.Attribute.INT: 1}],
		"skill": Constants.Skill.SOBREVIVENCIA,
		"feature": {
			"title": "Nada como o nosso lar",
			"text": "Escolha um ambiente: Costa, Deserto, Floresta ou Montanha, cada um com seu benefício.",
		},
	},
	"Johto": {
		"attributes": [{Constants.Attribute.INT: 2, Constants.Attribute.STR: 1}],
		"skill": Constants.Skill.HISTORIA,
		"feature": {
			"title": "Caminho da Serenidade",
			"text": "Ao falhar em uma salvaguarda de Sabedoria ou Carisma, role de novo e use o novo resultado. Uma vez por descanso curto ou longo.",
		},
	},
	"Kalos": {
		"attributes": [{Constants.Attribute.CHA: 2, Constants.Attribute.INT: 1}],
		"skill": Constants.Skill.PERSUASAO,
		"feature": {
			"title": "Bon Chance",
			"text": "Ao rolar 1 ou 2 no d20 em um teste de perícia ou salvaguarda, role de novo e use o novo resultado.",
		},
	},
	"Kanto": {
		"free_points": 2,
		"skill": Constants.Skill.INVESTIGACAO,
		"feature": {
			"title": "Minha hora de brilhar",
			"text": "Escolha um Talento e comece o jogo já com ele.",
		},
	},
	"Sinnoh": {
		"attributes": [{Constants.Attribute.CON: 2, Constants.Attribute.STR: 1}],
		"skill": Constants.Skill.ATLETISMO,
		"ac_bonus": 2,
		"saving_throws": [Constants.Attribute.CON],
		"feature": {
			"title": "Corpo e mente",
			"text": "Proficiência em salvaguardas de Constituição e +2 na Classe de Armadura (já aplicados na ficha).",
		},
	},
	"Unova": {
		"attributes": [{Constants.Attribute.DEX: 2, Constants.Attribute.WIS: 1}],
		"skill": Constants.Skill.INTUICAO,
		"free_skills": 2,
		"feature": {
			"title": "Pessoa de muitos talentos",
			"text": "Proficiência em 2 perícias de sua escolha (já aplicadas na ficha).",
		},
	},
	"Galar": {
		"attributes": [
			{Constants.Attribute.DEX: 2, Constants.Attribute.STR: 1},
			{Constants.Attribute.STR: 2, Constants.Attribute.DEX: 1},
		],
		"skill": Constants.Skill.INTIMIDACAO,
		"feature": {
			"title": "Minha mãe bate mais forte",
			"text": "Ao sofrer dano, use sua reação para rolar d12 + mod. de Constituição e reduzir o dano. Uma vez por descanso curto ou longo.",
		},
	},
	"Paldea": {
		"attributes": [{Constants.Attribute.INT: 2, Constants.Attribute.CHA: 1}],
		"skill": Constants.Skill.INVESTIGACAO,
		"feature": {
			"title": "Espírito Acadêmico",
			"text": "Seja na Academia Naranja ou Uva, você foi treinado para observar o mundo com curiosidade e dedicação. O estudo constante e a vida social vibrante moldaram sua mente. Você ganha +2 em sua Inteligência e +1 em seu Carisma.",
		},
		"extra_features": [
			{
				"title": "Em Busca do Tesouro",
				"text": "O objetivo de todo cidadão de Paldea é encontrar seu \"tesouro\" pessoal, o que exige um olhar atento aos detalhes e aos segredos escondidos na paisagem. Você ganha proficiência na perícia Investigação.",
			},
			{
				"title": "Brilho Terastal",
				"text": "Você carrega consigo a energia vibrante dos cristais de Paldea, permitindo que você ou seus Pokémon superem limites em momentos críticos. Escolha abaixo uma afinidade elementar baseada no seu \"Tera Tipo\" ideal. Essa escolha não pode ser alterada posteriormente.\n\n• Ofensivo: Uma vez por descanso longo, quando seu Pokémon realiza um ataque super efetivo, você pode usar sua ação bônus para aumentar o dano causado em um valor igual ao seu bônus de proficiência. Esse valor é acrescentado por último, após o cálculo do dano final.\n\n• Defensivo: Uma vez por descanso longo, quando seu Pokémon recebe um ataque super efetivo, você pode usar sua reação para reduzir o dano recebido em um valor igual ao seu bônus de proficiência. Esse valor é subtraído por último, após o cálculo do dano final.\n\n• Veloz: Você está acostumado a cavalgar por terrenos difíceis. Quando estiver utilizando um Pokémon como montaria, vocês ignoram penalidades de movimento em terrenos difíceis e acidentados (lama, neve, floresta densa, etc). Além disso, você é capaz de motivar seu Pokémon, aumentando seu deslocamento em 10 pés (3 metros) enquanto estiver montando nele.",
			},
		],
	},
}

static func has_data(id: String) -> bool:
	return DATA.has(id)

static func get_options(id: String) -> Array:
	return DATA.get(id, {}).get("attributes", [])

static func get_free_points(id: String) -> int:
	return DATA.get(id, {}).get("free_points", 0)

static func get_free_skills(id: String) -> int:
	return DATA.get(id, {}).get("free_skills", 0)

## Perícia fixa da região, ou -1
static func get_skill(id: String) -> int:
	return DATA.get(id, {}).get("skill", -1)

static func get_ac_bonus(id: String) -> int:
	return DATA.get(id, {}).get("ac_bonus", 0)

static func get_saving_throws(id: String) -> Array:
	return DATA.get(id, {}).get("saving_throws", [])

## {"title": ..., "text": ...} da habilidade principal (vazio se não houver região).
## Para pegar TODAS as habilidades (principal + extras), use get_features().
static func get_feature(id: String) -> Dictionary:
	return DATA.get(id, {}).get("feature", {})

## Lista completa das features da região: a principal + as extras.
## Cada item é {"title": ..., "text": ...}. Retorna [] se a região não tem feature.
## Usado pela aba "Talentos e Habilidades" para renderizar todos os blocos de texto.
static func get_features(id: String) -> Array:
	var data: Dictionary = DATA.get(id, {})
	var result := []
	var main: Dictionary = data.get("feature", {})
	if not main.is_empty():
		result.append(main)
	for extra in data.get("extra_features", []):
		result.append(extra)
	return result

## {atributo: valor} -> "+2 DES, +1 FOR"
static func describe(bonus: Dictionary) -> String:
	var parts := PackedStringArray()
	for attr in bonus:
		parts.append("%+d %s" % [bonus[attr], ATTR_LABELS[attr]])
	return ", ".join(parts)
