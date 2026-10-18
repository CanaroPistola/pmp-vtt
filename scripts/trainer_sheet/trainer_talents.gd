class_name TrainersTalents
extends RefCounted

const DATA := {
	"acrobata": {
		"display_name": "Acrobata",
		"description": "Aumente seu valor de Destreza em 1. Você ganha proficiência na perícia Acrobacia. Se já for proficiente, passa a ser especialista. Como ação bônus, você pode fazer um teste de Destreza (Acrobacia) CD 15. Se for bem-sucedido, o terreno difícil não lhe custará movimento extra até o final do turno atual.",
		"attribute_bonus": {Constants.Attribute.DEX: 1},
		"skills_fixed": [Constants.Skill.ACROBACIA],
		"skills_expert": [Constants.Skill.ACROBACIA]
	},
	"alerta": {
		"display_name": "Alerta",
		"description": "Você recebe +5 de bônus em iniciativa. Você não pode ser surpreso enquanto estiver consciente. Outras criaturas não ganham vantagem nas jogadas de ataque contra você por estarem escondidas de você.",
		"attribute_bonus": {}, "skills_fixed": [], "skills_expert": []
	},
	"atleta": {
		"display_name": "Atleta",
		"description": "Aumente seu valor de Força ou Destreza em 1. Quando você estiver caído, se levantar requer apenas 1,5 metro do seu deslocamento. Escalar não custa movimento adicional a você. Você pode realizar um salto em distância correndo ou um salto em altura correndo se movendo apenas um passo de ajuste de 1,5 metro, ao invés de 3 metros.",
		"attribute_bonus": {"choice": [Constants.Attribute.STR, Constants.Attribute.DEX]},
		"skills_fixed": [], "skills_expert": []
	},
	"ator": {
		"display_name": "Ator",
		"description": "Aumente seu valor de Carisma em 1. Você tem vantagem em testes de Carisma (Atuação) e Carisma (Enganação) quando você estiver tentando se passar por uma pessoa diferente. Você pode imitar a articulação de outra pessoa ou os sons feitos por outras criaturas...",
		"attribute_bonus": {Constants.Attribute.CHA: 1}, "skills_fixed": [], "skills_expert": []
	},
	"curandeiro": {
		"display_name": "Curandeiro",
		"description": "Quando você usar um kit de primeiros-socorros para estabilizar uma criatura morrendo, a criatura recupera 1 ponto de vida, ao invés disso. Com uma ação, você pode gastar um uso do kit de primeiros-socorros para tratar de uma criatura e restaurar 1d6 + 4 pontos de vida mais uma quantidade de pontos de vida adicionais igual ao número total de Dados de Vida da criatura. A criatura não pode recuperar pontos de vida através desse talento novamente até ter terminado um descanso curto ou longo.",
		"attribute_bonus": {}, "skills_fixed": [], "skills_expert": []
	},
	"dedos_rapidos": {
		"display_name": "Dedos Rápidos",
		"description": "Aumente seu valor de Destreza em 1. Você ganha proficiência na perícia Prestidigitação. Se já for proficiente, passa a ser especialista. Como uma ação bônus, você pode fazer um teste de Destreza (Prestidigitação) para plantar algo em outra pessoa, esconder um objeto em uma criatura, levantar uma bolsa ou tirar algo do bolso.",
		"attribute_bonus": {Constants.Attribute.DEX: 1},
		"skills_fixed": [Constants.Skill.PRESTIDIGITACAO],
		"skills_expert": [Constants.Skill.PRESTIDIGITACAO]
	},
	"disputador": {
		"display_name": "Disputador",
		"description": "Você tem vantagem nas jogadas de ataque contra uma criatura que você está agarrando. Você pode usar sua ação para tentar imobilizar uma criatura já agarrada por você. Para fazer isso, faça outro teste de agarrar. Se você for bem-sucedido, você e a criatura permanecerão impedidos até que o agarrão termine. Quando uma criatura tenta usar seu movimento para deixar seu alcance sem desengajar, você pode usar sua reação para tentar agarrar o alvo.",
		"attribute_bonus": {}, "skills_fixed": [], "skills_expert": []
	},
	"esquivo": {
		"display_name": "Esquivo",
		"description": "Pré-requisito: Destreza 13 ou maior. Você pode tentar se esconder quando estiver levemente obscurecido para a criatura de quem você está tentando se esconder. Quando você estiver escondido de uma criatura e errar um ataque à distância contra ela, realizar esse ataque não revelará sua posição. Penumbra não impõem desvantagem nos seus testes de Sabedoria (Percepção) relacionados a visão.",
		"attribute_bonus": {}, "skills_fixed": [], "skills_expert": []
	},
	"aumento_ca": {
		"display_name": "Aumento de CA",
		"description": "A sua CA aumenta em 1. Esse bônus é incluído nas evoluções de um Pokémon.",
		"attribute_bonus": {}, "skills_fixed": [], "skills_expert": []
	},
	"explorador_cavernas": {
		"display_name": "Explorador de Cavernas",
		"description": "Você tem vantagem em testes de Sabedoria (Percepção) e Inteligência (Investigação) feitos para detectar passagens ocultas, estruturas instáveis, formações frágeis ou entradas escondidas em cavernas, ruínas ou montanhas. Você tem vantagem em testes de resistência feitos para evitar desmoronamentos, gases tóxicos, terrenos naturais, escorregadios ou outras condições ambientais perigosas. Você possui resistência a danos causados por quedas de rochas, desabamentos e outros perigos naturais encontrados em ambientes subterrâneos. Você pode mapear e explorar ambientes rochosos ou subterrâneos sem reduzir seu ritmo de viagem...",
		"attribute_bonus": {}, "skills_fixed": [], "skills_expert": []
	},
	"mente_afiada": {
		"display_name": "Mente Afiada",
		"description": "Aumente seu valor de Inteligência em 1. Você sempre sabe qual a direção do norte. Você sempre sabe o número de horas restantes para o próximo nascer ou pôr do sol. Você pode relembrar, com precisão, qualquer coisa que você tenha visto ou ouvido no último mês.",
		"attribute_bonus": {Constants.Attribute.INT: 1}, "skills_fixed": [], "skills_expert": []
	},
		"mestre_do_tipo": {
		"display_name": "Mestre do Tipo",
		"description": "Você se torna um verdadeiro especialista em um tipo específico de Pokémon. Escolha um tipo entre suas Especializações. Todos os Pokémon desse tipo recebem os seguintes benefícios: O acerto, dano e STAB de qualquer Pokémon que compartilhe esse tipo aumentam em +2. Você adiciona seu modificador de Sabedoria ou Carisma na rolagem ao tentar capturar Pokémon do tipo escolhido. Você dobra seus bônus de proficiência ao realizar perícias para localizar Pokémon desse tipo. Seus Pokémon do tipo escolhido dobram seus bônus de proficiência nos testes de perícia que realizarem.",
		"attribute_bonus": {}, 
		"skills_fixed": [], 
		"skills_expert": [],
		"choice_type": true # Flag especial para a UI
	},
	"mobilidade": {
		"display_name": "Mobilidade",
		"description": "Seu deslocamento aumenta em 3 metros. Quando você usa a ação de Disparada, mover-se através de terreno difícil não lhe custa qualquer movimento adicional neste turno. Quando você realiza um ataque corpo a corpo contra uma criatura, você não provoca ataques de oportunidade para essa criatura pelo resto do turno, independentemente de ter atingido ou não.",
		"attribute_bonus": {}, "skills_fixed": [], "skills_expert": []
	},
	"musculoso": {
		"display_name": "Musculoso",
		"description": "Aumente seu valor de Força em 1. Você ganha proficiência na perícia Atletismo. Se já for proficiente, passa a ser especialista. Você conta como se fosse um tamanho maior para determinar sua capacidade de carga.",
		"attribute_bonus": {Constants.Attribute.STR: 1},
		"skills_fixed": [Constants.Skill.ATLETISMO], "skills_expert": [Constants.Skill.ATLETISMO]
	},
	"observador": {
		"display_name": "Observador",
		"description": "Aumente seu valor de Inteligência ou Sabedoria em 1. Se você puder ver a boca de uma criatura enquanto ela fala um idioma que você compreende, você pode interpretar o que ela está dizendo ao ler os seus lábios. Você tem +5 de bônus nos seus valores passivos de Sabedoria (Percepção) e Inteligência (Investigação).",
		"attribute_bonus": {"choice": [Constants.Attribute.INT, Constants.Attribute.WIS]},
		"skills_fixed": [], "skills_expert": []
	},
	"pequeno_grande": {
		"display_name": "Pequeno Grande",
		"description": "Pré-requisito: Treinador de nível 8 ou superior. Você enxerga o potencial oculto em seus Pokémon...",
		"attribute_bonus": {}, "skills_fixed": [], "skills_expert": []
	},
	"perceptivo": {
		"display_name": "Perceptivo",
		"description": "Aumente seu valor de Sabedoria em 1. Você ganha proficiência na perícia Percepção. Se já for proficiente, passa a ser especialista. Estar em uma área levemente obscurecida não impõe desvantagem em seus testes de Sabedoria (Percepção) se você puder ver e ouvir.",
		"attribute_bonus": {Constants.Attribute.WIS: 1},
		"skills_fixed": [Constants.Skill.PERCEPCAO], "skills_expert": [Constants.Skill.PERCEPCAO]
	},
	"perito": {
		"display_name": "Perito",
		"description": "Você ganha proficiência em qualquer combinação de três perícias à sua escolha.",
		"attribute_bonus": {}, "skills_fixed": [], "skills_expert": []
	},
	"resiliente": {
		"display_name": "Resiliente",
		"description": "Escolha um atributo. Aumente o valor do atributo escolhido em 1. Você ganha proficiência em testes de resistência usando o atributo escolhido. Caso já seja proficiente, este bônus não se acumula.",
		"attribute_bonus": {"choice": [Constants.Attribute.STR, Constants.Attribute.DEX, Constants.Attribute.CON, Constants.Attribute.INT, Constants.Attribute.WIS, Constants.Attribute.CHA]},
		"skills_fixed": [], "skills_expert": []
	},
	"resistente": {
		"display_name": "Resistente",
		"description": "Aumente seu valor de Constituição em 1. Quando você rolar um Dado de Vida para recuperar pontos de vida, o valor mínimo de pontos de vida que você recupera dessa rolagem será igual a duas vezes seu modificador de Constituição (mínimo de 2).",
		"attribute_bonus": {Constants.Attribute.CON: 1}, "skills_fixed": [], "skills_expert": []
	},
	"robusto": {
		"display_name": "Robusto",
		"description": "Seu máximo de pontos de vida aumenta em um valor igual a duas vezes seu nível quando você adquire esse talento. Toda vez que você ganhar um nível, após isso, seu máximo de pontos de vida aumenta em 2 pontos de vida adicionais.",
		"attribute_bonus": {}, "skills_fixed": [], "skills_expert": []
	},
	"sorrateiro": {
		"display_name": "Sorrateiro",
		"description": "Aumente seu valor de Destreza em 1. Você ganha proficiência na perícia Furtividade. Se já for proficiente, passa a ser especialista. Se estiver escondido, você pode se mover até 3 metros ao ar livre sem se revelar se terminar o movimento em uma posição onde não esteja claramente visível.",
		"attribute_bonus": {Constants.Attribute.DEX: 1},
		"skills_fixed": [Constants.Skill.FURTIVIDADE], "skills_expert": [Constants.Skill.FURTIVIDADE]
	},
	"sortudo": {
		"display_name": "Sortudo",
		"description": "Você tem 3 pontos de sorte. A qualquer momento que você realizar um teste de perícia ou teste de resistência, você pode gastar um ponto de sorte para rolar um d20 adicional... Você recupera seus pontos de sorte gastos após terminar um descanso longo.",
		"attribute_bonus": {}, "skills_fixed": [], "skills_expert": []
	}
}

static func has_data(id: String) -> bool:
	return DATA.has(id)

static func get_display_name(id: String) -> String:
	return DATA.get(id, {}).get("display_name", id)

static func get_description(id: String) -> String:
	return DATA.get(id, {}).get("description", "")

static func get_attribute_bonus(id: String) -> Dictionary:
	return DATA.get(id, {}).get("attribute_bonus", {})

static func get_skills_fixed(id: String) -> Array:
	return DATA.get(id, {}).get("skills_fixed", [])

static func get_skills_expert(id: String) -> Array:
	return DATA.get(id, {}).get("skills_expert", [])
