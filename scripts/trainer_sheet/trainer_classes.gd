class_name TrainersClasses
extends RefCounted
## Regras da Classe de Treinador (Livro de Regras, "Classes de Treinador").
## A classe é escolhida no nível 2 e dá acesso a 4 habilidades progressivas
## (níveis 2, 5, 9 e 15), além de perícias fixas e/ou escolhas.
##
## Chaves de cada entrada:
##   display_name    -> nome bonito para exibição (String)
##   skills_fixed    -> perícias garantidas pela classe (Array[Constants.Skill])
##   skills_choice   -> {"count": N, "options": Array | "all"} ou {} (sem escolha)
##   features        -> Array de {"level": int, "title": String, "text": String}
##                      (sempre 4, uma por nível de liberação)

const DATA := {
	"treinador_as": {
		"display_name": "Treinador Ás",
		"skills_fixed": [],
		"skills_choice": {},
		"features": [
			{
				"level": 2,
				"title": "Treinador Ás",
				"text": "Seu objetivo é se tornar um dos Treinadores mais fortes do mundo, e você se destaca em batalha. Todos os seus Pokémon recebem um bônus de +1 em suas rolagens de ataque e dano.",
			},
			{
				"level": 5,
				"title": "Mestre de Batalha",
				"text": "Você ganha um número de dados de batalha (d6) igual a 1 + seu modificador de Sabedoria (mínimo de 1). Você pode atribuir um desses dados a qualquer um de seus Pokémon para ser adicionado a uma única rolagem de ataque ou dano, após o resultado da rolagem inicial. Você repõe seu conjunto de dados de batalha a cada descanso longo.",
			},
			{
				"level": 9,
				"title": "Ritmo de Combate",
				"text": "Todos os seus Pokémon ganham mais 10 pés (3 metros) em seu deslocamento. Além disso, ao realizar uma rolagem de iniciativa, você pode rolar 1d6 adicional. Essa habilidade pode ser usada uma quantidade de vezes igual a 1 + seu modificador de Sabedoria (mínimo de 1) por descanso longo.",
			},
			{
				"level": 15,
				"title": "Troca Rápida",
				"text": "Você pode recolher e liberar Pokémon como uma ação bônus em vez de uma ação padrão. Você pode usar esse recurso um número de vezes igual a 1 + seu modificador de Sabedoria (mínimo de 1). Este conjunto é redefinido a cada descanso longo. Um Pokémon não pode ser trocado até o final de seu primeiro turno completo em combate (a menos que seja por meio de um item ou Move como Volt Switch, U-Turn, etc).",
			},
		],
	},
	"versatil": {
		"display_name": "Versátil",
		"skills_fixed": [],
		"skills_choice": {"count": 2, "options": "all"},
		"features": [
			{
				"level": 2,
				"title": "Versátil",
				"text": "Você escolhe experimentar uma variedade de habilidades para cuidar de seus Pokémon. Selecione uma especialização adicional e duas novas proficiências em perícias para o seu Treinador.",
			},
			{
				"level": 5,
				"title": "Apoiador",
				"text": "Você ganha um número de dados de habilidade (d6) igual a 1 + seu modificador de Sabedoria (mínimo de 1). Você pode atribuir um desses dados a qualquer um de seus Pokémon para ser adicionado a um único teste de perícia ou resistência, após o resultado do teste inicial. Você repõe seu conjunto de dados de habilidade a cada descanso longo.",
			},
			{
				"level": 9,
				"title": "Muitas Faces",
				"text": "Você pode escolher dois recursos de 2º nível ou um recurso de 5º ou 9º nível de qualquer outro caminho de Treinador.",
			},
			{
				"level": 15,
				"title": "Troca de Habilidade",
				"text": "Você é um mestre em ensinar novas estratégias a seus Pokémon para ajudar em batalha. A cada descanso longo, escolha um talento na seção Talentos para que todos os seus Pokémon o conheçam naquele dia. O talento pode ser alterado a cada descanso longo.",
			},
		],
	},
	"mentor_pokemon": {
		"display_name": "Mentor Pokémon",
		"skills_fixed": [],
		"skills_choice": {},
		"features": [
			{
				"level": 2,
				"title": "Mentor Pokémon",
				"text": "Você sabe como motivar seus aliados durante um combate. Uma vez por descanso curto, você pode usar uma ação bônus para impulsionar todos os Pokémon aliados com palavras inspiradoras. Até o seu próximo turno, você pode adicionar seu modificador de CAR (mínimo de 1) a todas as rolagens de ataque OU rolagens de dano OU CA de todos os Pokémon aliados.",
			},
			{
				"level": 5,
				"title": "Pokéchef",
				"text": "Você se destaca em criar refeições para seus Pokémon, aparentemente do nada. Você está frequentemente preparado com uma \"Guloseima Comestível\" para Pokémon, garantindo 2d4+2 pontos de vida temporários quando dado como uma ação. Você pode usar este recurso um número de vezes igual a 1 + seu modificador de Sabedoria. Esse recurso é redefinido a cada descanso longo. Uma Guloseima Comestível pode ser usada como item segurável, podendo ser ativado em combate com uma ação livre.",
			},
			{
				"level": 9,
				"title": "Tutor Capacitado",
				"text": "Você tem um toque de cuidado e habilidade para orientar o Pokémon a dar o melhor de si. Suas TMs podem ser usadas duas vezes antes de serem quebradas. Além disso, sua Guloseima Comestível do Pokéchef agora garante 2d8+4 pontos de vida temporários.",
			},
			{
				"level": 15,
				"title": "Tutor Mestre",
				"text": "Você se tornou um tutor Pokémon incrivelmente qualificado, e o aprendizado sob sua liderança é acelerado. A sua Guloseima Comestível do Pokéchef agora oferece 4d6+6 pontos de vida temporários. Além disso, ao consumi-la, o Pokémon também recebe Inspiração e 1d6 para ser usado em uma perícia ou teste de resistência. Você também se torna um verdadeiro Tutor Pokémon. Uma vez por descanso longo, você pode ensinar um Tutor Move a um Pokémon, desde que ele cumpra os requisitos necessários para aprendê-lo. O processo de ensino leva 1 hora de prática e concentração.",
			},
		],
	},
	"enfermeiro": {
		"display_name": "Enfermeiro",
		"skills_fixed": [Constants.Skill.MEDICINA],
		"skills_choice": {},
		"features": [
			{
				"level": 2,
				"title": "Enfermeiro",
				"text": "Você tem um coração puro e um espírito de cura. Você quer o melhor para seus Pokémon, e isso envolve mantê-los sempre em ótima forma. Ganhe proficiência na habilidade Medicina. Caso já seja proficiente, vira especialista. A cada descanso longo ou visita ao Centro Pokémon, escolha até 6 Pokémon para receberem pontos de vida temporários iguais ao seu nível de Treinador.",
			},
			{
				"level": 5,
				"title": "Coração Puro",
				"text": "Sua bondade irradia para todos ao seu redor. Você tem um poder de cura que é reabastecido quando você faz um descanso longo. Com uma ação, você pode tocar uma criatura voluntária e que não esteja incapacitada, e restaurar qualquer número de pontos de vida desta reserva. A reserva total é igual ao seu nível de Treinador x 5.",
			},
			{
				"level": 9,
				"title": "Espírito de Cura",
				"text": "Seu espírito de cura é transferido para o seu Pokémon. Sempre que você usar um consumível que cure um Pokémon, ou seu Pokémon usar um Move de cura, jogue os dados duas vezes e obtenha o resultado mais alto. Além disso, fora de combate, e até duas vezes por descanso longo, você pode curar 1 ponto de vida de um Pokémon incapacitado.",
			},
			{
				"level": 15,
				"title": "Alegria",
				"text": "Você ascendeu a um curador Pokémon definitivo. Uma vez por descanso longo, você pode gastar 1 hora para ganhar uma vantagem semelhante à de visitar um Centro Pokémon. Até seis Pokémon à sua escolha são totalmente curados de seus ferimentos e de todas as Condições de Status.",
			},
		],
	},
	"pesquisador": {
		"display_name": "Pesquisador",
		"skills_fixed": [],
		"skills_choice": {
			"count": 1,
			"options": [
				Constants.Skill.ARCANISMO,
				Constants.Skill.HISTORIA,
				Constants.Skill.INVESTIGACAO,
				Constants.Skill.NATUREZA,
				Constants.Skill.RELIGIAO,
			],
		},
		"features": [
			{
				"level": 2,
				"title": "Pesquisador",
				"text": "Você deseja aprender mais sobre Pokémon e os segredos que eles guardam. Escolha uma perícia entre Arcanismo, História, Investigação, Natureza ou Religião para se tornar proficiente. Caso já seja proficiente, vira especialista. Além disso, você se torna capaz de saber exatamente onde encontrar uma espécie Pokémon, caso ela esteja classificada como \"vista\" pela sua Pokédex. Por fim, seu Pokémon inicial é capaz de aprender pelo menos um Move do próximo nível em que receberia novos Moves.",
			},
			{
				"level": 5,
				"title": "Analista",
				"text": "Uma mente perspicaz permite que você note detalhes que passam despercebidos pelos outros. Você pode usar uma ação bônus para fazer um teste de Investigação CD 12 a fim de analisar um Pokémon, determinando seu nível, sua habilidade passiva e sua Natureza, conforme o Mestre definir. Além disso, todos os Pokémon aliados possuirão +2 na CA e nos testes de resistência contra o Pokémon analisado até o fim do combate. Você pode usar este recurso uma vez por descanso curto.",
			},
			{
				"level": 9,
				"title": "Especialista em Aprendizado",
				"text": "Sua compreensão dos segredos por trás da evolução dos Pokémon permite que você aprimore o processo. Todos os seus Pokémon recebem um Talento extra ao chegarem no nível 10. Além disso, você aprende com os erros. Sempre que um Pokémon aliado sofrer dano de um Move, você pode orientá-lo: se falhou em um teste de resistência, ele terá vantagem no próximo teste contra o mesmo Move; se o dano veio de um Move com jogada de acerto, o próximo ataque desse mesmo Move será feito com desvantagem. Após esse próximo uso, o efeito termina. Você pode usar este recurso um número de vezes igual a 1 + seu modificador de Inteligência (mínimo de 1) por descanso longo.",
			},
			{
				"level": 15,
				"title": "Preparação Estratégica",
				"text": "Você se torna um verdadeiro especialista em estudar adversários. Ao passar pelo menos 1 hora pesquisando um Treinador, organização, ou outro inimigo importante, faça um teste de Investigação. O resultado determina o que você descobre. CD 10: alguns Pokémon que esse adversário já possuiu; CD 15: até 2 Pokémon do time atual; CD 20: todo o time atual e o Move mais perigoso de cada; CD 25: todo o time e todos os Moves conhecidos. Caso obtenha CD 15 ou maior, todos os Pokémon aliados recebem +2 nas rolagens de ataque, dano e margem de crítico contra esse alvo até o fim do combate. Você pode usar esse recurso novamente após um descanso curto.",
			},
		],
	},
	"colecionador_pokemon": {
		"display_name": "Colecionador Pokémon",
		"skills_fixed": [],
		"skills_choice": {},
		"features": [
			{
				"level": 2,
				"title": "Colecionador Pokémon",
				"text": "Seu fascínio por todos os diferentes tipos de Pokémon do mundo impulsiona sua necessidade de colecionar todos eles. Você agora multiplica seu Bônus de Proficiência por 3 em seus testes de captura.",
			},
			{
				"level": 5,
				"title": "Tenho que Pegar Todos",
				"text": "Uma vez por descanso longo, você pode fazer um teste de captura com vantagem, mesmo que o oponente não esteja sofrendo uma condição de status negativa. Além disso, sempre que falhar numa captura, role um d4. Em um resultado de 4, você recupera a Pokébola perdida.",
			},
			{
				"level": 9,
				"title": "Especialista em Captura",
				"text": "Qualquer Pokémon que você capturar será instantaneamente curado de seus problemas de status e terá saúde plena. Você também pode adicionar seu modificador de Carisma a qualquer tentativa de captura. Somado a isso, você agora se tornou reconhecido por sua contribuição na coleta de dados através de sua Pokédex. Para cada 40 Pokémon completamente catalogados na sua Pokédex, você recebe recompensas especiais (role 2d6 e ganhe o brinde correspondente).",
			},
			{
				"level": 15,
				"title": "Ataques Disciplinados",
				"text": "Você treinou seu Pokémon para conter ou liberar poder quando necessário. Ao causar dano suficiente a um Pokémon para fazê-lo desmaiar, você pode escolher deixá-lo com 1 ponto de vida. Além disso, ao capturar um Pokémon, você pode rolar novamente a sua Natureza e escolher o resultado desejado.",
			},
		],
	},
	"comandante": {
		"display_name": "Comandante",
		"skills_fixed": [],
		"skills_choice": {},
		"features": [
			{
				"level": 2,
				"title": "Comandante",
				"text": "Você comanda seus Pokémon com punho de ferro, exigindo respeito e formando um vínculo inquebrável com sua equipe. A Lealdade do seu Pokémon inicial aumenta para \"Leal\". Além disso, qualquer novo Pokémon que você capturar receberá um bônus de +1 em Lealdade.",
			},
			{
				"level": 5,
				"title": "Líder Inspirador",
				"text": "Sua determinação inspira seus aliados a se prepararem para os desafios que virão. Ao gastar 10 minutos nessa inspiração, escolha até seis criaturas amistosas (incluindo você) a até 9 metros de distância que possam ver ou ouvir você. Cada criatura escolhida recebe pontos de vida temporários iguais ao seu nível + seu modificador de Carisma. Uma criatura não pode ganhar pontos de vida temporários por esta habilidade novamente até terminar um descanso curto ou longo.",
			},
			{
				"level": 9,
				"title": "Mostre-Me o Que Você Tem",
				"text": "Sua confiança e liderança inspira seus Pokémon a liberar um poder além do comum. Você pode escolher entre dois efeitos distintos: Dano Dobrado (uma vez por descanso longo, um de seus Pokémon pode dobrar todos os dados de dano de um de seus Moves, escolha antes de rolar o dano) ou Move de Nível Superior (uma vez por descanso curto, um de seus Pokémon pode ativar um único Move de um nível acima dos Moves que ele pode aprender atualmente). Você não pode utilizar os dois efeitos em um mesmo Move.",
			},
			{
				"level": 15,
				"title": "Somos Uma Equipe",
				"text": "Sua presença dominante é sentida por todos os Pokémon aliados no campo de batalha. Você pode usar uma ação bônus para falar uma frase de comando. Até o início do seu próximo turno, todos os Pokémon aliados a até 18 metros de você têm vantagem em seus ataques, e quaisquer criaturas que forem alvo de Moves danosos desses Pokémon realizam testes de resistência com desvantagem. Você pode usar esta característica um número de vezes igual a 1 + seu modificador de Carisma (mínimo de 1). Esta reserva é reiniciada a cada descanso longo.",
			},
		],
	},
	"patrulheiro": {
		"display_name": "Patrulheiro",
		"skills_fixed": [Constants.Skill.NATUREZA, Constants.Skill.SOBREVIVENCIA],
		"skills_choice": {},
		"features": [
			{
				"level": 2,
				"title": "Patrulheiro",
				"text": "Você se sente confortável na natureza e tem um incrível respeito pelos Pokémon em seu habitat natural. Ganhe proficiência em Natureza e Sobrevivência. Se você já era proficiente, você vira especialista (dobra o bônus de proficiência nas rolagens desta perícia). Além disso, sua velocidade de caminhada aumenta em 10 pés (3 metros).",
			},
			{
				"level": 5,
				"title": "Conexão Profunda",
				"text": "Você tem a habilidade inata de se comunicar com os Pokémon em um nível diferente dos outros. Você pode rolar testes de perícia com vantagem sempre que envolverem tentativas de entender o que um Pokémon está expressando ou querendo dizer, seja por gestos, sons ou emoções. Caso sua Região de Origem seja Alola, você entende essas intenções automaticamente, sem necessidade de testes. Além disso, você agora obtém ou se torna capaz de utilizar um equipamento chamado Capture Styler, capaz de criar uma conexão temporária com um Pokémon, fazendo com que ele coopere voluntariamente com você em tarefas e outras atividades. Para estabelecer essa conexão, faça um teste de Adestrar Animais contra uma CD baseada na atitude do Pokémon: CD 10 se ele for amistoso, CD 15 se estiver neutro e CD 20 se estiver incomodado. Pokémon enfurecidos precisam ser acalmados antes de aceitarem cooperar. Em caso de sucesso, o Pokémon permanecerá disposto a ajudá-lo por até 1 hora, aumentando essa duração em mais 1 hora para cada 5 pontos obtidos acima da CD. Você pode utilizar este recurso um número de vezes igual ao seu modificador de Sabedoria (mínimo de 1), recuperando todos os usos após um descanso longo.",
			},
			{
				"level": 9,
				"title": "Ligação Forte",
				"text": "Sua equipe Pokémon reconhece que estão juntos nesta jornada. Você pode criar vínculos com até dois Pokémon durante cada descanso longo. Além disso, você passa a dobrar seus bônus de proficiência ao utilizar a perícia Adestrar Animais para acalmar um Pokémon raivoso ou conquistar a amizade de um Pokémon neutro. Você também aprende um assobio característico, capaz de chamar todos os seus Pokémon fora da Pokébola em um raio de 200 metros.",
			},
			{
				"level": 15,
				"title": "Melhores Amigos",
				"text": "Você passa a agir em perfeita sintonia com seus Pokémon. Agora, você e eles podem dividir suas ações padrão, podendo agir simultaneamente enquanto ordena que seu Pokémon ataque. Você também pode usar sua ação padrão para acrescentar um bônus de +2 nas rolagens de acerto e dano de seu Pokémon nesta rodada.",
			},
		],
	},
	"capanga": {
		"display_name": "Capanga",
		"skills_fixed": [],
		"skills_choice": {},
		"features": [
			{
				"level": 2,
				"title": "Capanga",
				"text": "Seja membro atual ou aspirante de uma equipe maligna, seu objetivo é derrubar todos os Treinadores certinhos e subir nos escalões! Ganhe uma reserva de \"Pontos Sombrios\" igual ao seu nível. Sua reserva de pontos aumenta a cada nível e é redefinida a cada descanso longo. Você ganha acesso à habilidade \"Sabotagem\". Como reação, você pode gastar qualquer número de Pontos Sombrios para diminuir o resultado total de uma rolagem de ataque (incluindo modificadores) que atinge seu Pokémon, caso isso faça com que o ataque falhe. A rolagem de ataque natural não é afetada por esta habilidade para fins de efeitos secundários do Move, e os ataques com uma rolagem natural de 20 não podem ser diminuídos.",
			},
			{
				"level": 5,
				"title": "Encrenca em Dobro",
				"text": "Você conhece os meandros do que significa fazer parte de uma equipe maligna! Ganhe acesso à habilidade \"Vantagem Sombria\", que permite gastar 3 Pontos Sombrios para obter vantagem em qualquer teste de perícia, rolagem de ataque ou teste de resistência feito por você ou seu Pokémon. Além disso, sempre que um inimigo obtiver 1 natural em uma jogada de ataque contra um de seus Pokémon, você recupera 1 Ponto Sombrio gasto, e até o início do próximo turno desse inimigo todos os ataques contra ele serão feitos com vantagem.",
			},
			{
				"level": 9,
				"title": "Renda-se Agora",
				"text": "Você chegou aos escalões mais altos, comandando autoridade através de sua influência nas Artes das Sombras. Você ganha a habilidade \"Evasão Sinistra\". Como reação, você pode gastar 4 Pontos Sombrios para adicionar um nível de resistência a um Move que cause dano a um de seus Pokémon (Vulnerável → Neutro, Neutro → Resistente, Resistente → Imune).",
			},
			{
				"level": 15,
				"title": "Prepare-se para Lutar",
				"text": "Com a evolução das suas habilidades sombrias através do seu treino intenso, você e seus Pokémon aceitam a escuridão interior e a utilizam. Ganhe acesso à habilidade \"Copiar Meowth\", que permite gastar 5 Pontos Sombrios para qualquer um dos seus Pokémon invocar o Move \"Me First\".",
			},
		],
	},
	"tatico": {
		"display_name": "Tático",
		"skills_fixed": [],
		"skills_choice": {},
		"features": [
			{
				"level": 2,
				"title": "Tático",
				"text": "Você tem um olho para detalhes e um conjunto único de habilidades a serem usadas em batalha. Você ganha um conjunto de \"Pontos Táticos\" igual ao seu nível de Treinador. Sua reserva de pontos é reiniciada após cada descanso longo. Quando um Pokémon recupera pontos de vida através de um item ou Move, você pode aumentar a quantidade em 1d6 para cada \"Ponto Tático\" gasto.",
			},
			{
				"level": 5,
				"title": "Golpe Direcionado",
				"text": "Você sabe exatamente onde acertar um Pokémon para causar o dano máximo. Você pode gastar 2 \"Pontos Táticos\" para rolar o dano de um ataque duas vezes, obtendo o resultado mais alto.",
			},
			{
				"level": 9,
				"title": "Aumente Suas Defesas",
				"text": "Você é rapidamente capaz de sentir um golpe iminente em seu Pokémon. Quando seu Pokémon for alvo de um Move danoso, você pode usar uma reação para gastar seus \"Pontos Táticos\" e adicioná-los à CA ou a um teste de resistência do Pokémon, se isso fizer com que um ataque falhe, ou que você passe na CD do teste.",
			},
			{
				"level": 15,
				"title": "Não Dessa Vez",
				"text": "Seus Pokémon são treinados para serem implacáveis na batalha, nunca recuando. Depois que um oponente fizer um teste de resistência para um dos Moves do seu Pokémon, você poderá aumentar a CD em até 5 pontos se isso causar uma falha, gastando um \"Ponto Tático\" para cada aumento.",
			},
		],
	},
	"guru": {
		"display_name": "Guru",
		"skills_fixed": [Constants.Skill.PERSUASAO],
		"skills_choice": {},
		"features": [
			{
				"level": 2,
				"title": "Guru",
				"text": "Você e seus Pokémon estão conectados por mais do que apenas Treinador e fera. Ganhe proficiência na habilidade Persuasão. Se você já era proficiente, você vira especialista (dobra o bônus de proficiência nas rolagens desta perícia). Além disso, os Pokémon que ainda não podem ser controlados por você serão definidos no nível de lealdade \"Indiferente\" em vez de \"Desleal\" até que a Atualização de Controle seja alcançada.",
			},
			{
				"level": 5,
				"title": "Mente",
				"text": "Sua presença na batalha mantém seus Pokémon à vontade, para que eles possam se concentrar totalmente na tarefa em questão, sem distrações. Quando um de seus Pokémon realizar um teste de resistência de Sabedoria, ele pode adicionar o seu modificador de Sabedoria à jogada. Além disso, ao rolar um d20 para resistir ao efeito Confusão, seus Pokémon rolam duas vezes e ficam com o melhor resultado.",
			},
			{
				"level": 9,
				"title": "Corpo",
				"text": "Você treinou seu Pokémon para se concentrar profundamente em si mesmo e liberar todo o seu potencial. Todos os seus Pokémon passam a ter acesso a pelo menos duas Habilidades Passivas não ocultas, desde que possuam mais de uma. Se você obtiver a Habilidade Oculta de um Pokémon, ela substitui uma de suas Habilidades Passivas não ocultas. Porém, caso esse Pokémon possua apenas uma Habilidade Passiva não oculta, a Habilidade Oculta é adicionada em vez de substituí-la. Além disso, o talento Incansável pode ser aprendido por todos os seus Pokémon ao alcançarem o nível 10.",
			},
			{
				"level": 15,
				"title": "Espírito",
				"text": "A conexão com seu Pokémon é magistral. Treinador e fera movem-se juntos em perfeita harmonia. Você poderá controlar um Pokémon como se ele fosse uma extensão do seu corpo. No início do seu turno, você pode ativar esse recurso para adicionar seu modificador de SAB a todas as rolagens de ataque OU dano que seu Pokémon fizer até o início do seu próximo turno. Você pode usar esta característica um número de vezes igual a 1 + seu modificador de Sabedoria (mínimo de 1), reiniciando esta reserva a cada descanso longo. Além disso, seus Pokémon sabem como é a sua maneira de batalhar. Agora eles podem agir de forma autônoma, lutando como você faria, sem precisar de ordens diretas ou da sua presença no campo de batalha.",
			},
		],
	},
	"criador_pokemon": {
		"display_name": "Criador de Pokémon",
		"skills_fixed": [],
		"skills_choice": {},
		"features": [
			{
				"level": 2,
				"title": "Criador de Pokémon",
				"text": "Seu cuidado e delicadeza com os ovos Pokémon fazem com que os pequenos nasçam mais rapidamente em comparação aos de outros Treinadores. Sempre que você fizer uma rolagem para chocar um ovo Pokémon, você pode rolar 1d100 por hora para a incubação de um ovo. Quando um ovo choca, você pode rolar os IVs do seu Pokémon. IVs significam Valores Individuais, que são atributos ocultos, semelhantes a genes, que determinam o potencial de um Pokémon em um determinado atributo, variando de um mínimo de -2 e um máximo de +2. Para cada um dos seis atributos, role 1d20 recebendo um valor base no atributo de acordo com o valor da rolagem: 1) –2; 2 a 3) –1; 4 a 17) +0; 18 a 19) +1; 20) +2.",
			},
			{
				"level": 5,
				"title": "Cuidado e Carinho",
				"text": "Como Criador, você estudou a fundo os ovos de Pokémon e compreende exatamente o que cada espécie precisa para se desenvolver em um ambiente ideal. Sempre que rolar 1d100 para incubação, role o dado duas vezes e mantenha o maior resultado. Quando um ovo chocar, você pode jogar 1d6 para definir um atributo entre: 1) Força; 2) Destreza; 3) Constituição; 4) Inteligência; 5) Sabedoria; 6) Carisma. Você pode escolher se o IV sorteado será herdado ou não pelo filhote, optando entre o valor da mãe ou do pai. Seu bônus em testes para convencer Pokémon a se reproduzirem aumenta em +2. Além disso, ao chocar um ovo, você pode rolar a Natureza do filhote duas vezes e escolher o resultado desejado.",
			},
			{
				"level": 9,
				"title": "Boa Genética",
				"text": "Sua habilidade como Criador de Pokémon brilha, e as pessoas ao redor começam a notar o quanto seus Pokémon parecem ser mais fortes do que seus equivalentes típicos. Ao chocar um ovo, você pode escolher 1 atributo para possuir IV máximo, ou dar um talento a ele. Além disso, ao tentar criar um Pokémon Brilhante, a rolagem de sucesso no d100 passa a ser 91+ na reprodução com um dos pais Brilhantes ou 86+ com ambos.",
			},
			{
				"level": 15,
				"title": "Mestre dos Traços",
				"text": "Você é um mestre em seu ofício, capaz de criar um novo Pokémon com suas especificações perfeitas. Para qualquer Pokémon que chocar no futuro, você pode ignorar a rolagem e escolher a dedo o Gênero (dentre as opções), a Natureza e a Habilidade Passiva não oculta do Pokémon resultante (entre as opções disponíveis). Além disso, se algum de seus futuros Pokémon chocados herdar pelo menos um Egg Move, você poderá substituir o(s) Move(s) herdado(s) por qualquer outro(s) Move(s) de sua lista de Egg Moves. Você também pode escolher livremente quais IVs serão herdados pelo filhote, optando entre os valores do pai e da mãe.",
			},
		],
	},
}

static func has_data(id: String) -> bool:
	return DATA.has(id)

static func get_display_name(id: String) -> String:
	return DATA.get(id, {}).get("display_name", id)

static func get_skills_fixed(id: String) -> Array:
	return DATA.get(id, {}).get("skills_fixed", [])

## Retorna {"count": N, "options": Array | "all"} ou {} se a classe não escolhe.
static func get_skills_choice(id: String) -> Dictionary:
	return DATA.get(id, {}).get("skills_choice", {})

## Lista das 4 habilidades progressivas: Array[{"level": int, "title": String, "text": String}]
static func get_features(id: String) -> Array:
	return DATA.get(id, {}).get("features", [])

## Habilidades liberadas até (e incluindo) um certo nível.
static func get_unlocked_features(id: String, level: int) -> Array:
	var result := []
	for f in get_features(id):
		if f.get("level", 99) <= level:
			result.append(f)
	return result
