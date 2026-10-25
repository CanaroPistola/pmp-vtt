class_name ItemData
extends RefCounted
## Catálogo de itens do sistema (Livro de Regras, "Itens").
## Não é um sistema de loja — o jogador adiciona/remove itens manualmente.
## O `price` está aqui só como referência para o jogador descontar Pokédólares.
##
## Chaves de cada entrada:
##   display_name  -> nome de exibição
##   category      -> id de categoria (ver CATEGORIES abaixo)
##   price         -> preço em pokédolares (referência; -1 = não vendido)
##   description   -> texto curto mostrado no rodapé da mochila
##   effect        -> Dictionary cru com o efeito (interpretado em 3b/3c)
##   consumable    -> bool (decrementa no "Usar")
##
## Convenções:
##   - `effect.type`        -> verbo do efeito ("capture", "heal", "type_resist", ...)
##   - `effect.pokemon_type`-> tipo elemental quando o efeito precisa saber (Fogo, Água, ...)
##   - `effect.species` + `effect.variant` -> held items específicos por espécie
##   - Todas as unidades de distância são em metros (m).

## Ordem das categorias na sidebar da Mochila.
## "todos" é virtual (mostra tudo), as outras são reais.
const CATEGORIES := [
	{"id": "todos",       "display_name": "Todos"},
	{"id": "pokebola",    "display_name": "Pokébolas"},
	{"id": "cura",        "display_name": "Itens de Cura"},
	{"id": "status",      "display_name": "Itens de Status"},
	{"id": "batalha",     "display_name": "Itens de Batalha"},
	{"id": "vitamina",    "display_name": "Vitaminas"},
	{"id": "berry",       "display_name": "Berries"},
	{"id": "evolutivo",   "display_name": "Itens Evolutivos"},
	{"id": "held",        "display_name": "Itens Seguráveis"},
	{"id": "chave",       "display_name": "Itens-Chave"},
	{"id": "vestimenta",  "display_name": "Vestimentas"},
	{"id": "pacote",      "display_name": "Pacotes Iniciais"},
	{"id": "treinador",   "display_name": "Equipamento de Treinador"},
	{"id": "tesouro",     "display_name": "Tesouros"},
	{"id": "fossil",      "display_name": "Fósseis"},
	{"id": "tm",          "display_name": "TMs"},
]

const DATA := {
	# ============================================================
	# POKÉBOLAS
	# ============================================================
	"poke_ball": {
		"display_name": "Poké Ball", "category": "pokebola", "price": 250,
		"description": "+0 na Rolagem de Captura.",
		"effect": {"type": "capture", "bonus": 0}, "consumable": true,
	},
	"great_ball": {
		"display_name": "Great Ball", "category": "pokebola", "price": 500,
		"description": "+5 na Rolagem de Captura.",
		"effect": {"type": "capture", "bonus": 5}, "consumable": true,
	},
	"ultra_ball": {
		"display_name": "Ultra Ball", "category": "pokebola", "price": 1000,
		"description": "+10 na Rolagem de Captura.",
		"effect": {"type": "capture", "bonus": 10}, "consumable": true,
	},
	"level_ball": {
		"display_name": "Level Ball", "category": "pokebola", "price": 800,
		"description": "+10 na Rolagem de Captura para cada 5 níveis que o Pokémon alvo tiver a menos que o Pokémon ativo, até um máximo de +30.",
		"effect": {"type": "capture", "bonus": "conditional", "condition": "level_diff"}, "consumable": true,
	},
	"net_ball": {
		"display_name": "Net Ball", "category": "pokebola", "price": 800,
		"description": "+15 na Rolagem de Captura contra Pokémon dos tipos Inseto ou Água.",
		"effect": {"type": "capture", "bonus": 15, "condition": "type_bug_water"}, "consumable": true,
	},
	"nest_ball": {
		"display_name": "Nest Ball", "category": "pokebola", "price": 800,
		"description": "+15 na Rolagem de Captura contra Pokémon de nível 5 ou abaixo.",
		"effect": {"type": "capture", "bonus": 15, "condition": "level_5_or_less"}, "consumable": true,
	},
	"repeat_ball": {
		"display_name": "Repeat Ball", "category": "pokebola", "price": 800,
		"description": "+15 na Rolagem de Captura contra espécies já capturadas pelo usuário.",
		"effect": {"type": "capture", "bonus": 15, "condition": "already_caught"}, "consumable": true,
	},
	"luxury_ball": {
		"display_name": "Luxury Ball", "category": "pokebola", "price": 800,
		"description": "+5 na Rolagem de Captura. Define o nível de Lealdade para +1 após a captura.",
		"effect": {"type": "capture", "bonus": 5, "set_loyalty": 1}, "consumable": true,
	},
	"dive_ball": {
		"display_name": "Dive Ball", "category": "pokebola", "price": 800,
		"description": "+15 na Rolagem de Captura contra Pokémon que se encontram dentro d'água.",
		"effect": {"type": "capture", "bonus": 15, "condition": "underwater"}, "consumable": true,
	},
	"dusk_ball": {
		"display_name": "Dusk Ball", "category": "pokebola", "price": 800,
		"description": "+15 na Rolagem de Captura à noite ou em lugares escuros como cavernas.",
		"effect": {"type": "capture", "bonus": 15, "condition": "night_or_dark"}, "consumable": true,
	},
	"moon_ball": {
		"display_name": "Moon Ball", "category": "pokebola", "price": 1000,
		"description": "+20 na Rolagem de Captura contra Pokémon que evoluem com a Moon Stone.",
		"effect": {"type": "capture", "bonus": 20, "condition": "moon_stone_evolution"}, "consumable": true,
	},
	"heal_ball": {
		"display_name": "Heal Ball", "category": "pokebola", "price": 1000,
		"description": "+5 na Rolagem de Captura. Restaura a saúde do Pokémon capturado e cura todas as condições de status.",
		"effect": {"type": "capture", "bonus": 5, "heal_on_capture": true}, "consumable": true,
	},
	"timer_ball": {
		"display_name": "Timer Ball", "category": "pokebola", "price": 1200,
		"description": "+2 na Rolagem de Captura para cada rodada de combate que passou antes de lançar (máximo de +20).",
		"effect": {"type": "capture", "bonus": "conditional", "condition": "rounds_passed"}, "consumable": true,
	},
	"premier_ball": {
		"display_name": "Premier Ball", "category": "pokebola", "price": 1200,
		"description": "+5 na Rolagem de Captura. Aumenta o Carisma do Pokémon permanentemente em +2.",
		"effect": {"type": "capture", "bonus": 5, "permanent_cha": 2}, "consumable": true,
	},
	"quick_ball": {
		"display_name": "Quick Ball", "category": "pokebola", "price": 1200,
		"description": "+20 na Rolagem de Captura apenas se usado na primeira rodada do combate.",
		"effect": {"type": "capture", "bonus": 20, "condition": "first_round"}, "consumable": true,
	},
	"lure_ball": {
		"display_name": "Lure Ball", "category": "pokebola", "price": 1200,
		"description": "+20 na Rolagem de Captura contra Pokémon pescados por você.",
		"effect": {"type": "capture", "bonus": 20, "condition": "fished"}, "consumable": true,
	},
	"love_ball": {
		"display_name": "Love Ball", "category": "pokebola", "price": 1300,
		"description": "+30 na Rolagem de Captura contra um Pokémon alvo da mesma espécie que o Pokémon ativo, porém do gênero oposto.",
		"effect": {"type": "capture", "bonus": 30, "condition": "opposite_gender_same_species"}, "consumable": true,
	},
	"heavy_ball": {
		"display_name": "Heavy Ball", "category": "pokebola", "price": 2000,
		"description": "+5 na Rolagem de Captura contra Pokémon de tamanho Médio, e mais 5 para cada escala de tamanho acima.",
		"effect": {"type": "capture", "bonus": "conditional", "condition": "size"}, "consumable": true,
	},
	"beast_ball": {
		"display_name": "Beast Ball", "category": "pokebola", "price": -1,
		"description": "+20 na Rolagem de Captura contra um Pokémon Ultra Beast.",
		"effect": {"type": "capture", "bonus": 20, "condition": "ultra_beast"}, "consumable": true,
	},
	"master_ball": {
		"display_name": "Master Ball", "category": "pokebola", "price": -1,
		"description": "Sucesso automático na Rolagem de Captura.",
		"effect": {"type": "capture", "auto_success": true}, "consumable": true,
	},

	# ============================================================
	# ITENS DE CURA
	# ============================================================
	"pocao": {
		"display_name": "Poção", "category": "cura", "price": 200,
		"description": "Restaura 2d4+2 PV.",
		"effect": {"type": "heal", "dice": "2d4+2"}, "consumable": true,
	},
	"pocao_super": {
		"display_name": "Poção Super", "category": "cura", "price": 500,
		"description": "Restaura 3d6+6 PV.",
		"effect": {"type": "heal", "dice": "3d6+6"}, "consumable": true,
	},
	"pocao_hyper": {
		"display_name": "Poção Hyper", "category": "cura", "price": 800,
		"description": "Restaura 4d12+10 PV.",
		"effect": {"type": "heal", "dice": "4d12+10"}, "consumable": true,
	},
	"revive": {
		"display_name": "Revive", "category": "cura", "price": 450,
		"description": "Revive um Pokémon desmaiado e cura 2d4+2 PV.",
		"effect": {"type": "revive", "dice": "2d4+2"}, "consumable": true,
	},
	"max_revive": {
		"display_name": "Max Revive", "category": "cura", "price": 3000,
		"description": "Revive um Pokémon desmaiado e cura 4d12+10 PV.",
		"effect": {"type": "revive", "dice": "4d12+10"}, "consumable": true,
	},
	"ether": {
		"display_name": "Ether", "category": "cura", "price": 500,
		"description": "Restaura 5 PP para um único Move.",
		"effect": {"type": "restore_pp", "amount": 5, "scope": "single"}, "consumable": true,
	},
	"max_ether": {
		"display_name": "Max Ether", "category": "cura", "price": 900,
		"description": "Restaura 10 PP para um único Move.",
		"effect": {"type": "restore_pp", "amount": 10, "scope": "single"}, "consumable": true,
	},
	"elixir": {
		"display_name": "Elixir", "category": "cura", "price": 1800,
		"description": "Restaura 5 PP para todos os Moves.",
		"effect": {"type": "restore_pp", "amount": 5, "scope": "all"}, "consumable": true,
	},
	"max_elixir": {
		"display_name": "Max Elixir", "category": "cura", "price": 3200,
		"description": "Restaura 10 PP para todos os Moves.",
		"effect": {"type": "restore_pp", "amount": 10, "scope": "all"}, "consumable": true,
	},
	"sacred_ash": {
		"display_name": "Sacred Ash", "category": "cura", "price": 10000,
		"description": "Restaura completamente os PV de todos os Pokémon desmaiados carregados pelo Treinador. Apenas utilizável fora de batalha.",
		"effect": {"type": "full_heal_all", "only_out_of_battle": true}, "consumable": true,
	},
	"candy_bar": {
		"display_name": "Candy Bar", "category": "cura", "price": 450,
		"description": "Restaura 5 PV.",
		"effect": {"type": "heal", "flat": 5}, "consumable": true,
	},
	"berry_juice": {
		"display_name": "Berry Juice", "category": "cura", "price": 1000,
		"description": "Restaura 10 PV.",
		"effect": {"type": "heal", "flat": 10}, "consumable": true,
	},
	"fresh_water": {
		"display_name": "Fresh Water", "category": "cura", "price": 1000,
		"description": "Restaura 15 PV.",
		"effect": {"type": "heal", "flat": 15}, "consumable": true,
	},
	"soda_pop": {
		"display_name": "Soda Pop", "category": "cura", "price": 1000,
		"description": "Restaura 25 PV.",
		"effect": {"type": "heal", "flat": 25}, "consumable": true,
	},
	"lemonade": {
		"display_name": "Lemonade", "category": "cura", "price": 1000,
		"description": "Restaura 35 PV.",
		"effect": {"type": "heal", "flat": 35}, "consumable": true,
	},
	"moomoo_milk": {
		"display_name": "MooMoo Milk", "category": "cura", "price": 1000,
		"description": "Restaura 50 PV.",
		"effect": {"type": "heal", "flat": 50}, "consumable": true,
	},
	"energy_powder": {
		"display_name": "Energy Powder", "category": "cura", "price": 150,
		"description": "Restaura 3d6+6 PV. 1/4 de chance de diminuir a Lealdade em 1.",
		"effect": {"type": "heal", "dice": "3d6+6", "loyalty_risk": 0.25}, "consumable": true,
	},
	"energy_root": {
		"display_name": "Energy Root", "category": "cura", "price": 200,
		"description": "Restaura 4d12+10 PV. 1/4 de chance de diminuir a Lealdade em 1.",
		"effect": {"type": "heal", "dice": "4d12+10", "loyalty_risk": 0.25}, "consumable": true,
	},
	"heal_powder": {
		"display_name": "Heal Powder", "category": "cura", "price": 275,
		"description": "Cura todas as condições de status. 1/4 de chance de diminuir a Lealdade em 1.",
		"effect": {"type": "cure_status", "status": "all", "loyalty_risk": 0.25}, "consumable": true,
	},
	"revival_herb": {
		"display_name": "Revival Herb", "category": "cura", "price": 1200,
		"description": "Revive Pokémon desmaiados e cura 4d12+10 PV. 1/4 de chance de diminuir a Lealdade em 1.",
		"effect": {"type": "revive", "dice": "4d12+10", "loyalty_risk": 0.25}, "consumable": true,
	},

	# ============================================================
	# ITENS DE STATUS
	# ============================================================
	"antidote": {
		"display_name": "Antidote", "category": "status", "price": 200,
		"description": "Cura instantaneamente um Pokémon do status Envenenado ou Gravemente Envenenado.",
		"effect": {"type": "cure_status", "status": ["poisoned", "badly_poisoned"]}, "consumable": true,
	},
	"paralyze_heal": {
		"display_name": "Paralyze Heal", "category": "status", "price": 200,
		"description": "Cura instantaneamente um Pokémon do status Paralisado.",
		"effect": {"type": "cure_status", "status": ["paralyzed"]}, "consumable": true,
	},
	"burn_heal": {
		"display_name": "Burn Heal", "category": "status", "price": 200,
		"description": "Cura instantaneamente um Pokémon do status Queimado.",
		"effect": {"type": "cure_status", "status": ["burned"]}, "consumable": true,
	},
	"ice_heal": {
		"display_name": "Ice Heal", "category": "status", "price": 200,
		"description": "Cura instantaneamente um Pokémon do status Congelado.",
		"effect": {"type": "cure_status", "status": ["frozen"]}, "consumable": true,
	},
	"awakening": {
		"display_name": "Awakening", "category": "status", "price": 200,
		"description": "Acorda instantaneamente um Pokémon do status Sonolento ou Dormindo.",
		"effect": {"type": "cure_status", "status": ["drowsy", "asleep"]}, "consumable": true,
	},
	"full_heal": {
		"display_name": "Full Heal", "category": "status", "price": 450,
		"description": "Cura todas as condições de status e concede imunidade a elas por uma rodada.",
		"effect": {"type": "cure_status", "status": "all", "immunity_one_round": true}, "consumable": true,
	},
	"lava_cookie": {
		"display_name": "Lava Cookie", "category": "status", "price": 200,
		"description": "Cura todas as condições de status.",
		"effect": {"type": "cure_status", "status": "all"}, "consumable": true,
	},
	"mighty_candy": {
		"display_name": "Mighty Candy", "category": "status", "price": 1000,
		"description": "Aumenta a FOR em +2 por 1 minuto.",
		"effect": {"type": "stat_buff", "stat": "str", "amount": 2, "duration_sec": 60}, "consumable": true,
	},
	"quick_candy": {
		"display_name": "Quick Candy", "category": "status", "price": 1000,
		"description": "Aumenta a DES em +2 por 1 minuto.",
		"effect": {"type": "stat_buff", "stat": "dex", "amount": 2, "duration_sec": 60}, "consumable": true,
	},
	"health_candy": {
		"display_name": "Health Candy", "category": "status", "price": 1000,
		"description": "Concede 20 PV temporários por 1 minuto.",
		"effect": {"type": "temp_hp", "amount": 20, "duration_sec": 60}, "consumable": true,
	},
	"smart_candy": {
		"display_name": "Smart Candy", "category": "status", "price": 1000,
		"description": "Aumenta a INT em +2 por 1 minuto.",
		"effect": {"type": "stat_buff", "stat": "int", "amount": 2, "duration_sec": 60}, "consumable": true,
	},
	"tough_candy": {
		"display_name": "Tough Candy", "category": "status", "price": 1000,
		"description": "Aumenta a CA em +2 por 1 minuto.",
		"effect": {"type": "ac_buff", "amount": 2, "duration_sec": 60}, "consumable": true,
	},
	"courage_candy": {
		"display_name": "Courage Candy", "category": "status", "price": 1000,
		"description": "Aumenta a SAB em +2 por 1 minuto.",
		"effect": {"type": "stat_buff", "stat": "wis", "amount": 2, "duration_sec": 60}, "consumable": true,
	},

	# ============================================================
	# ITENS DE BATALHA (Itens-X)
	# ============================================================
	"x_attack": {
		"display_name": "X Attack", "category": "batalha", "price": 350,
		"description": "Aumenta o Ataque em 2 estágios.",
		"effect": {"type": "stat_boost", "stat": "atk", "stages": 2}, "consumable": true,
	},
	"x_defense": {
		"display_name": "X Defense", "category": "batalha", "price": 350,
		"description": "Aumenta a Defesa em 2 estágios.",
		"effect": {"type": "stat_boost", "stat": "def", "stages": 2}, "consumable": true,
	},
	"x_special_attack": {
		"display_name": "X Special Attack", "category": "batalha", "price": 350,
		"description": "Aumenta o Ataque Especial em 2 estágios.",
		"effect": {"type": "stat_boost", "stat": "spa", "stages": 2}, "consumable": true,
	},
	"x_special_defense": {
		"display_name": "X Special Defense", "category": "batalha", "price": 350,
		"description": "Aumenta a Defesa Especial em 2 estágios.",
		"effect": {"type": "stat_boost", "stat": "spd", "stages": 2}, "consumable": true,
	},
	"x_speed": {
		"display_name": "X Speed", "category": "batalha", "price": 350,
		"description": "Aumenta a Velocidade em 2 estágios.",
		"effect": {"type": "stat_boost", "stat": "spe", "stages": 2}, "consumable": true,
	},
	"x_accuracy": {
		"display_name": "X Accuracy", "category": "batalha", "price": 350,
		"description": "Aumenta a Precisão em 2 estágios.",
		"effect": {"type": "stat_boost", "stat": "acc", "stages": 2}, "consumable": true,
	},
	"dire_hit": {
		"display_name": "Dire Hit", "category": "batalha", "price": 400,
		"description": "Aumenta a margem de crítico em 1 estágio.",
		"effect": {"type": "stat_boost", "stat": "crit", "stages": 1}, "consumable": true,
	},
	"guard_spec": {
		"display_name": "Guard Spec", "category": "batalha", "price": 700,
		"description": "Previne reduções nas mudanças de status por 5 rodadas.",
		"effect": {"type": "prevent_stat_drop", "duration": 5}, "consumable": true,
	},

	# ============================================================
	# VITAMINAS
	# ============================================================
	"protein": {
		"display_name": "Protein", "category": "vitamina", "price": 4900,
		"description": "Recebe imediatamente 2 Pontos de EV em FOR.",
		"effect": {"type": "ev", "stat": "str", "amount": 2}, "consumable": true,
	},
	"carbos": {
		"display_name": "Carbos", "category": "vitamina", "price": 4900,
		"description": "Recebe imediatamente 2 Pontos de EV em DES.",
		"effect": {"type": "ev", "stat": "dex", "amount": 2}, "consumable": true,
	},
	"iron": {
		"display_name": "Iron", "category": "vitamina", "price": 4900,
		"description": "Recebe imediatamente 2 Pontos de EV em CON.",
		"effect": {"type": "ev", "stat": "con", "amount": 2}, "consumable": true,
	},
	"zinc": {
		"display_name": "Zinc", "category": "vitamina", "price": 4900,
		"description": "Recebe imediatamente 2 Pontos de EV em SAB.",
		"effect": {"type": "ev", "stat": "wis", "amount": 2}, "consumable": true,
	},
	"calcium": {
		"display_name": "Calcium", "category": "vitamina", "price": 4900,
		"description": "Recebe imediatamente 2 Pontos de EV em CAR.",
		"effect": {"type": "ev", "stat": "cha", "amount": 2}, "consumable": true,
	},
	"hp_up": {
		"display_name": "HP Up", "category": "vitamina", "price": 8800,
		"description": "Aumenta o PV máximo em um valor igual ao resultado máximo do seu dado de vida. Pode ser usado até 3x em um único Pokémon.",
		"effect": {"type": "max_hp_bonus", "uses_max": 3}, "consumable": true,
	},
	"pp_up": {
		"display_name": "PP Up", "category": "vitamina", "price": 8800,
		"description": "Aumenta o máximo de PP de um Move em 2. Pode ser usado até 3x em um único Move.",
		"effect": {"type": "max_pp_bonus", "amount": 2, "uses_max": 3}, "consumable": true,
	},

	# ============================================================
	# BERRIES
	# ============================================================
	"cheri_berry": {
		"display_name": "Cheri Berry", "category": "berry", "price": 150,
		"description": "Cura paralisia. Ativado quando o Pokémon fica paralisado.",
		"effect": {"type": "cure_status", "status": ["paralyzed"], "trigger": "on_paralysis"}, "consumable": true,
	},
	"chesto_berry": {
		"display_name": "Chesto Berry", "category": "berry", "price": 150,
		"description": "Acorda da condição sonolento ou dormindo.",
		"effect": {"type": "cure_status", "status": ["drowsy", "asleep"], "trigger": "on_sleep"}, "consumable": true,
	},
	"pecha_berry": {
		"display_name": "Pecha Berry", "category": "berry", "price": 150,
		"description": "Cura envenenamento. Ativado quando o Pokémon é envenenado ou gravemente envenenado.",
		"effect": {"type": "cure_status", "status": ["poisoned", "badly_poisoned"], "trigger": "on_poison"}, "consumable": true,
	},
	"rawst_berry": {
		"display_name": "Rawst Berry", "category": "berry", "price": 150,
		"description": "Cura queimadura. Ativado quando o Pokémon é queimado.",
		"effect": {"type": "cure_status", "status": ["burned"], "trigger": "on_burn"}, "consumable": true,
	},
	"aspear_berry": {
		"display_name": "Aspear Berry", "category": "berry", "price": 150,
		"description": "Cura congelamento. Ativado quando o Pokémon é congelado.",
		"effect": {"type": "cure_status", "status": ["frozen"], "trigger": "on_freeze"}, "consumable": true,
	},
	"leppa_berry": {
		"display_name": "Leppa Berry", "category": "berry", "price": 400,
		"description": "Restaura 10 PP para um Move. Ativado quando o Pokémon fica sem PP para um Move.",
		"effect": {"type": "restore_pp", "amount": 10, "trigger": "on_pp_empty"}, "consumable": true,
	},
	"oran_berry": {
		"display_name": "Oran Berry", "category": "berry", "price": 100,
		"description": "Restaura 2d4+2 PV. Ativado quando o Pokémon cai abaixo de 50% de PV.",
		"effect": {"type": "heal", "dice": "2d4+2", "trigger": "below_50_hp"}, "consumable": true,
	},
	"persim_berry": {
		"display_name": "Persim Berry", "category": "berry", "price": 150,
		"description": "Cura confusão. Ativado quando o Pokémon fica confuso.",
		"effect": {"type": "cure_confusion", "trigger": "on_confusion"}, "consumable": true,
	},
	"lum_berry": {
		"display_name": "Lum Berry", "category": "berry", "price": 300,
		"description": "Cura qualquer condição de status negativa.",
		"effect": {"type": "cure_status", "status": "all", "trigger": "on_any_status"}, "consumable": true,
	},
	"sitrus_berry": {
		"display_name": "Sitrus Berry", "category": "berry", "price": 250,
		"description": "Restaura 5d6 PV. Ativado quando o Pokémon cai abaixo de 50% de PV.",
		"effect": {"type": "heal", "dice": "5d6", "trigger": "below_50_hp"}, "consumable": true,
	},
	"figy_berry": {
		"display_name": "Figy Berry", "category": "berry", "price": 350,
		"description": "Restaura 5d10 PV abaixo de 25% de PV; confunde naturezas Sério, Tímido, Sereno, Teimoso.",
		"effect": {"type": "heal", "dice": "5d10", "trigger": "below_25_hp", "confuse_natures": ["serious", "timid", "calm", "bold"]}, "consumable": true,
	},
	"wiki_berry": {
		"display_name": "Wiki Berry", "category": "berry", "price": 350,
		"description": "Restaura 5d10 PV abaixo de 25% de PV; confunde naturezas Determinado, Alegre, Prudente, Travesso.",
		"effect": {"type": "heal", "dice": "5d10", "trigger": "below_25_hp", "confuse_natures": ["adamant", "jolly", "careful", "impish"]}, "consumable": true,
	},
	"mago_berry": {
		"display_name": "Mago Berry", "category": "berry", "price": 350,
		"description": "Restaura 5d10 PV abaixo de 25% de PV; confunde naturezas Corajoso, Sábio, Arrogante, Preguiçoso.",
		"effect": {"type": "heal", "dice": "5d10", "trigger": "below_25_hp", "confuse_natures": ["brave", "naughty", "lonely", "lax"]}, "consumable": true,
	},
	"aguav_berry": {
		"display_name": "Aguav Berry", "category": "berry", "price": 350,
		"description": "Restaura 5d10 PV abaixo de 25% de PV; confunde naturezas Energético, Impulsivo, Ingênuo, Curioso.",
		"effect": {"type": "heal", "dice": "5d10", "trigger": "below_25_hp", "confuse_natures": ["naive", "impish", "timid", "hasty"]}, "consumable": true,
	},
	"iapapa_berry": {
		"display_name": "Iapapa Berry", "category": "berry", "price": 350,
		"description": "Restaura 5d10 PV abaixo de 25% de PV; confunde naturezas Apático, Astuto, Sociável, Apressado.",
		"effect": {"type": "heal", "dice": "5d10", "trigger": "below_25_hp", "confuse_natures": ["careful", "sassy", "docile", "hasty"]}, "consumable": true,
	},
	"pomeg_berry": {
		"display_name": "Pomeg Berry", "category": "berry", "price": 500,
		"description": "Reduz CON em 2 até o próximo descanso longo; aumenta Lealdade em 1. Permite redistribuir EV investidos.",
		"effect": {"type": "ev_redistribute", "stat": "con", "amount": 2, "loyalty": 1}, "consumable": true,
	},
	"kelpsy_berry": {
		"display_name": "Kelpsy Berry", "category": "berry", "price": 500,
		"description": "Reduz FOR em 2 até o próximo descanso longo; aumenta Lealdade em 1. Permite redistribuir EV investidos.",
		"effect": {"type": "ev_redistribute", "stat": "str", "amount": 2, "loyalty": 1}, "consumable": true,
	},
	"qualot_berry": {
		"display_name": "Qualot Berry", "category": "berry", "price": 500,
		"description": "Reduz CA em 2 até o próximo descanso longo; aumenta Lealdade em 1.",
		"effect": {"type": "stat_penalty_temp", "stat": "ac", "amount": 2, "loyalty": 1}, "consumable": true,
	},
	"hondew_berry": {
		"display_name": "Hondew Berry", "category": "berry", "price": 500,
		"description": "Reduz DES em 2 até o próximo descanso longo; aumenta Lealdade em 1. Permite redistribuir EV investidos.",
		"effect": {"type": "ev_redistribute", "stat": "dex", "amount": 2, "loyalty": 1}, "consumable": true,
	},
	"grepa_berry": {
		"display_name": "Grepa Berry", "category": "berry", "price": 500,
		"description": "Reduz SAB em 2 até o próximo descanso longo; aumenta Lealdade em 1. Permite redistribuir EV investidos.",
		"effect": {"type": "ev_redistribute", "stat": "wis", "amount": 2, "loyalty": 1}, "consumable": true,
	},
	"tomato_berry": {
		"display_name": "Tomato Berry", "category": "berry", "price": 500,
		"description": "Reduz o deslocamento em 3 metros até o próximo descanso longo; aumenta Lealdade em 1.",
		"effect": {"type": "movement_penalty_temp", "amount_m": 3, "loyalty": 1}, "consumable": true,
	},
	"razz_berry": {
		"display_name": "Razz Berry", "category": "berry", "price": 1000,
		"description": "Quando segurado em combate, o Treinador ganha +1 nas tentativas de captura. (Não consumível)",
		"effect": {"type": "capture_boost_held", "bonus": 1}, "consumable": false,
	},
	# --- Berries de resistência de tipo ---
	"occa_berry": {
		"display_name": "Occa Berry", "category": "berry", "price": 200,
		"description": "Pokémon sofre metade do dano de um Move do tipo Fogo. Ativado ao receber o dano.",
		"effect": {"type": "type_resist", "pokemon_type": "fire", "mult": 0.5, "trigger": "on_damage"}, "consumable": true,
	},
	"passho_berry": {
		"display_name": "Passho Berry", "category": "berry", "price": 200,
		"description": "Pokémon sofre metade do dano de um Move do tipo Água. Ativado ao receber o dano.",
		"effect": {"type": "type_resist", "pokemon_type": "water", "mult": 0.5, "trigger": "on_damage"}, "consumable": true,
	},
	"wacan_berry": {
		"display_name": "Wacan Berry", "category": "berry", "price": 200,
		"description": "Pokémon sofre metade do dano de um Move do tipo Elétrico. Ativado ao receber o dano.",
		"effect": {"type": "type_resist", "pokemon_type": "electric", "mult": 0.5, "trigger": "on_damage"}, "consumable": true,
	},
	"rindo_berry": {
		"display_name": "Rindo Berry", "category": "berry", "price": 200,
		"description": "Pokémon sofre metade do dano de um Move do tipo Grama. Ativado ao receber o dano.",
		"effect": {"type": "type_resist", "pokemon_type": "grass", "mult": 0.5, "trigger": "on_damage"}, "consumable": true,
	},
	"yache_berry": {
		"display_name": "Yache Berry", "category": "berry", "price": 200,
		"description": "Pokémon sofre metade do dano de um Move do tipo Gelo. Ativado ao receber o dano.",
		"effect": {"type": "type_resist", "pokemon_type": "ice", "mult": 0.5, "trigger": "on_damage"}, "consumable": true,
	},
	"chople_berry": {
		"display_name": "Chople Berry", "category": "berry", "price": 200,
		"description": "Pokémon sofre metade do dano de um Move do tipo Lutador. Ativado ao receber o dano.",
		"effect": {"type": "type_resist", "pokemon_type": "fighting", "mult": 0.5, "trigger": "on_damage"}, "consumable": true,
	},
	"kebia_berry": {
		"display_name": "Kebia Berry", "category": "berry", "price": 200,
		"description": "Pokémon sofre metade do dano de um Move do tipo Venenoso. Ativado ao receber o dano.",
		"effect": {"type": "type_resist", "pokemon_type": "poison", "mult": 0.5, "trigger": "on_damage"}, "consumable": true,
	},
	"shuca_berry": {
		"display_name": "Shuca Berry", "category": "berry", "price": 200,
		"description": "Pokémon sofre metade do dano de um Move do tipo Terra. Ativado ao receber o dano.",
		"effect": {"type": "type_resist", "pokemon_type": "ground", "mult": 0.5, "trigger": "on_damage"}, "consumable": true,
	},
	"coba_berry": {
		"display_name": "Coba Berry", "category": "berry", "price": 200,
		"description": "Pokémon sofre metade do dano de um Move do tipo Voador. Ativado ao receber o dano.",
		"effect": {"type": "type_resist", "pokemon_type": "flying", "mult": 0.5, "trigger": "on_damage"}, "consumable": true,
	},
	"payapa_berry": {
		"display_name": "Payapa Berry", "category": "berry", "price": 200,
		"description": "Pokémon sofre metade do dano de um Move do tipo Psíquico. Ativado ao receber o dano.",
		"effect": {"type": "type_resist", "pokemon_type": "psychic", "mult": 0.5, "trigger": "on_damage"}, "consumable": true,
	},
	"tanga_berry": {
		"display_name": "Tanga Berry", "category": "berry", "price": 200,
		"description": "Pokémon sofre metade do dano de um Move do tipo Inseto. Ativado ao receber o dano.",
		"effect": {"type": "type_resist", "pokemon_type": "bug", "mult": 0.5, "trigger": "on_damage"}, "consumable": true,
	},
	"charti_berry": {
		"display_name": "Charti Berry", "category": "berry", "price": 200,
		"description": "Pokémon sofre metade do dano de um Move do tipo Pedra. Ativado ao receber o dano.",
		"effect": {"type": "type_resist", "pokemon_type": "rock", "mult": 0.5, "trigger": "on_damage"}, "consumable": true,
	},
	"kasib_berry": {
		"display_name": "Kasib Berry", "category": "berry", "price": 200,
		"description": "Pokémon sofre metade do dano de um Move do tipo Fantasma. Ativado ao receber o dano.",
		"effect": {"type": "type_resist", "pokemon_type": "ghost", "mult": 0.5, "trigger": "on_damage"}, "consumable": true,
	},
	"haban_berry": {
		"display_name": "Haban Berry", "category": "berry", "price": 200,
		"description": "Pokémon sofre metade do dano de um Move do tipo Dragão. Ativado ao receber o dano.",
		"effect": {"type": "type_resist", "pokemon_type": "dragon", "mult": 0.5, "trigger": "on_damage"}, "consumable": true,
	},
	"colbur_berry": {
		"display_name": "Colbur Berry", "category": "berry", "price": 200,
		"description": "Pokémon sofre metade do dano de um Move do tipo Sombrio. Ativado ao receber o dano.",
		"effect": {"type": "type_resist", "pokemon_type": "dark", "mult": 0.5, "trigger": "on_damage"}, "consumable": true,
	},
	"babiri_berry": {
		"display_name": "Babiri Berry", "category": "berry", "price": 200,
		"description": "Pokémon sofre metade do dano de um Move do tipo Aço. Ativado ao receber o dano.",
		"effect": {"type": "type_resist", "pokemon_type": "steel", "mult": 0.5, "trigger": "on_damage"}, "consumable": true,
	},
	"chilan_berry": {
		"display_name": "Chilan Berry", "category": "berry", "price": 200,
		"description": "Pokémon sofre metade do dano de um Move do tipo Normal. Ativado ao receber o dano.",
		"effect": {"type": "type_resist", "pokemon_type": "normal", "mult": 0.5, "trigger": "on_damage"}, "consumable": true,
	},
	"roseli_berry": {
		"display_name": "Roseli Berry", "category": "berry", "price": 200,
		"description": "Pokémon sofre metade do dano de um Move do tipo Fada. Ativado ao receber o dano.",
		"effect": {"type": "type_resist", "pokemon_type": "fairy", "mult": 0.5, "trigger": "on_damage"}, "consumable": true,
	},
	# --- Berries de stat boost ---
	"liechi_berry": {
		"display_name": "Liechi Berry", "category": "berry", "price": 300,
		"description": "Aumenta o Ataque em 1 estágio. Ativado ao cair abaixo de 25% de PV.",
		"effect": {"type": "stat_boost", "stat": "atk", "stages": 1, "trigger": "below_25_hp"}, "consumable": true,
	},
	"petaya_berry": {
		"display_name": "Petaya Berry", "category": "berry", "price": 300,
		"description": "Aumenta o Ataque Especial em 1 estágio. Ativado ao cair abaixo de 25% de PV.",
		"effect": {"type": "stat_boost", "stat": "spa", "stages": 1, "trigger": "below_25_hp"}, "consumable": true,
	},
	"ganlon_berry": {
		"display_name": "Ganlon Berry", "category": "berry", "price": 300,
		"description": "Aumenta a Defesa em 1 estágio. Ativado ao cair abaixo de 25% de PV.",
		"effect": {"type": "stat_boost", "stat": "def", "stages": 1, "trigger": "below_25_hp"}, "consumable": true,
	},
	"apicot_berry": {
		"display_name": "Apicot Berry", "category": "berry", "price": 300,
		"description": "Aumenta a Defesa Especial em 1 estágio. Ativado ao cair abaixo de 25% de PV.",
		"effect": {"type": "stat_boost", "stat": "spd", "stages": 1, "trigger": "below_25_hp"}, "consumable": true,
	},
	"salac_berry": {
		"display_name": "Salac Berry", "category": "berry", "price": 300,
		"description": "Aumenta a Velocidade em 1 estágio. Ativado ao cair abaixo de 25% de PV.",
		"effect": {"type": "stat_boost", "stat": "spe", "stages": 1, "trigger": "below_25_hp"}, "consumable": true,
	},
	"starf_berry": {
		"display_name": "Starf Berry", "category": "berry", "price": 350,
		"description": "Role 1d6 e aumente em 2 estágios o status correspondente. Ativado ao cair abaixo de 25% de PV.",
		"effect": {"type": "random_stat_boost", "stages": 2, "trigger": "below_25_hp"}, "consumable": true,
	},
	"micle_berry": {
		"display_name": "Micle Berry", "category": "berry", "price": 400,
		"description": "Aumenta a Precisão em 2 estágios. Ativado ao cair abaixo de 25% de PV.",
		"effect": {"type": "stat_boost", "stat": "acc", "stages": 2, "trigger": "below_25_hp"}, "consumable": true,
	},
	"lansat_berry": {
		"display_name": "Lansat Berry", "category": "berry", "price": 400,
		"description": "Aumenta a Margem de Crítico em 2 estágios. Ativado ao cair abaixo de 25% de PV.",
		"effect": {"type": "stat_boost", "stat": "crit", "stages": 2, "trigger": "below_25_hp"}, "consumable": true,
	},
	"enigma_berry": {
		"display_name": "Enigma Berry", "category": "berry", "price": 450,
		"description": "Restaura 5d10 PV. Ativado quando o Pokémon recebe dano super efetivo.",
		"effect": {"type": "heal", "dice": "5d10", "trigger": "on_super_effective"}, "consumable": true,
	},
	"custap_berry": {
		"display_name": "Custap Berry", "category": "berry", "price": 500,
		"description": "Faz com que você seja o primeiro a agir na rodada seguinte. Ativado ao cair abaixo de 25% de PV.",
		"effect": {"type": "priority_next_round", "trigger": "below_25_hp"}, "consumable": true,
	},
	"kee_berry": {
		"display_name": "Kee Berry", "category": "berry", "price": 400,
		"description": "Aumenta a Defesa em 1 estágio. Ativado após receber um ataque corpo a corpo.",
		"effect": {"type": "stat_boost", "stat": "def", "stages": 1, "trigger": "after_physical_hit"}, "consumable": true,
	},
	"maranga_berry": {
		"display_name": "Maranga Berry", "category": "berry", "price": 400,
		"description": "Aumenta a Defesa Especial em 1 estágio. Ativado após receber um ataque à distância.",
		"effect": {"type": "stat_boost", "stat": "spd", "stages": 1, "trigger": "after_ranged_hit"}, "consumable": true,
	},

	# ============================================================
	# ITENS EVOLUTIVOS
	# ============================================================
	"alola_stone": {
		"display_name": "Alola Stone", "category": "evolutivo", "price": 4000,
		"description": "Evolui Pikachu, Exeggcute e Cubone para suas formas de Alola.",
		"effect": {"type": "evolve", "targets": ["pikachu", "exeggcute", "cubone"]}, "consumable": true,
	},
	"hisui_stone": {
		"display_name": "Hisui Stone", "category": "evolutivo", "price": 4000,
		"description": "Evolui Quilava, Dewott, Dartrix, Goomy, Bergmite, Petilil e Rufflet para formas de Hisui.",
		"effect": {"type": "evolve", "targets": ["quilava", "dewott", "dartrix", "goomy", "bergmite", "petilil", "rufflet"]}, "consumable": true,
	},
	"galar_stone": {
		"display_name": "Galar Stone", "category": "evolutivo", "price": 4000,
		"description": "Evolui Koffing e Mime Jr. para suas formas de Galar.",
		"effect": {"type": "evolve", "targets": ["koffing", "mime_jr"]}, "consumable": true,
	},
	"dawn_stone": {
		"display_name": "Dawn Stone", "category": "evolutivo", "price": 4000,
		"description": "Evolui Kirlia e Snorunt.",
		"effect": {"type": "evolve", "targets": ["kirlia", "snorunt"]}, "consumable": true,
	},
	"deep_sea_scale": {
		"display_name": "Deep Sea Scale", "category": "evolutivo", "price": 4000,
		"description": "Evolui Clamperl (para Gorebyss).",
		"effect": {"type": "evolve", "targets": ["clamperl"]}, "consumable": true,
	},
	"deep_sea_tooth": {
		"display_name": "Deep Sea Tooth", "category": "evolutivo", "price": 4000,
		"description": "Evolui Clamperl (para Huntail).",
		"effect": {"type": "evolve", "targets": ["clamperl"]}, "consumable": true,
	},
	"dragon_scale": {
		"display_name": "Dragon Scale", "category": "evolutivo", "price": 4000,
		"description": "Evolui Seadra.",
		"effect": {"type": "evolve", "targets": ["seadra"]}, "consumable": true,
	},
	"dubious_disc": {
		"display_name": "Dubious Disc", "category": "evolutivo", "price": 4000,
		"description": "Evolui Porygon2.",
		"effect": {"type": "evolve", "targets": ["porygon2"]}, "consumable": true,
	},
	"dusk_stone": {
		"display_name": "Dusk Stone", "category": "evolutivo", "price": 4000,
		"description": "Evolui Misdreavus, Murkrow, Lampent e Doublade.",
		"effect": {"type": "evolve", "targets": ["misdreavus", "murkrow", "lampent", "doublade"]}, "consumable": true,
	},
	"electirizer": {
		"display_name": "Electirizer", "category": "evolutivo", "price": 4000,
		"description": "Evolui Electabuzz.",
		"effect": {"type": "evolve", "targets": ["electabuzz"]}, "consumable": true,
	},
	"fire_stone": {
		"display_name": "Fire Stone", "category": "evolutivo", "price": 4000,
		"description": "Evolui Vulpix, Growlithe, Eevee e Pansear.",
		"effect": {"type": "evolve", "targets": ["vulpix", "growlithe", "eevee", "pansear"]}, "consumable": true,
	},
	"ice_stone": {
		"display_name": "Ice Stone", "category": "evolutivo", "price": 4000,
		"description": "Evolui Eevee, Sandshrew de Alola e Vulpix de Alola.",
		"effect": {"type": "evolve", "targets": ["eevee", "sandshrew_alola", "vulpix_alola"]}, "consumable": true,
	},
	"kings_rock": {
		"display_name": "King's Rock", "category": "evolutivo", "price": 4000,
		"description": "Evolui Slowpoke e Poliwhirl. Como held item: 10% de chance de atordoar em ataques.",
		"effect": {"type": "evolve", "targets": ["slowpoke", "poliwhirl"]}, "consumable": true,
	},
	"leaf_stone": {
		"display_name": "Leaf Stone", "category": "evolutivo", "price": 4000,
		"description": "Evolui Eevee, Gloom, Weepinbell, Exeggcute, Nuzleaf e Pansage.",
		"effect": {"type": "evolve", "targets": ["eevee", "gloom", "weepinbell", "exeggcute", "nuzleaf", "pansage"]}, "consumable": true,
	},
	"magmarizer": {
		"display_name": "Magmarizer", "category": "evolutivo", "price": 4000,
		"description": "Evolui Magmar.",
		"effect": {"type": "evolve", "targets": ["magmar"]}, "consumable": true,
	},
	"metal_coat": {
		"display_name": "Metal Coat", "category": "evolutivo", "price": 4000,
		"description": "Evolui Onix e Scyther. Como held item: +prof no dano de Moves de Aço.",
		"effect": {"type": "evolve", "targets": ["onix", "scyther"]}, "consumable": true,
	},
	"moon_stone": {
		"display_name": "Moon Stone", "category": "evolutivo", "price": 4000,
		"description": "Evolui Nidorina, Nidorino, Clefairy, Jigglypuff, Skitty e Munna.",
		"effect": {"type": "evolve", "targets": ["nidorina", "nidorino", "clefairy", "jigglypuff", "skitty", "munna"]}, "consumable": true,
	},
	"oval_stone": {
		"display_name": "Oval Stone", "category": "evolutivo", "price": 4000,
		"description": "Evolui Happiny.",
		"effect": {"type": "evolve", "targets": ["happiny"]}, "consumable": true,
	},
	"prism_scale": {
		"display_name": "Prism Scale", "category": "evolutivo", "price": 4000,
		"description": "Evolui Feebas.",
		"effect": {"type": "evolve", "targets": ["feebas"]}, "consumable": true,
	},
	"protector": {
		"display_name": "Protector", "category": "evolutivo", "price": 4000,
		"description": "Evolui Rhydon.",
		"effect": {"type": "evolve", "targets": ["rhydon"]}, "consumable": true,
	},
	"razor_claw": {
		"display_name": "Razor Claw", "category": "evolutivo", "price": 4000,
		"description": "Evolui Sneasel. Como held item: +1 margem de crítico.",
		"effect": {"type": "evolve", "targets": ["sneasel"]}, "consumable": true,
	},
	"razor_fang": {
		"display_name": "Razor Fang", "category": "evolutivo", "price": 4000,
		"description": "Evolui Gligar. Como held item: 10% de chance de atordoar em ataques.",
		"effect": {"type": "evolve", "targets": ["gligar"]}, "consumable": true,
	},
	"reaper_cloth": {
		"display_name": "Reaper Cloth", "category": "evolutivo", "price": 4000,
		"description": "Evolui Dusclops.",
		"effect": {"type": "evolve", "targets": ["dusclops"]}, "consumable": true,
	},
	"sachet": {
		"display_name": "Sachet", "category": "evolutivo", "price": 4000,
		"description": "Evolui Spritzee.",
		"effect": {"type": "evolve", "targets": ["spritzee"]}, "consumable": true,
	},
	"shiny_stone": {
		"display_name": "Shiny Stone", "category": "evolutivo", "price": 4000,
		"description": "Evolui Togetic, Roselia, Minccino e Floette.",
		"effect": {"type": "evolve", "targets": ["togetic", "roselia", "minccino", "floette"]}, "consumable": true,
	},
	"sun_stone": {
		"display_name": "Sun Stone", "category": "evolutivo", "price": 4000,
		"description": "Evolui Gloom, Sunkern, Cottonee, Petilil e Helioptile.",
		"effect": {"type": "evolve", "targets": ["gloom", "sunkern", "cottonee", "petilil", "helioptile"]}, "consumable": true,
	},
	"thunder_stone": {
		"display_name": "Thunder Stone", "category": "evolutivo", "price": 4000,
		"description": "Evolui Pikachu, Eevee, Eelektrik e Charjabug.",
		"effect": {"type": "evolve", "targets": ["pikachu", "eevee", "eelektrik", "charjabug"]}, "consumable": true,
	},
	"upgrade": {
		"display_name": "Upgrade", "category": "evolutivo", "price": 4000,
		"description": "Evolui Porygon.",
		"effect": {"type": "evolve", "targets": ["porygon"]}, "consumable": true,
	},
	"water_stone": {
		"display_name": "Water Stone", "category": "evolutivo", "price": 4000,
		"description": "Evolui Poliwhirl, Shellder, Eevee, Staryu, Lombre e Panpour.",
		"effect": {"type": "evolve", "targets": ["poliwhirl", "shellder", "eevee", "staryu", "lombre", "panpour"]}, "consumable": true,
	},
	"whipped_dream": {
		"display_name": "Whipped Dream", "category": "evolutivo", "price": 4000,
		"description": "Evolui Swirlix.",
		"effect": {"type": "evolve", "targets": ["swirlix"]}, "consumable": true,
	},
	"pedra_chave": {
		"display_name": "Pedra-Chave", "category": "evolutivo", "price": -1,
		"description": "Permite que um Pokémon em seu último estágio Mega Evolua.",
		"effect": {"type": "enable_mega"}, "consumable": false,
	},

	# ============================================================
	# ITENS SEGURÁVEIS (HELD) NÃO CONSUMÍVEIS
	# ============================================================
	"assault_vest": {
		"display_name": "Assault Vest", "category": "held", "price": 4400,
		"description": "Reduz dano de ataques à distância em prof. O portador só pode usar Moves de dano.",
		"effect": {"type": "ranged_damage_reduction", "amount": "prof", "restrict_to_damage_moves": true}, "consumable": false,
	},
	"big_root": {
		"display_name": "Big Root", "category": "held", "price": 4400,
		"description": "Moves que roubam PV restauram +1d12 PV.",
		"effect": {"type": "drain_boost", "dice": "1d12"}, "consumable": false,
	},
	"black_belt": {
		"display_name": "Black Belt", "category": "held", "price": 4400,
		"description": "+prof no dano de Moves de Lutador.",
		"effect": {"type": "type_damage_boost", "pokemon_type": "fighting", "amount": "prof"}, "consumable": false,
	},
	"black_glasses": {
		"display_name": "Black Glasses", "category": "held", "price": 4400,
		"description": "+prof no dano de Moves de Sombrio.",
		"effect": {"type": "type_damage_boost", "pokemon_type": "dark", "amount": "prof"}, "consumable": false,
	},
	"black_sludge": {
		"display_name": "Black Sludge", "category": "held", "price": 4400,
		"description": "Restaura metade do nível por turno se Venenoso; dano igual ao nível se não.",
		"effect": {"type": "poison_held_regen", "amount": "half_level"}, "consumable": false,
	},
	"bright_powder": {
		"display_name": "Bright Powder", "category": "held", "price": 4400,
		"description": "+1 CA e +1 em todos os testes de resistência.",
		"effect": {"type": "ac_and_save_bonus", "amount": 1}, "consumable": false,
	},
	"charcoal": {
		"display_name": "Charcoal", "category": "held", "price": 4400,
		"description": "+prof no dano de Moves de Fogo.",
		"effect": {"type": "type_damage_boost", "pokemon_type": "fire", "amount": "prof"}, "consumable": false,
	},
	"choice_band": {
		"display_name": "Choice Band", "category": "held", "price": 4000,
		"description": "Lock no primeiro Move escolhido. +prof no dano de ataques corpo a corpo.",
		"effect": {"type": "lock_move", "boost": "prof", "scope": "physical"}, "consumable": false,
	},
	"choice_specs": {
		"display_name": "Choice Specs", "category": "held", "price": 4000,
		"description": "Lock no primeiro Move escolhido. +prof no dano de ataques à distância.",
		"effect": {"type": "lock_move", "boost": "prof", "scope": "ranged"}, "consumable": false,
	},
	"choice_scarf": {
		"display_name": "Choice Scarf", "category": "held", "price": 4000,
		"description": "Lock no primeiro Move escolhido. +prof em iniciativa, +1,5m de deslocamento.",
		"effect": {"type": "lock_move", "boost": "prof_initiative", "extra_movement_m": 1.5}, "consumable": false,
	},
	"damp_rock": {
		"display_name": "Damp Rock", "category": "held", "price": 2500,
		"description": "Aumenta a duração de Rain Dance em 3 rodadas.",
		"effect": {"type": "weather_extend", "weather": "rain", "rounds": 3}, "consumable": false,
	},
	"dragon_fang": {
		"display_name": "Dragon Fang", "category": "held", "price": 4400,
		"description": "+prof no dano de Moves de Dragão.",
		"effect": {"type": "type_damage_boost", "pokemon_type": "dragon", "amount": "prof"}, "consumable": false,
	},
	"eject_button": {
		"display_name": "Eject Button", "category": "held", "price": 4000,
		"description": "Ao ser atingido por um ataque, o portador pode ser trocado por reação. 1 por equipe.",
		"effect": {"type": "eject_on_hit"}, "consumable": false,
	},
	"eviolite": {
		"display_name": "Eviolite", "category": "held", "price": 4400,
		"description": "Se o Pokémon ainda puder evoluir, reduz dano corpo a corpo e à distância em prof.",
		"effect": {"type": "unevolved_damage_reduction", "amount": "prof"}, "consumable": false,
	},
	"fairy_feather": {
		"display_name": "Fairy Feather", "category": "held", "price": 4000,
		"description": "+prof no dano de Moves de Fada.",
		"effect": {"type": "type_damage_boost", "pokemon_type": "fairy", "amount": "prof"}, "consumable": false,
	},
	"flame_orb": {
		"display_name": "Flame Orb", "category": "held", "price": 5000,
		"description": "Inflige o status Queimado ao final de cada turno.",
		"effect": {"type": "status_per_turn", "status": "burned"}, "consumable": false,
	},
	"float_stone": {
		"display_name": "Float Stone", "category": "held", "price": 4400,
		"description": "+3m de salto, -2d6 de queda, tratado como 1 tamanho menor em Moves por tamanho.",
		"effect": {"type": "weight_reduction", "jump_bonus_m": 3, "fall_reduction_dice": "2d6"}, "consumable": false,
	},
	"focus_band": {
		"display_name": "Focus Band", "category": "held", "price": 2000,
		"description": "19-20 no d20: sobrevive com 1 PV a um golpe que o desmaiaria.",
		"effect": {"type": "survive_at_1_hp", "chance": 0.1}, "consumable": false,
	},
	"hard_stone": {
		"display_name": "Hard Stone", "category": "held", "price": 2500,
		"description": "+prof no dano de Moves de Pedra.",
		"effect": {"type": "type_damage_boost", "pokemon_type": "rock", "amount": "prof"}, "consumable": false,
	},
	"heat_rock": {
		"display_name": "Heat Rock", "category": "held", "price": 2500,
		"description": "Aumenta a duração de Sunny Day em 3 rodadas.",
		"effect": {"type": "weather_extend", "weather": "sun", "rounds": 3}, "consumable": false,
	},
	"icy_rock": {
		"display_name": "Icy Rock", "category": "held", "price": 2500,
		"description": "Aumenta a duração de Hail em 3 rodadas.",
		"effect": {"type": "weather_extend", "weather": "hail", "rounds": 3}, "consumable": false,
	},
	"iron_ball": {
		"display_name": "Iron Ball", "category": "held", "price": 2500,
		"description": "Reduz deslocamento à metade, -2*prof em iniciativa, sempre No Chão.",
		"effect": {"type": "ground_and_slow"}, "consumable": false,
	},
	"lagging_tail": {
		"display_name": "Lagging Tail", "category": "held", "price": 2500,
		"description": "Portador sempre age por último na rodada.",
		"effect": {"type": "always_last"}, "consumable": false,
	},
	"leftovers": {
		"display_name": "Leftovers", "category": "held", "price": 4400,
		"description": "Restaura PV = metade do nível no final de cada turno.",
		"effect": {"type": "end_of_turn_heal", "amount": "half_level"}, "consumable": false,
	},
	"life_orb": {
		"display_name": "Life Orb", "category": "held", "price": 4400,
		"description": "+prof em rolagens de dano, mas perde PV iguais ao bônus ao causar dano.",
		"effect": {"type": "damage_boost_with_recoil", "amount": "prof"}, "consumable": false,
	},
	"light_clay": {
		"display_name": "Light Clay", "category": "held", "price": 4000,
		"description": "Aumenta a duração de Light Screen, Reflect ou Aurora Veil em 3 rodadas.",
		"effect": {"type": "screen_extend", "rounds": 3}, "consumable": false,
	},
	"lucky_egg": {
		"display_name": "Lucky Egg", "category": "held", "price": 4400,
		"description": "Experiência de batalha aumentada em 20%.",
		"effect": {"type": "xp_boost", "mult": 1.2}, "consumable": false,
	},
	"magnet": {
		"display_name": "Magnet", "category": "held", "price": 4400,
		"description": "+prof no dano de Moves de Elétrico.",
		"effect": {"type": "type_damage_boost", "pokemon_type": "electric", "amount": "prof"}, "consumable": false,
	},
	"miracle_seed": {
		"display_name": "Miracle Seed", "category": "held", "price": 4400,
		"description": "+prof no dano de Moves de Grama.",
		"effect": {"type": "type_damage_boost", "pokemon_type": "grass", "amount": "prof"}, "consumable": false,
	},
	"muscle_band": {
		"display_name": "Muscle Band", "category": "held", "price": 5000,
		"description": "+2 nas rolagens de dano de Moves corpo a corpo.",
		"effect": {"type": "flat_damage_boost", "scope": "physical", "amount": 2}, "consumable": false,
	},
	"mystic_water": {
		"display_name": "Mystic Water", "category": "held", "price": 4400,
		"description": "+prof no dano de Moves de Água.",
		"effect": {"type": "type_damage_boost", "pokemon_type": "water", "amount": "prof"}, "consumable": false,
	},
	"never_melt_ice": {
		"display_name": "Never-Melt Ice", "category": "held", "price": 4400,
		"description": "+prof no dano de Moves de Gelo.",
		"effect": {"type": "type_damage_boost", "pokemon_type": "ice", "amount": "prof"}, "consumable": false,
	},
	"poison_barb": {
		"display_name": "Poison Barb", "category": "held", "price": 4400,
		"description": "+prof no dano de Moves de Venenoso.",
		"effect": {"type": "type_damage_boost", "pokemon_type": "poison", "amount": "prof"}, "consumable": false,
	},
	"quick_claw": {
		"display_name": "Quick Claw", "category": "held", "price": 4000,
		"description": "17+ no d20 no início da rodada: age primeiro.",
		"effect": {"type": "priority_chance", "threshold": 17}, "consumable": false,
	},
	"rocky_helmet": {
		"display_name": "Rocky Helmet", "category": "held", "price": 4400,
		"description": "Atacante corpo a corpo recebe dano sem tipo igual à prof.",
		"effect": {"type": "contact_damage", "amount": "prof"}, "consumable": false,
	},
	"safety_goggles": {
		"display_name": "Safety Goggles", "category": "held", "price": 4000,
		"description": "Imune a Moves Powder/Spore e a dano de granizo/tempestade de areia.",
		"effect": {"type": "powder_weather_immunity"}, "consumable": false,
	},
	"scope_lens": {
		"display_name": "Scope Lens", "category": "held", "price": 4400,
		"description": "+1 margem de crítico.",
		"effect": {"type": "crit_margin_boost", "stages": 1}, "consumable": false,
	},
	"sharp_beak": {
		"display_name": "Sharp Beak", "category": "held", "price": 4400,
		"description": "+prof no dano de Moves de Voador.",
		"effect": {"type": "type_damage_boost", "pokemon_type": "flying", "amount": "prof"}, "consumable": false,
	},
	"shed_shell": {
		"display_name": "Shed Shell", "category": "held", "price": 2000,
		"description": "Permite troca mesmo sob efeito de trapping.",
		"effect": {"type": "escape_trapping"}, "consumable": false,
	},
	"shell_bell": {
		"display_name": "Shell Bell", "category": "held", "price": 4400,
		"description": "Restaura PV = prof sempre que causar dano com Move.",
		"effect": {"type": "heal_on_damage", "amount": "prof"}, "consumable": false,
	},
	"silk_scarf": {
		"display_name": "Silk Scarf", "category": "held", "price": 4400,
		"description": "+prof no dano de Moves de Normal.",
		"effect": {"type": "type_damage_boost", "pokemon_type": "normal", "amount": "prof"}, "consumable": false,
	},
	"silver_powder": {
		"display_name": "Silver Powder", "category": "held", "price": 4400,
		"description": "+prof no dano de Moves de Inseto.",
		"effect": {"type": "type_damage_boost", "pokemon_type": "bug", "amount": "prof"}, "consumable": false,
	},
	"smoke_ball": {
		"display_name": "Smoke Ball", "category": "held", "price": 4400,
		"description": "Fuga garantida de Pokémon selvagens.",
		"effect": {"type": "guaranteed_escape"}, "consumable": false,
	},
	"smooth_rock": {
		"display_name": "Smooth Rock", "category": "held", "price": 2500,
		"description": "Aumenta a duração de Sandstorm em 3 rodadas.",
		"effect": {"type": "weather_extend", "weather": "sand", "rounds": 3}, "consumable": false,
	},
	"soft_sand": {
		"display_name": "Soft Sand", "category": "held", "price": 4400,
		"description": "+prof no dano de Moves de Terra.",
		"effect": {"type": "type_damage_boost", "pokemon_type": "ground", "amount": "prof"}, "consumable": false,
	},
	"soothe_bell": {
		"display_name": "Soothe Bell", "category": "held", "price": 6000,
		"description": "Redefine Lealdade para +0; facilita ganho de Lealdade.",
		"effect": {"type": "loyalty_reset_positive"}, "consumable": false,
	},
	"spell_tag": {
		"display_name": "Spell Tag", "category": "held", "price": 4400,
		"description": "+prof no dano de Moves de Fantasma.",
		"effect": {"type": "type_damage_boost", "pokemon_type": "ghost", "amount": "prof"}, "consumable": false,
	},
	"terrain_extender": {
		"display_name": "Terrain Extender", "category": "held", "price": 4400,
		"description": "+3 rodadas nos Terrain ativados pelo portador.",
		"effect": {"type": "terrain_extend", "rounds": 3}, "consumable": false,
	},
	"toxic_orb": {
		"display_name": "Toxic Orb", "category": "held", "price": 5000,
		"description": "Inflige Gravemente Envenenado ao final de cada turno.",
		"effect": {"type": "status_per_turn", "status": "badly_poisoned"}, "consumable": false,
	},
	"twisted_spoon": {
		"display_name": "Twisted Spoon", "category": "held", "price": 4400,
		"description": "+prof no dano de Moves de Psíquico.",
		"effect": {"type": "type_damage_boost", "pokemon_type": "psychic", "amount": "prof"}, "consumable": false,
	},
	"wide_lens": {
		"display_name": "Wide Lens", "category": "held", "price": 4400,
		"description": "+1 nas rolagens de ataque e na CD de Moves.",
		"effect": {"type": "accuracy_boost", "amount": 1}, "consumable": false,
	},
	"wise_glasses": {
		"display_name": "Wise Glasses", "category": "held", "price": 4400,
		"description": "+2 nas rolagens de dano de Moves à distância.",
		"effect": {"type": "flat_damage_boost", "scope": "ranged", "amount": 2}, "consumable": false,
	},

	# ============================================================
	# HELD ITEMS CONSUMÍVEIS
	# ============================================================
	"absorb_bulb": {
		"display_name": "Absorb Bulb", "category": "held", "price": 250,
		"description": "+1 Ataque Especial ao receber dano de Água.",
		"effect": {"type": "stat_boost_on_damage", "stat": "spa", "stages": 1, "damage_type": "water"}, "consumable": true,
	},
	"air_balloon": {
		"display_name": "Air Balloon", "category": "held", "price": 500,
		"description": "Torna o portador Elevado. Estoura ao ser atingido por um ataque.",
		"effect": {"type": "elevated", "pop_on_hit": true}, "consumable": true,
	},
	"cell_battery": {
		"display_name": "Cell Battery", "category": "held", "price": 250,
		"description": "+1 Ataque ao receber dano de Elétrico.",
		"effect": {"type": "stat_boost_on_damage", "stat": "atk", "stages": 1, "damage_type": "electric"}, "consumable": true,
	},
	"focus_sash": {
		"display_name": "Focus Sash", "category": "held", "price": 2000,
		"description": "Se com PV cheios, reduz pela metade o primeiro dano forte. Sobrevive com 1 PV se ainda desmaiaria.",
		"effect": {"type": "survive_at_1_hp", "condition": "full_hp_first_hit"}, "consumable": true,
	},
	"luminous_moss": {
		"display_name": "Luminous Moss", "category": "held", "price": 250,
		"description": "+1 Defesa Especial ao receber dano de Água.",
		"effect": {"type": "stat_boost_on_damage", "stat": "spd", "stages": 1, "damage_type": "water"}, "consumable": true,
	},
	"mental_herb": {
		"display_name": "Mental Herb", "category": "held", "price": 500,
		"description": "Remove Encantado, Taunt, Encore, Torment, Heal Block, Disable ou Cursed Body com ação livre.",
		"effect": {"type": "cure_mental", "statuses": ["encore", "taunt", "torment", "heal_block", "disable", "cursed_body", "encantado"]}, "consumable": true,
	},
	"snowball": {
		"display_name": "Snowball", "category": "held", "price": 250,
		"description": "+1 Ataque ao receber dano de Gelo.",
		"effect": {"type": "stat_boost_on_damage", "stat": "atk", "stages": 1, "damage_type": "ice"}, "consumable": true,
	},
	"white_herb": {
		"display_name": "White Herb", "category": "held", "price": 500,
		"description": "Remove todos os estágios negativos com ação livre.",
		"effect": {"type": "clear_negative_stages"}, "consumable": true,
	},
	"power_herb": {
		"display_name": "Power Herb", "category": "held", "price": 500,
		"description": "Executa Move com turno de preparação no mesmo turno.",
		"effect": {"type": "skip_charge_turn"}, "consumable": true,
	},
	"weakness_policy": {
		"display_name": "Weakness Policy", "category": "held", "price": 1000,
		"description": "+2 Ataque e Ataque Especial ao receber dano super efetivo.",
		"effect": {"type": "stat_boost_on_super_effective", "stats": ["atk", "spa"], "stages": 2}, "consumable": true,
	},
	# Seeds
	"electric_seed": {
		"display_name": "Electric Seed", "category": "held", "price": 500,
		"description": "+1 Defesa ao entrar em Electric Terrain.",
		"effect": {"type": "terrain_seed", "terrain": "electric", "stat": "def", "stages": 1}, "consumable": true,
	},
	"grassy_seed": {
		"display_name": "Grassy Seed", "category": "held", "price": 500,
		"description": "+1 Defesa ao entrar em Grassy Terrain.",
		"effect": {"type": "terrain_seed", "terrain": "grassy", "stat": "def", "stages": 1}, "consumable": true,
	},
	"misty_seed": {
		"display_name": "Misty Seed", "category": "held", "price": 500,
		"description": "+1 Defesa Especial ao entrar em Misty Terrain.",
		"effect": {"type": "terrain_seed", "terrain": "misty", "stat": "spd", "stages": 1}, "consumable": true,
	},
	"psychic_seed": {
		"display_name": "Psychic Seed", "category": "held", "price": 500,
		"description": "+1 Defesa Especial ao entrar em Psychic Terrain.",
		"effect": {"type": "terrain_seed", "terrain": "psychic", "stat": "spd", "stages": 1}, "consumable": true,
	},
	# Gems (uma por tipo; efeito genérico)
	"fire_gem": {"display_name": "Fire Gem", "category": "held", "price": 200,
		"description": "Aumenta o dano de um Move de Fogo pela metade. Consumido no uso.",
		"effect": {"type": "gem", "pokemon_type": "fire"}, "consumable": true},
	"water_gem": {"display_name": "Water Gem", "category": "held", "price": 200,
		"description": "Aumenta o dano de um Move de Água pela metade. Consumido no uso.",
		"effect": {"type": "gem", "pokemon_type": "water"}, "consumable": true},
	"grass_gem": {"display_name": "Grass Gem", "category": "held", "price": 200,
		"description": "Aumenta o dano de um Move de Grama pela metade. Consumido no uso.",
		"effect": {"type": "gem", "pokemon_type": "grass"}, "consumable": true},
	"electric_gem": {"display_name": "Electric Gem", "category": "held", "price": 200,
		"description": "Aumenta o dano de um Move de Elétrico pela metade. Consumido no uso.",
		"effect": {"type": "gem", "pokemon_type": "electric"}, "consumable": true},
	"ice_gem": {"display_name": "Ice Gem", "category": "held", "price": 200,
		"description": "Aumenta o dano de um Move de Gelo pela metade. Consumido no uso.",
		"effect": {"type": "gem", "pokemon_type": "ice"}, "consumable": true},
	"fighting_gem": {"display_name": "Fighting Gem", "category": "held", "price": 200,
		"description": "Aumenta o dano de um Move de Lutador pela metade. Consumido no uso.",
		"effect": {"type": "gem", "pokemon_type": "fighting"}, "consumable": true},
	"poison_gem": {"display_name": "Poison Gem", "category": "held", "price": 200,
		"description": "Aumenta o dano de um Move de Venenoso pela metade. Consumido no uso.",
		"effect": {"type": "gem", "pokemon_type": "poison"}, "consumable": true},
	"ground_gem": {"display_name": "Ground Gem", "category": "held", "price": 200,
		"description": "Aumenta o dano de um Move de Terra pela metade. Consumido no uso.",
		"effect": {"type": "gem", "pokemon_type": "ground"}, "consumable": true},
	"flying_gem": {"display_name": "Flying Gem", "category": "held", "price": 200,
		"description": "Aumenta o dano de um Move de Voador pela metade. Consumido no uso.",
		"effect": {"type": "gem", "pokemon_type": "flying"}, "consumable": true},
	"psychic_gem": {"display_name": "Psychic Gem", "category": "held", "price": 200,
		"description": "Aumenta o dano de um Move de Psíquico pela metade. Consumido no uso.",
		"effect": {"type": "gem", "pokemon_type": "psychic"}, "consumable": true},
	"bug_gem": {"display_name": "Bug Gem", "category": "held", "price": 200,
		"description": "Aumenta o dano de um Move de Inseto pela metade. Consumido no uso.",
		"effect": {"type": "gem", "pokemon_type": "bug"}, "consumable": true},
	"rock_gem": {"display_name": "Rock Gem", "category": "held", "price": 200,
		"description": "Aumenta o dano de um Move de Pedra pela metade. Consumido no uso.",
		"effect": {"type": "gem", "pokemon_type": "rock"}, "consumable": true},
	"ghost_gem": {"display_name": "Ghost Gem", "category": "held", "price": 200,
		"description": "Aumenta o dano de um Move de Fantasma pela metade. Consumido no uso.",
		"effect": {"type": "gem", "pokemon_type": "ghost"}, "consumable": true},
	"dragon_gem": {"display_name": "Dragon Gem", "category": "held", "price": 200,
		"description": "Aumenta o dano de um Move de Dragão pela metade. Consumido no uso.",
		"effect": {"type": "gem", "pokemon_type": "dragon"}, "consumable": true},
	"dark_gem": {"display_name": "Dark Gem", "category": "held", "price": 200,
		"description": "Aumenta o dano de um Move de Sombrio pela metade. Consumido no uso.",
		"effect": {"type": "gem", "pokemon_type": "dark"}, "consumable": true},
	"steel_gem": {"display_name": "Steel Gem", "category": "held", "price": 200,
		"description": "Aumenta o dano de um Move de Aço pela metade. Consumido no uso.",
		"effect": {"type": "gem", "pokemon_type": "steel"}, "consumable": true},
	"normal_gem": {"display_name": "Normal Gem", "category": "held", "price": 200,
		"description": "Aumenta o dano de um Move de Normal pela metade. Consumido no uso.",
		"effect": {"type": "gem", "pokemon_type": "normal"}, "consumable": true},
	"fairy_gem": {"display_name": "Fairy Gem", "category": "held", "price": 200,
		"description": "Aumenta o dano de um Move de Fada pela metade. Consumido no uso.",
		"effect": {"type": "gem", "pokemon_type": "fairy"}, "consumable": true},

	# ============================================================
	# HELD ITEMS ESPECÍFICOS (por espécie)
	# ============================================================
	"arceus_plate": {
		"display_name": "Arceus Plate", "category": "held", "price": -1,
		"description": "Altera o tipo do Arceus e de Judgment.",
		"effect": {"type": "species_specific", "species": "arceus", "variant": "plate_change"}, "consumable": false,
	},
	"everstone": {
		"display_name": "Everstone", "category": "held", "price": 1400,
		"description": "Impede evolução. 50% de chance de herdar Natureza na reprodução.",
		"effect": {"type": "block_evolution", "nature_inherit_chance": 0.5}, "consumable": false,
	},
	"genesect_drive": {
		"display_name": "Genesect Drive", "category": "held", "price": -1,
		"description": "Muda o tipo de Techno Blast do Genesect (Burn/Chill/Douse/Shock).",
		"effect": {"type": "species_specific", "species": "genesect", "variant": "drive"}, "consumable": false,
	},
	"griseous_orb": {
		"display_name": "Griseous Orb", "category": "held", "price": 7000,
		"description": "Permite Giratina trocar de forma. Dano de Dragão/Fantasma rola duas vezes.",
		"effect": {"type": "species_specific", "species": "giratina", "variant": "form_and_damage"}, "consumable": false,
	},
	"light_ball": {
		"display_name": "Light Ball", "category": "held", "price": 1400,
		"description": "Pikachu dobra o bônus de proficiência em dano corpo a corpo e à distância.",
		"effect": {"type": "species_specific", "species": "pikachu", "variant": "double_prof_damage"}, "consumable": false,
	},
	"lucky_punch": {
		"display_name": "Lucky Punch", "category": "held", "price": 1200,
		"description": "Chansey ganha +2 margem de crítico.",
		"effect": {"type": "species_specific", "species": "chansey", "variant": "crit_boost", "stages": 2}, "consumable": false,
	},
	"memory_disc": {
		"display_name": "Memory Disc", "category": "held", "price": -1,
		"description": "Altera o tipo de Silvally e de Multi-Attack.",
		"effect": {"type": "species_specific", "species": "silvally", "variant": "type_change"}, "consumable": false,
	},
	"metal_powder": {
		"display_name": "Metal Powder", "category": "held", "price": 1200,
		"description": "Ditto reduz dano recebido (corpo a corpo e à distância) em prof.",
		"effect": {"type": "species_specific", "species": "ditto", "variant": "damage_reduction"}, "consumable": false,
	},
	"stick": {
		"display_name": "Stick", "category": "held", "price": 1200,
		"description": "Farfetch'd ganha +2 margem de crítico.",
		"effect": {"type": "species_specific", "species": "farfetchd", "variant": "crit_boost", "stages": 2}, "consumable": false,
	},
	"thick_club": {
		"display_name": "Thick Club", "category": "held", "price": 4400,
		"description": "Cubone/Marowak dobram o bônus de proficiência no dano corpo a corpo.",
		"effect": {"type": "species_specific", "species": "cubone", "variant": "double_prof_damage"}, "consumable": false,
	},
	"adamant_orb": {
		"display_name": "Adamant Orb", "category": "held", "price": -1,
		"description": "Dialga rola dano de Aço e Dragão duas vezes.",
		"effect": {"type": "species_specific", "species": "dialga", "variant": "double_type_damage", "types": ["steel", "dragon"]}, "consumable": false,
	},
	"lustrous_orb": {
		"display_name": "Lustrous Orb", "category": "held", "price": -1,
		"description": "Palkia rola dano de Água e Dragão duas vezes.",
		"effect": {"type": "species_specific", "species": "palkia", "variant": "double_type_damage", "types": ["water", "dragon"]}, "consumable": false,
	},
	"soul_dew": {
		"display_name": "Soul Dew", "category": "held", "price": -1,
		"description": "Latios/Latias rolam dano de Psíquico e Dragão duas vezes.",
		"effect": {"type": "species_specific", "species": "latios", "variant": "double_type_damage", "types": ["psychic", "dragon"]}, "consumable": false,
	},

	# ============================================================
	# ITENS-CHAVE
	# ============================================================
	"pokedex": {
		"display_name": "Pokédex", "category": "chave", "price": 10000,
		"description": "Registra Pokémon num raio de 15m. Revela SR básico e fatos sobre a espécie.",
		"effect": {"type": "scan_pokemon", "range_m": 15}, "consumable": false,
	},
	"rotom_dex": {
		"display_name": "Rotom Dex", "category": "chave", "price": 50000,
		"description": "Registra Pokémon automaticamente num raio de 15m. Permite trocas com o PC até 2x por dia.",
		"effect": {"type": "auto_scan", "range_m": 15, "pc_trades_per_day": 2}, "consumable": false,
	},
	"old_rod": {
		"display_name": "Old Rod", "category": "chave", "price": 1000,
		"description": "Vara de pesca básica. Aguenta Pokémon de SR até 5.",
		"effect": {"type": "fishing", "max_sr": 5, "pull_bonus": 0}, "consumable": false,
	},
	"good_rod": {
		"display_name": "Good Rod", "category": "chave", "price": 5000,
		"description": "Vara de pesca intermediária. Aguenta Pokémon de SR até 10. +1 em testes de Força para puxar.",
		"effect": {"type": "fishing", "max_sr": 10, "pull_bonus": 1}, "consumable": false,
	},
	"super_rod": {
		"display_name": "Super Rod", "category": "chave", "price": 15000,
		"description": "Vara de pesca avançada. Aguenta qualquer Pokémon. +2 em testes de Força para puxar.",
		"effect": {"type": "fishing", "max_sr": 999, "pull_bonus": 2}, "consumable": false,
	},
	"bicicleta_corrida": {
		"display_name": "Bicicleta de Corrida", "category": "chave", "price": 10000,
		"description": "Move-se até 60m por turno em estradas asfaltadas, aumentando 3m a cada turno.",
		"effect": {"type": "movement_boost", "max_m": 60, "terrain": "paved"}, "consumable": false,
	},
	"bicicleta_cross": {
		"display_name": "Bicicleta Cross", "category": "chave", "price": 10000,
		"description": "Move-se até 27m por turno em qualquer estrada ou trilha.",
		"effect": {"type": "movement_boost", "max_m": 27, "terrain": "any_road"}, "consumable": false,
	},
	"escape_rope": {
		"display_name": "Escape Rope", "category": "chave", "price": 200,
		"description": "Ao ser amarrada em um nó, indica o caminho de saída de uma caverna.",
		"effect": {"type": "escape_cave"}, "consumable": true,
	},
	"fluffy_tail": {
		"display_name": "Fluffy Tail", "category": "chave", "price": 150,
		"description": "Sucesso automático para escapar do combate.",
		"effect": {"type": "guaranteed_escape_consumable"}, "consumable": true,
	},
	"honey": {
		"display_name": "Honey", "category": "chave", "price": 1000,
		"description": "Atrai um Pokémon da área.",
		"effect": {"type": "attract_pokemon"}, "consumable": true,
	},
	"exp_share": {
		"display_name": "Exp. Share", "category": "chave", "price": 7500,
		"description": "Criatura segurando recebe metade da XP total de cada combate.",
		"effect": {"type": "share_xp", "fraction": 0.5}, "consumable": false,
	},
	"ability_capsule": {
		"display_name": "Ability Capsule", "category": "chave", "price": 12000,
		"description": "Troca a habilidade passiva não oculta de um Pokémon.",
		"effect": {"type": "swap_ability"}, "consumable": true,
	},
	"ability_patch": {
		"display_name": "Ability Patch", "category": "chave", "price": 25000,
		"description": "Troca a habilidade passiva para a habilidade oculta.",
		"effect": {"type": "unlock_hidden_ability"}, "consumable": true,
	},
	"shiny_charm": {
		"display_name": "Shiny Charm", "category": "chave", "price": 50000,
		"description": "+5 na margem de sucesso em d100 para Pokémon Brilhantes.",
		"effect": {"type": "shiny_boost", "amount": 5}, "consumable": false,
	},
	"mega_bracelete": {
		"display_name": "Mega Bracelete", "category": "chave", "price": -1,
		"description": "Necessário para realizar Mega Evolução.",
		"effect": {"type": "enable_mega"}, "consumable": false,
	},
	"bracelete_z": {
		"display_name": "Bracelete-Z", "category": "chave", "price": -1,
		"description": "Necessário para realizar Z-Moves.",
		"effect": {"type": "enable_zmove"}, "consumable": false,
	},
	"incubadora_basica": {
		"display_name": "Incubadora Básica", "category": "chave", "price": 1000,
		"description": "Reduz Tempo de Eclosão em 1d20 adicional.",
		"effect": {"type": "incubator", "bonus_dice": "1d20"}, "consumable": false,
	},
	"incubadora_plus": {
		"display_name": "Incubadora Plus", "category": "chave", "price": 3000,
		"description": "Reduz Tempo de Eclosão em 2d20 adicionais.",
		"effect": {"type": "incubator", "bonus_dice": "2d20"}, "consumable": false,
	},
	"incubadora_super": {
		"display_name": "Incubadora Super", "category": "chave", "price": 10000,
		"description": "Reduz Tempo de Eclosão em 3d20 adicionais e escolhe o momento de chocar.",
		"effect": {"type": "incubator", "bonus_dice": "3d20", "choose_hatch_time": true}, "consumable": false,
	},
	# Itens-chave específicos (formas de lendários)
	"dna_splicer": {
		"display_name": "DNA Splicer", "category": "chave", "price": -1,
		"description": "Permite a Kyurem fundir-se com Reshiram ou Zekrom.",
		"effect": {"type": "species_specific", "species": "kyurem", "variant": "fuse"}, "consumable": false,
	},
	"gracidea": {
		"display_name": "Gracidea", "category": "chave", "price": 1400,
		"description": "Permite Shaymin mudar de forma durante o dia.",
		"effect": {"type": "species_specific", "species": "shaymin", "variant": "form_change", "time_range": [5, 20]}, "consumable": false,
	},
	"n_solarizer": {
		"display_name": "N-Solarizer", "category": "chave", "price": -1,
		"description": "Permite Necrozma fundir-se com Solgaleo.",
		"effect": {"type": "species_specific", "species": "necrozma", "variant": "fuse_solgaleo"}, "consumable": false,
	},
	"n_lunarizer": {
		"display_name": "N-Lunarizer", "category": "chave", "price": -1,
		"description": "Permite Necrozma fundir-se com Lunala.",
		"effect": {"type": "species_specific", "species": "necrozma", "variant": "fuse_lunala"}, "consumable": false,
	},
	"reveal_glass": {
		"display_name": "Reveal Glass", "category": "chave", "price": -1,
		"description": "Muda forma de Thundurus, Landorus, Tornadus e Enamorus.",
		"effect": {"type": "species_specific", "species": "tornadus", "variant": "form_change"}, "consumable": false,
	},
	"prison_bottle": {
		"display_name": "Prison Bottle", "category": "chave", "price": -1,
		"description": "Permite Hoopa mudar de forma.",
		"effect": {"type": "species_specific", "species": "hoopa", "variant": "form_change"}, "consumable": false,
	},
	# Néctares de Oricorio
	"nectar_vermelho": {"display_name": "Néctar Vermelho", "category": "chave", "price": 400,
		"description": "Transforma Oricorio no Estilo Baile.", "effect": {"type": "orichorio_nectar", "style": "baile"}, "consumable": true},
	"nectar_amarelo": {"display_name": "Néctar Amarelo", "category": "chave", "price": 400,
		"description": "Transforma Oricorio no Estilo Pom-Pom.", "effect": {"type": "orichorio_nectar", "style": "pom_pom"}, "consumable": true},
	"nectar_rosa": {"display_name": "Néctar Rosa", "category": "chave", "price": 400,
		"description": "Transforma Oricorio no Estilo Pa'u.", "effect": {"type": "orichorio_nectar", "style": "pau"}, "consumable": true},
	"nectar_roxo": {"display_name": "Néctar Roxo", "category": "chave", "price": 400,
		"description": "Transforma Oricorio no Estilo Sensu.", "effect": {"type": "orichorio_nectar", "style": "sensu"}, "consumable": true},

	# ============================================================
	# VESTIMENTAS (+1 em perícia; máximo 3 equipadas, 1 por perícia)
	# ============================================================
	"camiseta_treino": {"display_name": "Camiseta de Treino", "category": "vestimenta", "price": 250,
		"description": "+1 em Atletismo.", "effect": {"type": "skill_bonus", "skill": "atletismo", "amount": 1}, "consumable": false},
	"calcas_flexiveis": {"display_name": "Calças Flexíveis", "category": "vestimenta", "price": 250,
		"description": "+1 em Acrobacia.", "effect": {"type": "skill_bonus", "skill": "acrobacia", "amount": 1}, "consumable": false},
	"tenis_silenciosos": {"display_name": "Tênis Silenciosos", "category": "vestimenta", "price": 250,
		"description": "+1 em Furtividade.", "effect": {"type": "skill_bonus", "skill": "furtividade", "amount": 1}, "consumable": false},
	"luvas_couro": {"display_name": "Luvas de Couro", "category": "vestimenta", "price": 250,
		"description": "+1 em Prestidigitação.", "effect": {"type": "skill_bonus", "skill": "prestidigitacao", "amount": 1}, "consumable": false},
	"colar_aromatico": {"display_name": "Colar Aromático", "category": "vestimenta", "price": 250,
		"description": "+1 em Arcanismo.", "effect": {"type": "skill_bonus", "skill": "arcanismo", "amount": 1}, "consumable": false},
	"livro_bolso": {"display_name": "Livro de Bolso Ilustrado", "category": "vestimenta", "price": 250,
		"description": "+1 em História.", "effect": {"type": "skill_bonus", "skill": "historia", "amount": 1}, "consumable": false},
	"oculos_leitura": {"display_name": "Óculos de Leitura", "category": "vestimenta", "price": 250,
		"description": "+1 em Investigação.", "effect": {"type": "skill_bonus", "skill": "investigacao", "amount": 1}, "consumable": false},
	"colar_natural": {"display_name": "Colar Natural", "category": "vestimenta", "price": 250,
		"description": "+1 em Natureza.", "effect": {"type": "skill_bonus", "skill": "natureza", "amount": 1}, "consumable": false},
	"broche_religioso": {"display_name": "Broche Religioso", "category": "vestimenta", "price": 250,
		"description": "+1 em Religião.", "effect": {"type": "skill_bonus", "skill": "religiao", "amount": 1}, "consumable": false},
	"pulseira_sutil": {"display_name": "Pulseira Sutil", "category": "vestimenta", "price": 250,
		"description": "+1 em Intuição.", "effect": {"type": "skill_bonus", "skill": "intuicao", "amount": 1}, "consumable": false},
	"cinto_utensilios": {"display_name": "Cinto de Utensílios", "category": "vestimenta", "price": 250,
		"description": "+1 em Medicina.", "effect": {"type": "skill_bonus", "skill": "medicina", "amount": 1}, "consumable": false},
	"camisa_impermeavel": {"display_name": "Camisa Impermeável", "category": "vestimenta", "price": 250,
		"description": "+1 em Sobrevivência.", "effect": {"type": "skill_bonus", "skill": "sobrevivencia", "amount": 1}, "consumable": false},
	"pingente_sensorial": {"display_name": "Pingente Sensorial", "category": "vestimenta", "price": 250,
		"description": "+1 em Percepção.", "effect": {"type": "skill_bonus", "skill": "percepcao", "amount": 1}, "consumable": false},
	"capa_esvoacante": {"display_name": "Capa Esvoaçante", "category": "vestimenta", "price": 250,
		"description": "+1 em Enganação.", "effect": {"type": "skill_bonus", "skill": "enganacao", "amount": 1}, "consumable": false},
	"bandana": {"display_name": "Bandana", "category": "vestimenta", "price": 250,
		"description": "+1 em Intimidação.", "effect": {"type": "skill_bonus", "skill": "intimidacao", "amount": 1}, "consumable": false},
	"camisa_bufante": {"display_name": "Camisa Bufante", "category": "vestimenta", "price": 250,
		"description": "+1 em Atuação.", "effect": {"type": "skill_bonus", "skill": "atuacao", "amount": 1}, "consumable": false},
	"camisa_cores_vibrantes": {"display_name": "Camisa de Cores Vibrantes", "category": "vestimenta", "price": 250,
		"description": "+1 em Persuasão.", "effect": {"type": "skill_bonus", "skill": "persuasao", "amount": 1}, "consumable": false},

	# ============================================================
	# PACOTES INICIAIS
	# `contents` é uma lista de {id, qty}. Ao adicionar o pacote,
	# TrainerData.add_item expande nos itens filhos e não guarda o pacote.
	# ============================================================
	"pacote_aventureiro": {
		"display_name": "Pacote de Aventureiro", "category": "pacote", "price": 1200,
		"description": "Mochila, Kit de Escalada, Lanterna, 5 Células de Energia, Pederneira e Aço, 10 Rações, Cantil, Corda de 9 metros.",
		"effect": {"type": "package", "contents": [
			{"id": "mochila", "qty": 1},
			{"id": "kit_escalada", "qty": 1},
			{"id": "lanterna", "qty": 1},
			{"id": "celula_energia", "qty": 5},
			{"id": "pederneira_aco", "qty": 1},
			{"id": "racao_acampamento", "qty": 10},
			{"id": "cantil", "qty": 1},
			{"id": "corda_9m", "qty": 1},
		]}, "consumable": false,
	},
	"pacote_explorador": {
		"display_name": "Pacote de Explorador", "category": "pacote", "price": 1200,
		"description": "Mochila, Saco de Dormir, Kit de Refeição, Lanterna, 5 Células de Energia, Pederneira e Aço, 10 Rações, Cantil, Corda de 9 metros.",
		"effect": {"type": "package", "contents": [
			{"id": "mochila", "qty": 1},
			{"id": "saco_dormir", "qty": 1},
			{"id": "kit_refeicao", "qty": 1},
			{"id": "lanterna", "qty": 1},
			{"id": "celula_energia", "qty": 5},
			{"id": "pederneira_aco", "qty": 1},
			{"id": "racao_acampamento", "qty": 10},
			{"id": "cantil", "qty": 1},
			{"id": "corda_9m", "qty": 1},
		]}, "consumable": false,
	},
	"pacote_socorrista": {
		"display_name": "Pacote de Socorrista", "category": "pacote", "price": 1200,
		"description": "Mochila, Kit de Primeiros Socorros, Lanterna, 5 Células de Energia, Cantil, Canivete de Bolso, Casaco Impermeável, Garrafa Térmica, 10 Rações.",
		"effect": {"type": "package", "contents": [
			{"id": "mochila", "qty": 1},
			{"id": "kit_primeiros_socorros", "qty": 1},
			{"id": "lanterna", "qty": 1},
			{"id": "celula_energia", "qty": 5},
			{"id": "cantil", "qty": 1},
			{"id": "canivete_bolso", "qty": 1},
			{"id": "casaco_impermeavel", "qty": 1},
			{"id": "garrafa_termica", "qty": 1},
			{"id": "racao_acampamento", "qty": 10},
		]}, "consumable": false,
	},
	"pacote_biologo": {
		"display_name": "Pacote de Biólogo", "category": "pacote", "price": 1200,
		"description": "Mochila, Saco de Dormir, Kit de Jardinagem, Lanterna, 2 Células de Energia, Cantil, Bússola, Canivete de Bolso, Repelente, Pederneira e Aço, Carregador Solar.",
		"effect": {"type": "package", "contents": [
			{"id": "mochila", "qty": 1},
			{"id": "saco_dormir", "qty": 1},
			{"id": "kit_jardinagem", "qty": 1},
			{"id": "lanterna", "qty": 1},
			{"id": "celula_energia", "qty": 2},
			{"id": "cantil", "qty": 1},
			{"id": "bussola", "qty": 1},
			{"id": "canivete_bolso", "qty": 1},
			{"id": "repelente", "qty": 1},
			{"id": "pederneira_aco", "qty": 1},
			{"id": "carregador_solar", "qty": 1},
		]}, "consumable": false,
	},
	"pacote_mergulhador": {
		"display_name": "Pacote de Mergulhador", "category": "pacote", "price": 1200,
		"description": "Mochila, Kit de Mergulho, Respirador, Filtro para Respirador, Lanterna, 2 Células de Energia.",
		"effect": {"type": "package", "contents": [
			{"id": "mochila", "qty": 1},
			{"id": "kit_mergulho", "qty": 1},
			{"id": "respirador", "qty": 1},
			{"id": "filtro_respirador", "qty": 1},
			{"id": "lanterna", "qty": 1},
			{"id": "celula_energia", "qty": 2},
		]}, "consumable": false,
	},

	# ============================================================
	# EQUIPAMENTO DE TREINADOR
	# ============================================================
	"acessorio_lanterna": {"display_name": "Acessório de Lanterna", "category": "treinador", "price": 120,
		"description": "Lanterna pequena acoplável. Luz plena em cone de 1,5m, penumbra por mais 1,5m.",
		"effect": {"type": "light_source", "bright_m": 1.5, "dim_m": 1.5}, "consumable": false},
	"algemas": {"display_name": "Algemas", "category": "treinador", "price": 50,
		"description": "Algemas de ferro para criaturas Médias. Acrobacia CD 30 ou Força CD 25 para escapar.",
		"effect": {"type": "restraint", "break_cd": 25, "escape_cd": 30}, "consumable": false},
	"arpeu": {"display_name": "Arpéu", "category": "treinador", "price": 120,
		"description": "Gancho de aço com corda de 9m para escalar.",
		"effect": {"type": "climbing_tool"}, "consumable": false},
	"binoculos": {"display_name": "Binóculos", "category": "treinador", "price": 250,
		"description": "Vê objetos com o dobro do tamanho.",
		"effect": {"type": "magnification", "mult": 2}, "consumable": false},
	"bussola": {"display_name": "Bússola", "category": "treinador", "price": 100,
		"description": "Aponta sempre para o Norte.",
		"effect": {"type": "compass"}, "consumable": false},
	"canivete_bolso": {"display_name": "Canivete de Bolso", "category": "treinador", "price": 50,
		"description": "+prof em testes relacionados. Microferramentas.",
		"effect": {"type": "tool", "prof_on_tests": true}, "consumable": false},
	"cantil": {"display_name": "Cantil", "category": "treinador", "price": 50,
		"description": "Transporta água ou líquidos.",
		"effect": {"type": "container_liquid"}, "consumable": false},
	"carregador_solar": {"display_name": "Carregador Solar", "category": "treinador", "price": 250,
		"description": "Carrega 2 células de energia durante um descanso longo.",
		"effect": {"type": "energy_charger", "cells_per_long_rest": 2}, "consumable": false},
	"casaco_impermeavel": {"display_name": "Casaco Impermeável", "category": "treinador", "price": 250,
		"description": "+2 em testes para resistir ao frio.",
		"effect": {"type": "cold_resist", "amount": 2}, "consumable": false},
	"celula_energia": {"display_name": "Célula de Energia", "category": "treinador", "price": 20,
		"description": "Fornece energia a dispositivos eletrônicos.",
		"effect": {"type": "energy_cell"}, "consumable": true},
	"chaleira": {"display_name": "Chaleira", "category": "treinador", "price": 100,
		"description": "Esquenta líquidos em fogueira.",
		"effect": {"type": "cookware"}, "consumable": false},
	"corda_9m": {"display_name": "Corda de 9 metros", "category": "treinador", "price": 20,
		"description": "Sustenta grandes pesos. 2 PV, quebrável com Força CD 18.",
		"effect": {"type": "rope", "hp": 2, "break_cd": 18}, "consumable": false},
	"filtro_respirador": {"display_name": "Filtro para Respirador", "category": "treinador", "price": 50,
		"description": "Filtro para respirador. Dura 4 horas.",
		"effect": {"type": "respirator_filter", "duration_hours": 4}, "consumable": true},
	"fogao": {"display_name": "Fogão", "category": "treinador", "price": 250,
		"description": "Fogão portátil a lenha.",
		"effect": {"type": "cookware"}, "consumable": false},
	"garrafa_termica": {"display_name": "Garrafa Térmica", "category": "treinador", "price": 120,
		"description": "+2 em testes de resistência contra climas frios ou quentes.",
		"effect": {"type": "thermal_resist", "amount": 2}, "consumable": false},
	"kit_cozinha": {"display_name": "Kit de Cozinha", "category": "treinador", "price": 500,
		"description": "Panelas, frigideiras, utensílios. +prof em testes de cozinhar.",
		"effect": {"type": "cooking_tool", "prof_on_tests": true}, "consumable": false},
	"kit_escalada": {"display_name": "Kit de Escalada", "category": "treinador", "price": 500,
		"description": "Vantagem em escalada. Não cai mais que 7,5m. +prof em testes relacionados.",
		"effect": {"type": "climbing_tool", "advantage": true, "max_fall_m": 7.5, "prof_on_tests": true}, "consumable": false},
	"kit_jardinagem": {"display_name": "Kit de Jardinagem", "category": "treinador", "price": 350,
		"description": "Cuidar de plantas e berries. +prof em testes relacionados.",
		"effect": {"type": "gardening_tool", "prof_on_tests": true}, "consumable": false},
	"kit_mergulho": {"display_name": "Kit de Mergulho", "category": "treinador", "price": 750,
		"description": "-6m deslocamento, +9m natação. 2h de ar, mergulha até 60m, imune à temperatura da água.",
		"effect": {"type": "diving_gear", "walking_penalty_m": 6, "swim_speed_m": 9, "air_hours": 2, "max_depth_m": 60}, "consumable": false},
	"kit_primeiros_socorros": {"display_name": "Kit de Primeiros Socorros", "category": "treinador", "price": 100,
		"description": "10 usos. Estabiliza Treinador com 0 PV sem teste de Medicina.",
		"effect": {"type": "first_aid", "uses": 10, "auto_stabilize": true}, "consumable": false},
	"kit_refeicao": {"display_name": "Kit de Refeição", "category": "treinador", "price": 150,
		"description": "Caixa de aço com xícara e talheres. Um lado vira panela, o outro prato.",
		"effect": {"type": "cookware"}, "consumable": false},
	"lampiao": {"display_name": "Lampião", "category": "treinador", "price": 100,
		"description": "Luz plena em raio de 9m, penumbra por mais 9m. Célula dura 4h.",
		"effect": {"type": "light_source", "bright_m": 9, "dim_m": 9, "fuel_hours": 4}, "consumable": false},
	"lampiao_solar": {"display_name": "Lampião Solar", "category": "treinador", "price": 150,
		"description": "Luz plena em raio de 9m. Carrega ao sol, 4h de uso.",
		"effect": {"type": "light_source", "bright_m": 9, "dim_m": 9, "solar_charge": true}, "consumable": false},
	"lanterna": {"display_name": "Lanterna", "category": "treinador", "price": 50,
		"description": "Luz plena em cone de 4,5m, penumbra por mais 9m. Célula dura 4h.",
		"effect": {"type": "light_source", "bright_m": 4.5, "dim_m": 9, "fuel_hours": 4}, "consumable": false},
	"lanterna_solar": {"display_name": "Lanterna Solar", "category": "treinador", "price": 120,
		"description": "Luz plena em cone de 4,5m. Carrega ao sol, 1h de sol = 1h de uso (até 4h).",
		"effect": {"type": "light_source", "bright_m": 4.5, "dim_m": 9, "solar_charge": true}, "consumable": false},
	"mapa_regiao": {"display_name": "Mapa da Região", "category": "treinador", "price": 500,
		"description": "+5 em testes de Sobrevivência para se orientar na região.",
		"effect": {"type": "map_bonus", "amount": 5}, "consumable": false},
	"mochila": {"display_name": "Mochila", "category": "treinador", "price": 150,
		"description": "Suporta até 15kg.",
		"effect": {"type": "backpack", "capacity_kg": 15}, "consumable": false},
	"mochila_energizada": {"display_name": "Mochila Energizada", "category": "treinador", "price": 250,
		"description": "Compartimento para gerador. Carga = 1 célula de energia, recarrega em 2h numa tomada.",
		"effect": {"type": "backpack_powered", "energy_cells": 1, "recharge_hours": 2}, "consumable": false},
	"multi_ferramenta": {"display_name": "Multi-ferramenta", "category": "treinador", "price": 150,
		"description": "Alicates, tesouras, faca. +prof em testes relacionados.",
		"effect": {"type": "tool", "prof_on_tests": true}, "consumable": false},
	"oculos_protecao": {"display_name": "Óculos de Proteção", "category": "treinador", "price": 350,
		"description": "Neutraliza efeitos negativos de clima sem prejudicar a visão.",
		"effect": {"type": "weather_eye_protection"}, "consumable": false},
	"oculos_visao_noturna": {"display_name": "Óculos de Visão Noturna", "category": "treinador", "price": 2500,
		"description": "Enxerga claramente no escuro, mas sem cores.",
		"effect": {"type": "darkvision"}, "consumable": false},
	"pederneira_aco": {"display_name": "Pederneira e Aço", "category": "treinador", "price": 50,
		"description": "Faz faíscas para iniciar fogo.",
		"effect": {"type": "firestarter"}, "consumable": false},
	"racao_acampamento": {"display_name": "Ração de Acampamento", "category": "treinador", "price": 50,
		"description": "Refeição liofilizada para uma pessoa por dia.",
		"effect": {"type": "food", "meals": 1}, "consumable": true},
	"relogio_multifuncional": {"display_name": "Relógio Multifuncional", "category": "treinador", "price": 300,
		"description": "Bússola, termômetro e barômetro.",
		"effect": {"type": "multitool", "includes": ["compass", "thermometer", "barometer"]}, "consumable": false},
	"repelente": {"display_name": "Repelente", "category": "treinador", "price": 50,
		"description": "Pokémon de nível inferior não se aproximam por 2h. 3 usos.",
		"effect": {"type": "repellent", "duration_hours": 2, "uses": 3}, "consumable": true},
	"respirador": {"display_name": "Respirador", "category": "treinador", "price": 500,
		"description": "Permite respirar debaixo d'água. Filtro dura 4h.",
		"effect": {"type": "underwater_breathing", "duration_hours": 4}, "consumable": false},
	"saco_dormir": {"display_name": "Saco de Dormir", "category": "treinador", "price": 250,
		"description": "Saco de dormir para uma pessoa.",
		"effect": {"type": "camping"}, "consumable": false},
	"tenda_grande": {"display_name": "Tenda Grande", "category": "treinador", "price": 500,
		"description": "Tenda para quatro pessoas.",
		"effect": {"type": "camping", "capacity": 4}, "consumable": false},
	"tenda_pequena": {"display_name": "Tenda Pequena", "category": "treinador", "price": 250,
		"description": "Tenda para duas pessoas.",
		"effect": {"type": "camping", "capacity": 2}, "consumable": false},
	"tenis_reforcados": {"display_name": "Tênis Reforçados", "category": "treinador", "price": 200,
		"description": "+1,5m de deslocamento quando reduzido por terreno difícil.",
		"effect": {"type": "difficult_terrain_bonus_m", "amount": 1.5}, "consumable": false},

	# ============================================================
	# TESOUROS
	# ============================================================
	"rare_bone": {"display_name": "Rare Bone", "category": "tesouro", "price": 2500,
		"description": "Osso raro de grande valor arqueológico.", "effect": {"type": "treasure"}, "consumable": false},
	"tiny_mushroom": {"display_name": "Tiny Mushroom", "category": "tesouro", "price": 250,
		"description": "Cogumelo pequeno e raro.", "effect": {"type": "treasure"}, "consumable": false},
	"big_mushroom": {"display_name": "Big Mushroom", "category": "tesouro", "price": 2500,
		"description": "Cogumelo grande e raro.", "effect": {"type": "treasure"}, "consumable": false},
	"balm_mushroom": {"display_name": "Balm Mushroom", "category": "tesouro", "price": 7500,
		"description": "Cogumelo raro com fragrância agradável.", "effect": {"type": "treasure"}, "consumable": false},
	"nugget": {"display_name": "Nugget", "category": "tesouro", "price": 5000,
		"description": "Pepita de ouro puro.", "effect": {"type": "treasure"}, "consumable": false},
	"big_nugget": {"display_name": "Big Nugget", "category": "tesouro", "price": 20000,
		"description": "Grande pepita de ouro puro.", "effect": {"type": "treasure"}, "consumable": false},
	"pearl": {"display_name": "Pearl", "category": "tesouro", "price": 1000,
		"description": "Pérola pequena de brilho prateado.", "effect": {"type": "treasure"}, "consumable": false},
	"big_pearl": {"display_name": "Big Pearl", "category": "tesouro", "price": 4000,
		"description": "Pérola grande de brilho prateado.", "effect": {"type": "treasure"}, "consumable": false},
	"pearl_string": {"display_name": "Pearl String", "category": "tesouro", "price": 10000,
		"description": "Pérolas muito grandes de brilho prateado.", "effect": {"type": "treasure"}, "consumable": false},
	"stardust": {"display_name": "Stardust", "category": "tesouro", "price": 1500,
		"description": "Areia vermelha encantadora.", "effect": {"type": "treasure"}, "consumable": false},
	"star_piece": {"display_name": "Star Piece", "category": "tesouro", "price": 6000,
		"description": "Pedaço de gema avermelhada.", "effect": {"type": "treasure"}, "consumable": false},
	"comet_shard": {"display_name": "Comet Shard", "category": "tesouro", "price": 12500,
		"description": "Fragmento de cometa.", "effect": {"type": "treasure"}, "consumable": false},

	# ============================================================
	# FÓSSEIS
	# ============================================================
	"helix_fossil": {"display_name": "Helix Fossil", "category": "fossil", "price": 250,
		"description": "Traz um Omanyte de volta à vida.", "effect": {"type": "revive_fossil", "species": "omanyte"}, "consumable": true},
	"dome_fossil": {"display_name": "Dome Fossil", "category": "fossil", "price": 250,
		"description": "Traz um Kabuto de volta à vida.", "effect": {"type": "revive_fossil", "species": "kabuto"}, "consumable": true},
	"old_amber": {"display_name": "Old Amber", "category": "fossil", "price": 250,
		"description": "Traz um Aerodactyl de volta à vida.", "effect": {"type": "revive_fossil", "species": "aerodactyl"}, "consumable": true},
	"root_fossil": {"display_name": "Root Fossil", "category": "fossil", "price": 250,
		"description": "Traz um Lileep de volta à vida.", "effect": {"type": "revive_fossil", "species": "lileep"}, "consumable": true},
	"claw_fossil": {"display_name": "Claw Fossil", "category": "fossil", "price": 250,
		"description": "Traz um Anorith de volta à vida.", "effect": {"type": "revive_fossil", "species": "anorith"}, "consumable": true},
	"skull_fossil": {"display_name": "Skull Fossil", "category": "fossil", "price": 250,
		"description": "Traz um Cranidos de volta à vida.", "effect": {"type": "revive_fossil", "species": "cranidos"}, "consumable": true},
	"armor_fossil": {"display_name": "Armor Fossil", "category": "fossil", "price": 250,
		"description": "Traz um Shieldon de volta à vida.", "effect": {"type": "revive_fossil", "species": "shieldon"}, "consumable": true},
	"cover_fossil": {"display_name": "Cover Fossil", "category": "fossil", "price": 250,
		"description": "Traz um Tirtouga de volta à vida.", "effect": {"type": "revive_fossil", "species": "tirtouga"}, "consumable": true},
	"plume_fossil": {"display_name": "Plume Fossil", "category": "fossil", "price": 250,
		"description": "Traz um Archen de volta à vida.", "effect": {"type": "revive_fossil", "species": "archen"}, "consumable": true},
	"jaw_fossil": {"display_name": "Jaw Fossil", "category": "fossil", "price": 250,
		"description": "Traz um Tyrunt de volta à vida.", "effect": {"type": "revive_fossil", "species": "tyrunt"}, "consumable": true},
	"sail_fossil": {"display_name": "Sail Fossil", "category": "fossil", "price": 250,
		"description": "Traz um Amaura de volta à vida.", "effect": {"type": "revive_fossil", "species": "amaura"}, "consumable": true},
}

static func _get_raw_data(id: String) -> Dictionary:
	# Se for uma TM (ex: "tm_1"), gera os dados na hora
	if id.begins_with("tm_"):
		var num_str = id.replace("tm_", "")
		if num_str.is_valid_int():
			var num = int(num_str)
			if TmData.has_data(num):
				return {
					"display_name": TmData.get_display_name(num),
					"category": "tm",
					"price": TmData.get_price(num),
					"description": "Ensina o Move %s a um Pokémon." % TmData.get_move_id(num).capitalize(),
					"effect": {"type": "teach_tm", "tm_number": num},
					"consumable": true
				}
	# Se não for TM, busca no dicionário normal
	return DATA.get(id, {})

# --- Atualize TODAS as funções abaixo para usar _get_raw_data ---

static func has_item(id: String) -> bool:
	return not _get_raw_data(id).is_empty() or DATA.has(id)

static func get_display_name(id: String) -> String:
	var data = _get_raw_data(id)
	return data.get("display_name", id)

static func get_category(id: String) -> String:
	var data = _get_raw_data(id)
	return data.get("category", "")

static func get_price(id: String) -> int:
	var data = _get_raw_data(id)
	return data.get("price", 0)

static func get_description(id: String) -> String:
	var data = _get_raw_data(id)
	return data.get("description", "")

static func get_effect(id: String) -> Dictionary:
	var data = _get_raw_data(id)
	return data.get("effect", {})

static func is_consumable(id: String) -> bool:
	var data = _get_raw_data(id)
	return data.get("consumable", false)

static func get_ids_by_category(category_id: String) -> Array:
	# Se for categoria "tm", gera a lista das 321 TMs
	if category_id == "tm":
		var tm_ids := []
		for num in TmData.get_all_numbers():
			tm_ids.append("tm_" + str(num))
		return tm_ids

	# Senão, busca no DATA normal
	if category_id == "todos":
		return DATA.keys()
	var result := []
	for id in DATA:
		if DATA[id].get("category", "") == category_id:
			result.append(id)
	return result
