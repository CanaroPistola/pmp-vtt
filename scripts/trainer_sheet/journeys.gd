class_name Journeys
extends RefCounted
## Regras da Origem de Jornada do Treinador (Livro de Regras, "Origem de Jornada").
## Cada origem dá 2 perícias fixas, um conhecimento de itens (texto), um
## equipamento bônus (dado cru, sem UI por enquanto) e uma habilidade própria (texto).
##
## Chaves de cada entrada:
##   skills           -> lista de Constants.Skill (sempre 2, fixas)
##   item_knowledge   -> texto da categoria de itens que o Treinador conhece
##   bonus_equipment  -> Dictionary descrevendo o bônus de equipamento
##   feature          -> {"title": ..., "text": ...} da habilidade própria
## Os ids são os mesmos nomes dos nós do popup journey_selector.tscn.

const DATA := {
	"Atleta": {
		"skills": [Constants.Skill.ATLETISMO, Constants.Skill.SOBREVIVENCIA],
		"item_knowledge": "Itens-X, Vitaminas",
		"bonus_equipment": {
			"type": "items_budget",
			"category": "Itens-X",
			"budget": 1200,
		},
		"feature": {
			"title": "Espírito Competitivo",
			"text": "Você tem uma força de vontade inabalável e um físico treinado pela competição. Ao realizar um teste de Atletismo para correr, escalar ou nadar, você pode rolar duas vezes e escolher o melhor resultado (uma vez por descanso curto ou longo). Além disso, você ignora penalidades de terreno difícil causadas por superfícies naturais (lama, areia, neve) ao se deslocar.",
		},
	},
	"Conhecedor": {
		"skills": [Constants.Skill.MEDICINA, Constants.Skill.ATUACAO],
		"item_knowledge": "Itens restauradores",
		"bonus_equipment": {
			"type": "items_budget",
			"category": "Itens restauradores",
			"budget": 1200,
		},
		"feature": {
			"title": "Cuidado Natural",
			"text": "Você sabe como acalmar e cuidar de pessoas e Pokémon feridos ou estressados. Ao realizar um teste de Sabedoria (Medicina) para usar os conhecimentos da medicina humana e Pokémon, você pode rolar duas vezes e escolher o melhor resultado (uma vez por descanso curto ou longo). Uma vez por descanso longo, você pode gastar 10 minutos cuidando de um Treinador ou Pokémon consciente, restaurando PV iguais ao seu modificador de Sabedoria + o nível do alvo (mínimo de 1). Treinadores e Pokémon tratados dessa forma também têm vantagem em testes de resistência contra a condição envenenado nas próximas 24 horas.",
		},
	},
	"Nobre": {
		"skills": [Constants.Skill.HISTORIA, Constants.Skill.PERSUASAO],
		"item_knowledge": "Itens Segurados",
		"bonus_equipment": {
			"type": "held_item_budget",
			"budget": 4400,
		},
		"feature": {
			"title": "Presença Aristocrática",
			"text": "Você carrega uma aura de confiança e autoridade que poucos ousam questionar. Ao realizar um teste de Carisma (Persuasão) com pessoas acostumadas à etiqueta ou autoridade (como oficiais, comerciantes ou pessoas famosas), você pode rolar duas vezes e escolher o melhor resultado (uma vez por descanso curto ou longo). Uma vez por descanso longo, você pode usar 1 minuto para discursar, organizar ou encorajar uma equipe. Até 6 ouvintes (Pokémon ou humanos) recebem vantagem em um teste de perícia à sua escolha feito na próxima hora. Além disso, sempre que chega a um novo local, você sabe onde encontrar recursos de luxo, hospedagens ou contatos de alto nível.",
		},
	},
	"Encrenqueiro": {
		"skills": [Constants.Skill.PRESTIDIGITACAO, Constants.Skill.FURTIVIDADE],
		"item_knowledge": "Itens de Evolução",
		"bonus_equipment": {
			"type": "evolution_item",
			"exclude": "Pedra-Chave",
		},
		"feature": {
			"title": "Fuga Rápida",
			"text": "Você aprendeu a se virar em situações perigosas. Ao realizar um teste de Enganação ou Prestidigitação feitos para despistar alguém, improvisar truques, distrair oponentes ou sair de situações embaraçosas, você pode rolar duas vezes e escolher o melhor resultado (uma vez por descanso curto ou longo). Uma vez por descanso longo, você pode fazer um teste de Prestidigitação com vantagem para resolver um obstáculo simples, como abrir uma porta trancada improvisando ferramentas com o ambiente ou consertar algo quebrado usando materiais limitados. Além disso, você conhece as áreas menos movimentadas das cidades, becos tranquilos e rotas alternativas. Você sempre sabe onde encontrar abrigo, atalhos e rotas seguras dentro de uma cidade ou vila.",
		},
	},
	"Amigo dos Pokémon": {
		"skills": [Constants.Skill.SOBREVIVENCIA, Constants.Skill.NATUREZA],
		"item_knowledge": "Berries",
		"bonus_equipment": {
			"type": "items_budget",
			"category": "Berries",
			"budget": 1200,
		},
		"feature": {
			"title": "Andarilho Natural",
			"text": "Você conhece a natureza e os hábitos dos Pokémon selvagens. Você tem uma memória excelente para mapas e geografia, e sempre pode recobrar o plano geral de terrenos, assentamentos ou outras características ao seu redor. Você pode encontrar comida e água fresca para você e até cinco outras pessoas a cada dia, considerando que a terra ofereça berries, pequenas frutas, água e similares. Pokémon selvagens neutros têm atitude inicial amistosa com você, a menos que sejam provocados.",
		},
	},
	"Rival": {
		"skills": [Constants.Skill.PERCEPCAO, Constants.Skill.INTIMIDACAO],
		"item_knowledge": "Pokébolas Raras",
		"bonus_equipment": {
			"type": "items_budget",
			"category": "Pokébolas",
			"budget": 1200,
		},
		"feature": {
			"title": "Espírito de Superação",
			"text": "Você prospera com a rivalidade, usando-a como combustível para evoluir. Sempre que perde uma competição, desafio ou falha em uma meta pessoal, você pode marcar essa derrota como uma lição. Na próxima situação semelhante, você recebe vantagem no teste de perícia relacionado (uma vez por lição). Caso tenha perdido uma batalha Pokémon, você possui vantagem em 1 ataque no próximo combate. Cada vitória te enche de determinação. A cada vitória consecutiva em batalhas contra outros Treinadores, todos os seus Pokémon em combate recebem +1 na iniciativa nas próximas batalhas, até um máximo de +3 (após três vitórias seguidas). Caso perca uma batalha contra outro Treinador, o acúmulo é zerado.",
		},
	},
	"Estudioso": {
		"skills": [Constants.Skill.INVESTIGACAO, Constants.Skill.HISTORIA],
		"item_knowledge": "TMs",
		"bonus_equipment": {
			"type": "tm_choice",
			"options_tm": [
				"TM01 Work Up", "TM04 Calm Mind", "TM05 Roar", "TM07 Hail",
				"TM11 Sunny Day", "TM12 Taunt", "TM16 Light Screen", "TM18 Rain Dance",
				"TM20 Safeguard", "TM32 Double Team", "TM33 Reflect", "TM37 Sandstorm",
				"TM41 Torment", "TM45 Attract", "TM63 Embargo", "TM69 Rock Polish",
				"TM70 Aurora Veil", "TM77 Psych Up", "TM90 Substitute", "TM92 Trick Room",
			],
		},
		"feature": {
			"title": "Análise Estratégica",
			"text": "Você é capaz de observar padrões e compreender as forças e fraquezas de um adversário. Como uma ação bônus, você pode analisar um Pokémon que possa ver. Faça um teste de Investigação (CD = 10 + nível do alvo). Se for bem-sucedido, você descobre o(s) tipo(s) do Pokémon e se ele tem alguma resistência ou vulnerabilidade ao Move que você planeja usar. Você pode usar este recurso um número de vezes igual a 1 + seu modificador de Inteligência (mínimo de 1). Uma vez por descanso longo, você pode usar essa análise para orientar um Pokémon aliado ou seu Treinador, concedendo vantagem em uma rolagem de ataque ou resistência contra o alvo que você examinou. Você pode fazer isso mesmo que não esteja participando do combate.",
		},
	},
}

static func has_data(id: String) -> bool:
	return DATA.has(id)

static func get_skills(id: String) -> Array:
	return DATA.get(id, {}).get("skills", [])

static func get_item_knowledge(id: String) -> String:
	return DATA.get(id, {}).get("item_knowledge", "")

static func get_bonus_equipment(id: String) -> Dictionary:
	return DATA.get(id, {}).get("bonus_equipment", {})

static func get_feature(id: String) -> Dictionary:
	return DATA.get(id, {}).get("feature", {})
