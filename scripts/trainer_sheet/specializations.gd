class_name Specializations
extends RefCounted
## Regras das Especializações do Treinador (Livro de Regras, "Especializações").
## Escolhidas nos níveis 1, 7 e 18. Cada uma dá 1 perícia (fixa ou escolha),
## eventualmente +1 em atributo (fixo ou escolha) e uma habilidade própria.
##
## Chaves de cada entrada:
##   display_name       -> nome bonito para exibição
##   skill_fixed        -> Constants.Skill ou -1 (sem perícia fixa)
##   skill_choice       -> Array de Constants.Skill (vazio = sem escolha)
##   attribute_fixed    -> Constants.Attribute ou -1 (sem bônus fixo)
##   attribute_choice   -> Array de Constants.Attribute (vazio = sem escolha)
##   feature            -> {"title": String, "text": String}

const DATA := {
	"guardiao_dos_passaros": {
		"display_name": "Guardião dos Pássaros",
		"skill_fixed": Constants.Skill.PERCEPCAO,
		"skill_choice": [],
		"attribute_fixed": -1,
		"attribute_choice": [],
		"feature": {
			"title": "Visão Aguçada",
			"text": "Por sua experiência em observar aves à distância, sua visão tornou-se extremamente aguçada. Ao realizar testes de Percepção relacionados à visão, adicione 1d4 ao resultado do teste. Além disso, você é capaz de enxergar com grande riqueza de detalhes a até 100 pés (30 metros) de distância. Adicione um bônus de +1 a todos os testes de perícia feitos por qualquer um dos seus Pokémon do tipo Voador.",
		},
	},
	"maniatico_por_insetos": {
		"display_name": "Maníaco por Insetos",
		"skill_fixed": Constants.Skill.NATUREZA,
		"skill_choice": [],
		"attribute_fixed": -1,
		"attribute_choice": [],
		"feature": {
			"title": "Olho para Insetos",
			"text": "Uma vez por descanso longo, você pode fazer um teste de Inteligência (Natureza) com vantagem para obter informações sobre o ambiente ou sinais de Pokémon do tipo Inseto nas proximidades. Adicione um bônus de +1 a todos os testes de perícia feitos por qualquer um dos seus Pokémon do tipo Inseto.",
		},
	},
	"campista": {
		"display_name": "Campista",
		"skill_fixed": Constants.Skill.SOBREVIVENCIA,
		"skill_choice": [],
		"attribute_fixed": -1,
		"attribute_choice": [],
		"feature": {
			"title": "Acampamento Seguro",
			"text": "Você consegue montar acampamento seguro rapidamente. Uma vez por descanso longo, qualquer teste de Sobrevivência feito para encontrar ou preparar abrigo, comida ou fogo é feito com vantagem. Adicione um bônus de +1 a todos os testes de perícia feitos por qualquer um dos seus Pokémon do tipo Terra.",
		},
	},
	"domador_de_dragoes": {
		"display_name": "Domador de Dragões",
		"skill_fixed": Constants.Skill.ADESTRAR_ANIMAIS,
		"skill_choice": [],
		"attribute_fixed": Constants.Attribute.WIS,
		"attribute_choice": [],
		"feature": {
			"title": "Sentido Dracônico",
			"text": "Você sente a presença de Pokémon Dragão nas proximidades. Você pode sentir a presença de um Pokémon Dragão em até 100 metros, mas não é capaz de saber a direção dele. Adicione um bônus de +1 a todos os testes de perícia feitos por qualquer um dos seus Pokémon do tipo Dragão.",
		},
	},
	"engenheiro": {
		"display_name": "Engenheiro",
		"skill_fixed": Constants.Skill.ARCANISMO,
		"skill_choice": [],
		"attribute_fixed": Constants.Attribute.INT,
		"attribute_choice": [],
		"feature": {
			"title": "Análise Técnica",
			"text": "Você consegue analisar dispositivos ou mecanismos rapidamente. Uma vez por descanso longo, você pode rolar um teste de Inteligência (Investigação) com vantagem para entender ou consertar máquinas ou mecanismos. Adicione um bônus de +1 a todos os testes de perícia feitos por qualquer um dos seus Pokémon do tipo Elétrico.",
		},
	},
	"piromaniaco": {
		"display_name": "Piromaníaco",
		"skill_fixed": Constants.Skill.INTIMIDACAO,
		"skill_choice": [],
		"attribute_fixed": Constants.Attribute.CON,
		"attribute_choice": [],
		"feature": {
			"title": "Sempre Pronto para o Fogo",
			"text": "Você nunca perde a oportunidade de botar fogo em algo. Você sempre tem consigo um pequeno esqueiro, capaz de acender fogueiras, romper cordas ou gerar luz em um raio de 4,5 metros. Adicione um bônus de +1 a todos os testes de perícia feitos por qualquer um dos seus Pokémon do tipo Fogo.",
		},
	},
	"encantador": {
		"display_name": "Encantador",
		"skill_fixed": Constants.Skill.PERSUASAO,
		"skill_choice": [],
		"attribute_fixed": Constants.Attribute.CHA,
		"attribute_choice": [],
		"feature": {
			"title": "Presença Encantadora",
			"text": "Sua presença é encantadora. Uma vez por descanso longo, você pode conceder vantagem a um teste de Carisma (Persuasão) para interagir com pessoas ou Pokémon de temperamento amigável. Adicione um bônus de +1 a todos os testes de perícia feitos por qualquer um dos seus Pokémon do tipo Fada.",
		},
	},
	"sombrio": {
		"display_name": "Sombrio",
		"skill_fixed": -1,
		"skill_choice": [Constants.Skill.ENGANACAO, Constants.Skill.FURTIVIDADE],
		"attribute_fixed": -1,
		"attribute_choice": [],
		"feature": {
			"title": "Mover nas Sombras",
			"text": "Você consegue se mover silenciosamente e observar sem ser notado. Uma vez por descanso longo, você pode rolar um teste de Furtividade ou Enganação com vantagem. Adicione um bônus de +1 a todos os testes de perícia feitos por qualquer um dos seus Pokémon do tipo Sombrio.",
		},
	},
	"alquimista": {
		"display_name": "Alquimista",
		"skill_fixed": -1,
		"skill_choice": [Constants.Skill.MEDICINA, Constants.Skill.ENGANACAO],
		"attribute_fixed": -1,
		"attribute_choice": [],
		"feature": {
			"title": "Preparo Rápido",
			"text": "Você consegue preparar poções simples rapidamente. Uma vez por descanso longo, você pode criar uma poção. Esta poção pode ser usada em até 24h. Após isso, ela perde seu efeito. Adicione um bônus de +1 a todos os testes de perícia feitos por qualquer um dos seus Pokémon do tipo Venenoso.",
		},
	},
	"jogador_de_equipe": {
		"display_name": "Jogador de Equipe",
		"skill_fixed": -1,
		"skill_choice": [],
		"attribute_fixed": -1,
		"attribute_choice": [
			Constants.Attribute.STR, Constants.Attribute.DEX, Constants.Attribute.CON,
			Constants.Attribute.INT, Constants.Attribute.WIS, Constants.Attribute.CHA,
		],
		"feature": {
			"title": "Inspirar Aliados",
			"text": "Você consegue inspirar aliados. Uma vez por descanso curto, você pode conceder +1d4 a um teste de perícia ou rolagem de ataque de qualquer aliado. Pode ser usado após o resultado da rolagem. Adicione um bônus de +1 a todos os testes de perícia feitos por qualquer um dos seus Pokémon do tipo Normal.",
		},
	},
	"esquiador": {
		"display_name": "Esquiador",
		"skill_fixed": -1,
		"skill_choice": [Constants.Skill.ATUACAO, Constants.Skill.PERSUASAO],
		"attribute_fixed": -1,
		"attribute_choice": [],
		"feature": {
			"title": "Passo Firme no Gelo",
			"text": "Você se move elegantemente sobre superfícies escorregadias. Uma vez por descanso curto, você pode rolar um teste de Acrobacia ou Atletismo com vantagem para se mover em gelo, neve ou terrenos escorregadios. Adicione um bônus de +1 a todos os testes de perícia feitos por qualquer um dos seus Pokémon do tipo Gelo.",
		},
	},
	"jardineiro": {
		"display_name": "Jardineiro",
		"skill_fixed": Constants.Skill.NATUREZA,
		"skill_choice": [],
		"attribute_fixed": -1,
		"attribute_choice": [],
		"feature": {
			"title": "Conhecedor de Plantas",
			"text": "Você consegue identificar plantas úteis ou venenosas com facilidade. Uma vez por descanso longo, você pode rolar um teste de Inteligência (Natureza) com vantagem para identificar plantas e seus efeitos. Adicione um bônus de +1 a todos os testes de perícia feitos por qualquer um dos seus Pokémon do tipo Grama.",
		},
	},
	"artista_marcial": {
		"display_name": "Artista Marcial",
		"skill_fixed": -1,
		"skill_choice": [],
		"attribute_fixed": -1,
		"attribute_choice": [Constants.Attribute.STR, Constants.Attribute.DEX, Constants.Attribute.CON],
		"feature": {
			"title": "Agilidade em Combate",
			"text": "Você consegue se mover com agilidade em combate ou obstáculos físicos. Uma vez por descanso longo, você pode rolar um teste de Destreza (Acrobacia) com vantagem. Adicione um bônus de +1 a todos os testes de perícia feitos por qualquer um dos seus Pokémon do tipo Lutador.",
		},
	},
	"alpinista": {
		"display_name": "Alpinista",
		"skill_fixed": -1,
		"skill_choice": [],
		"attribute_fixed": -1,
		"attribute_choice": [Constants.Attribute.STR, Constants.Attribute.DEX, Constants.Attribute.CON],
		"feature": {
			"title": "Passo em Terreno Difícil",
			"text": "Você é resistente em terrenos difíceis. Uma vez por descanso longo, você pode rolar um teste de Atletismo ou Acrobacia com vantagem enquanto estiver escalando ou se movendo em terrenos acidentados. Adicione um bônus de +1 a todos os testes de perícia feitos por qualquer um dos seus Pokémon do tipo Pedra.",
		},
	},
	"mistico": {
		"display_name": "Místico",
		"skill_fixed": Constants.Skill.ARCANISMO,
		"skill_choice": [],
		"attribute_fixed": -1,
		"attribute_choice": [],
		"feature": {
			"title": "Sentir o Sobrenatural",
			"text": "Você consegue sentir presenças sobrenaturais. Você é capaz de detectar a presença de Pokémon Fantasma ou atividades sobrenaturais em até 30 metros, mas não é capaz de saber a direção. Adicione um bônus de +1 a todos os testes de perícia feitos por qualquer um dos seus Pokémon do tipo Fantasma.",
		},
	},
	"metalurgico": {
		"display_name": "Metalúrgico",
		"skill_fixed": -1,
		"skill_choice": [],
		"attribute_fixed": -1,
		"attribute_choice": [Constants.Attribute.STR, Constants.Attribute.CON],
		"feature": {
			"title": "Corpo Endurecido",
			"text": "Acostumado a lidar com o peso e a rigidez de Pokémon metálicos, seu corpo se tornou mais resistente. Uma vez por descanso longo, quando você sofrer dano físico, pode reduzir esse dano em 1d4 + seu modificador de Constituição. Adicione um bônus de +1 a todos os testes de perícia feitos por qualquer um dos seus Pokémon do tipo Aço.",
		},
	},
	"psiquico": {
		"display_name": "Psíquico",
		"skill_fixed": -1,
		"skill_choice": [],
		"attribute_fixed": Constants.Attribute.INT,
		"attribute_choice": [],
		"feature": {
			"title": "Ligação Telepática",
			"text": "Você cria uma ligação telepática com um de seus Pokémon, sem limite de distância, permitindo compartilhar instantaneamente palavras, imagens, sons, sensações, além de ser capaz de comandá-lo em combate mesmo quando ele estiver além do alcance de sua voz. Só é possível ter um Pokémon conectado por vez, podendo trocar o alvo a cada descanso longo. Adicione um bônus de +1 a todos os testes de perícia feitos por qualquer um dos seus Pokémon do tipo Psíquico.",
		},
	},
	"nadador": {
		"display_name": "Nadador",
		"skill_fixed": -1,
		"skill_choice": [],
		"attribute_fixed": Constants.Attribute.CON,
		"attribute_choice": [],
		"feature": {
			"title": "Nado Natural",
			"text": "Ganhe uma velocidade de natação igual à sua velocidade de movimento. Adicione um bônus de +1 a todos os testes de perícia feitos por qualquer um dos seus Pokémon do tipo Água.",
		},
	},
}

static func has_data(id: String) -> bool:
	return DATA.has(id)

static func get_display_name(id: String) -> String:
	return DATA.get(id, {}).get("display_name", id)

static func get_skill_fixed(id: String) -> int:
	return DATA.get(id, {}).get("skill_fixed", -1)

static func get_skill_choice(id: String) -> Array:
	return DATA.get(id, {}).get("skill_choice", [])

static func get_attribute_fixed(id: String) -> int:
	return DATA.get(id, {}).get("attribute_fixed", -1)

static func get_attribute_choice(id: String) -> Array:
	return DATA.get(id, {}).get("attribute_choice", [])

static func get_feature(id: String) -> Dictionary:
	return DATA.get(id, {}).get("feature", {})

## Se a especialização pede alguma escolha na UI (perícia ou atributo).
static func needs_choice(id: String) -> bool:
	return not get_skill_choice(id).is_empty() or not get_attribute_choice(id).is_empty()
