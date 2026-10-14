class_name ItemData
extends RefCounted
## Catálogo de itens do sistema (Livro de Regras, "Itens").
## Não é um sistema de loja — o jogador adiciona/remove itens manualmente.
## O `price` está aqui só como referência para o jogador descontar Pokédolares.
##
## Chaves de cada entrada:
##   display_name  -> nome de exibição
##   category      -> id de categoria (ver CATEGORIES abaixo)
##   price         -> preço em pokédolares (referência)
##   description   -> texto curto mostrado no rodapé da mochila
##   effect        -> Dictionary cru com o efeito (interpretado em 3c)
##   consumable    -> bool (decrementa no "Usar")

## Ordem das categorias na sidebar da Mochila.
## "todos" é virtual (mostra tudo), as outras são reais.
const CATEGORIES := [
	{"id": "todos",      "display_name": "Todos"},
	{"id": "pokebola",   "display_name": "Pokébolas"},
	{"id": "cura",       "display_name": "Itens de Cura"},
	{"id": "status",     "display_name": "Itens de Status"},
	{"id": "batalha",    "display_name": "Itens de Batalha"},
	{"id": "vitamina",   "display_name": "Vitaminas"},
	{"id": "berry",      "display_name": "Berries"},
	{"id": "evolutivo",  "display_name": "Itens Evolutivos"},
	{"id": "held",       "display_name": "Itens Seguráveis"},
	{"id": "chave",      "display_name": "Itens-Chave"},
]

const DATA := {
	# ============================================================
	# POKÉBOLAS
	# ============================================================
	"pokebola": {
		"display_name": "Pokébola",
		"category": "pokebola",
		"price": 250,
		"description": "+0 na Rolagem de Captura.",
		"effect": {"type": "capture", "bonus": 0},
		"consumable": true,
	},
	"great_ball": {
		"display_name": "Great Ball",
		"category": "pokebola",
		"price": 500,
		"description": "+5 na Rolagem de Captura.",
		"effect": {"type": "capture", "bonus": 5},
		"consumable": true,
	},
	"ultra_ball": {
		"display_name": "Ultra Ball",
		"category": "pokebola",
		"price": 1000,
		"description": "+10 na Rolagem de Captura.",
		"effect": {"type": "capture", "bonus": 10},
		"consumable": true,
	},
	"level_ball": {
		"display_name": "Level Ball",
		"category": "pokebola",
		"price": 800,
		"description": "+10 na Rolagem de Captura para cada 5 níveis que o Pokémon alvo tiver a menos que o Pokémon ativo, até um máximo de +30.",
		"effect": {"type": "capture", "bonus": "conditional", "condition": "level_diff"},
		"consumable": true,
	},
	"net_ball": {
		"display_name": "Net Ball",
		"category": "pokebola",
		"price": 800,
		"description": "+15 na Rolagem de Captura contra Pokémon dos tipos Inseto ou Água.",
		"effect": {"type": "capture", "bonus": 15, "condition": "type_bug_water"},
		"consumable": true,
	},
	"nest_ball": {
		"display_name": "Nest Ball",
		"category": "pokebola",
		"price": 800,
		"description": "+15 na Rolagem de Captura contra Pokémon de nível 5 ou abaixo.",
		"effect": {"type": "capture", "bonus": 15, "condition": "level_5_or_less"},
		"consumable": true,
	},
	"repeat_ball": {
		"display_name": "Repeat Ball",
		"category": "pokebola",
		"price": 800,
		"description": "+15 na Rolagem de Captura contra espécies já capturadas pelo usuário.",
		"effect": {"type": "capture", "bonus": 15, "condition": "already_caught"},
		"consumable": true,
	},
	"luxury_ball": {
		"display_name": "Luxury Ball",
		"category": "pokebola",
		"price": 800,
		"description": "+5 na Rolagem de Captura. Define o nível de Lealdade para +1 após a captura.",
		"effect": {"type": "capture", "bonus": 5, "set_loyalty": 1},
		"consumable": true,
	},
	"dive_ball": {
		"display_name": "Dive Ball",
		"category": "pokebola",
		"price": 800,
		"description": "+15 na Rolagem de Captura contra Pokémon que se encontram dentro d'água.",
		"effect": {"type": "capture", "bonus": 15, "condition": "underwater"},
		"consumable": true,
	},
	"dusk_ball": {
		"display_name": "Dusk Ball",
		"category": "pokebola",
		"price": 800,
		"description": "+15 na Rolagem de Captura à noite ou em lugares escuros como cavernas.",
		"effect": {"type": "capture", "bonus": 15, "condition": "night_or_dark"},
		"consumable": true,
	},
	"moon_ball": {
		"display_name": "Moon Ball",
		"category": "pokebola",
		"price": 1000,
		"description": "+20 na Rolagem de Captura contra Pokémon que evoluem com a Moon Stone.",
		"effect": {"type": "capture", "bonus": 20, "condition": "moon_stone_evolution"},
		"consumable": true,
	},
	"heal_ball": {
		"display_name": "Heal Ball",
		"category": "pokebola",
		"price": 1000,
		"description": "+5 na Rolagem de Captura. Restaura a saúde do Pokémon capturado e cura todas as condições de status.",
		"effect": {"type": "capture", "bonus": 5, "heal_on_capture": true},
		"consumable": true,
	},
	"timer_ball": {
		"display_name": "Timer Ball",
		"category": "pokebola",
		"price": 1200,
		"description": "+2 na Rolagem de Captura para cada rodada de combate que passou antes de lançar (Máximo de +20).",
		"effect": {"type": "capture", "bonus": "conditional", "condition": "rounds_passed"},
		"consumable": true,
	},
	"premier_ball": {
		"display_name": "Premier Ball",
		"category": "pokebola",
		"price": 1200,
		"description": "+5 na Rolagem de Captura. Aumenta o Carisma do Pokémon permanentemente em +2.",
		"effect": {"type": "capture", "bonus": 5, "permanent_cha": 2},
		"consumable": true,
	},
	"quick_ball": {
		"display_name": "Quick Ball",
		"category": "pokebola",
		"price": 1200,
		"description": "+20 na Rolagem de Captura apenas se usado na primeira rodada do combate.",
		"effect": {"type": "capture", "bonus": 20, "condition": "first_round"},
		"consumable": true,
	},
	"lure_ball": {
		"display_name": "Lure Ball",
		"category": "pokebola",
		"price": 1200,
		"description": "+20 na Rolagem de Captura contra Pokémon pescados por você.",
		"effect": {"type": "capture", "bonus": 20, "condition": "fished"},
		"consumable": true,
	},
	"love_ball": {
		"display_name": "Love Ball",
		"category": "pokebola",
		"price": 1300,
		"description": "+30 na Rolagem de Captura contra um Pokémon alvo da mesma espécie que o Pokémon ativo, porém do gênero oposto.",
		"effect": {"type": "capture", "bonus": 30, "condition": "opposite_gender_same_species"},
		"consumable": true,
	},
	"heavy_ball": {
		"display_name": "Heavy Ball",
		"category": "pokebola",
		"price": 2000,
		"description": "+5 na Rolagem de Captura contra Pokémon de tamanho Médio, e mais 5 para cada escala de tamanho acima.",
		"effect": {"type": "capture", "bonus": "conditional", "condition": "size"},
		"consumable": true,
	},
	"beast_ball": {
		"display_name": "Beast Ball",
		"category": "pokebola",
		"price": -1,
		"description": "+20 na Rolagem de Captura contra um Pokémon Ultra Beast.",
		"effect": {"type": "capture", "bonus": 20, "condition": "ultra_beast"},
		"consumable": true,
	},
	"master_ball": {
		"display_name": "Master Ball",
		"category": "pokebola",
		"price": -1,   # não vendida
		"description": "Sucesso automático na Rolagem de Captura.",
		"effect": {"type": "capture", "auto_success": true},
		"consumable": true,
	},

	# ============================================================
	# ITENS DE CURA (poções, revives, ethers, sacred ash)
	# ============================================================
	"pocao": {
		"display_name": "Poção",
		"category": "cura",
		"price": 200,
		"description": "Restaura 2d4+2 PV.",
		"effect": {"type": "heal", "dice": "2d4+2"},
		"consumable": true,
	},
	"pocao_super": {
		"display_name": "Poção Super",
		"category": "cura",
		"price": 500,
		"description": "Restaura 3d6+6 PV.",
		"effect": {"type": "heal", "dice": "3d6+6"},
		"consumable": true,
	},
	"pocao_hyper": {
		"display_name": "Poção Hyper",
		"category": "cura",
		"price": 800,
		"description": "Restaura 4d12+10 PV.",
		"effect": {"type": "heal", "dice": "4d12+10"},
		"consumable": true,
	},
	"revive": {
		"display_name": "Revive",
		"category": "cura",
		"price": 450,
		"description": "Revive um Pokémon desmaiado e cura 2d4+2 PV.",
		"effect": {"type": "revive", "dice": "2d4+2"},
		"consumable": true,
	},
	"max_revive": {
		"display_name": "Max Revive",
		"category": "cura",
		"price": 3000,
		"description": "Revive um Pokémon desmaiado e cura 4d12+10 PV.",
		"effect": {"type": "revive", "dice": "4d12+10"},
		"consumable": true,
	},
	"ether": {
		"display_name": "Ether",
		"category": "cura",
		"price": 500,
		"description": "Restaura 5 PP para um único Move.",
		"effect": {"type": "restore_pp", "amount": 5, "scope": "single"},
		"consumable": true,
	},
	"max_ether": {
		"display_name": "Max Ether",
		"category": "cura",
		"price": 900,
		"description": "Restaura 10 PP para um único Move.",
		"effect": {"type": "restore_pp", "amount": 10, "scope": "single"},
		"consumable": true,
	},
	"elixir": {
		"display_name": "Elixir",
		"category": "cura",
		"price": 1800,
		"description": "Restaura 5 PP para todos os Moves.",
		"effect": {"type": "restore_pp", "amount": 5, "scope": "all"},
		"consumable": true,
	},
	"max_elixir": {
		"display_name": "Max Elixir",
		"category": "cura",
		"price": 3200,
		"description": "Restaura 10 PP para todos os Moves.",
		"effect": {"type": "restore_pp", "amount": 10, "scope": "all"},
		"consumable": true,
	},
	"sacred_ash": {
		"display_name": "Sacred Ash",
		"category": "cura",
		"price": 10000,
		"description": "Restaura completamente os PV de todos os Pokémon desmaiados carregados pelo Treinador. Apenas utilizável fora de batalha.",
		"effect": {"type": "full_heal_all", "only_out_of_battle": true},
		"consumable": true,
	},

	# ============================================================
	# ITENS DE STATUS (cura de condições específicas)
	# ============================================================
	"antidote": {
		"display_name": "Antidote",
		"category": "status",
		"price": 200,
		"description": "Cura instantaneamente um Pokémon do status Envenenado ou Gravemente Envenenado.",
		"effect": {"type": "cure_status", "status": ["poisoned", "badly_poisoned"]},
		"consumable": true,
	},
	"paralyze_heal": {
		"display_name": "Paralyze Heal",
		"category": "status",
		"price": 200,
		"description": "Cura instantaneamente um Pokémon do status Paralisado.",
		"effect": {"type": "cure_status", "status": ["paralyzed"]},
		"consumable": true,
	},
	"burn_heal": {
		"display_name": "Burn Heal",
		"category": "status",
		"price": 200,
		"description": "Cura instantaneamente um Pokémon do status Queimado.",
		"effect": {"type": "cure_status", "status": ["burned"]},
		"consumable": true,
	},
	"ice_heal": {
		"display_name": "Ice Heal",
		"category": "status",
		"price": 200,
		"description": "Cura instantaneamente um Pokémon do status Congelado.",
		"effect": {"type": "cure_status", "status": ["frozen"]},
		"consumable": true,
	},
	"awakening": {
		"display_name": "Awakening",
		"category": "status",
		"price": 200,
		"description": "Acorda instantaneamente um Pokémon do status Sonolento ou Dormindo.",
		"effect": {"type": "cure_status", "status": ["drowsy", "asleep"]},
		"consumable": true,
	},
	"full_heal": {
		"display_name": "Full Heal",
		"category": "status",
		"price": 450,
		"description": "Cura todas as condições de status e concede imunidade a elas por uma rodada.",
		"effect": {"type": "cure_status", "status": "all", "immunity_one_round": true},
		"consumable": true,
	},
	"lava_cookie": {
		"display_name": "Lava Cookie",
		"category": "status",
		"price": 200,
		"description": "Cura todas as condições de status.",
		"effect": {"type": "cure_status", "status": "all"},
		"consumable": true,
	},

	# ============================================================
	# ITENS DE BATALHA (Itens-X)
	# ============================================================
	"x_attack": {
		"display_name": "X Attack",
		"category": "batalha",
		"price": 350,
		"description": "Aumenta o Ataque em 2 estágios.",
		"effect": {"type": "stat_boost", "stat": "atk", "stages": 2},
		"consumable": true,
	},
	"x_defense": {
		"display_name": "X Defense",
		"category": "batalha",
		"price": 350,
		"description": "Aumenta a Defesa em 2 estágios.",
		"effect": {"type": "stat_boost", "stat": "def", "stages": 2},
		"consumable": true,
	},
	"x_special_attack": {
		"display_name": "X Special Attack",
		"category": "batalha",
		"price": 350,
		"description": "Aumenta o Ataque Especial em 2 estágios.",
		"effect": {"type": "stat_boost", "stat": "spa", "stages": 2},
		"consumable": true,
	},
	"x_special_defense": {
		"display_name": "X Special Defense",
		"category": "batalha",
		"price": 350,
		"description": "Aumenta a Defesa Especial em 2 estágios.",
		"effect": {"type": "stat_boost", "stat": "spd", "stages": 2},
		"consumable": true,
	},
	"x_speed": {
		"display_name": "X Speed",
		"category": "batalha",
		"price": 350,
		"description": "Aumenta a Velocidade em 2 estágios.",
		"effect": {"type": "stat_boost", "stat": "spe", "stages": 2},
		"consumable": true,
	},
	"x_accuracy": {
		"display_name": "X Accuracy",
		"category": "batalha",
		"price": 350,
		"description": "Aumenta a Precisão em 2 estágios.",
		"effect": {"type": "stat_boost", "stat": "acc", "stages": 2},
		"consumable": true,
	},
	"dire_hit": {
		"display_name": "Dire Hit",
		"category": "batalha",
		"price": 400,
		"description": "Aumenta a margem de crítico em 1 estágio.",
		"effect": {"type": "stat_boost", "stat": "crit", "stages": 1},
		"consumable": true,
	},
	"guard_spec": {
		"display_name": "Guard Spec",
		"category": "batalha",
		"price": 700,
		"description": "Previne reduções nas mudanças de status por 5 rodadas.",
		"effect": {"type": "prevent_stat_drop", "duration": 5},
		"consumable": true,
	},

	# ============================================================
	# VITAMINAS
	# ============================================================
	"protein": {
		"display_name": "Protein",
		"category": "vitamina",
		"price": 4900,
		"description": "Recebe imediatamente 2 Pontos de EV em FOR.",
		"effect": {"type": "ev", "stat": "str", "amount": 2},
		"consumable": true,
	},
	"carbos": {
		"display_name": "Carbos",
		"category": "vitamina",
		"price": 4900,
		"description": "Recebe imediatamente 2 Pontos de EV em DES.",
		"effect": {"type": "ev", "stat": "dex", "amount": 2},
		"consumable": true,
	},
	"iron": {
		"display_name": "Iron",
		"category": "vitamina",
		"price": 4900,
		"description": "Recebe imediatamente 2 Pontos de EV em CON.",
		"effect": {"type": "ev", "stat": "con", "amount": 2},
		"consumable": true,
	},
	"zinc": {
		"display_name": "Zinc",
		"category": "vitamina",
		"price": 4900,
		"description": "Recebe imediatamente 2 Pontos de EV em SAB.",
		"effect": {"type": "ev", "stat": "wis", "amount": 2},
		"consumable": true,
	},
	"calcium": {
		"display_name": "Calcium",
		"category": "vitamina",
		"price": 4900,
		"description": "Recebe imediatamente 2 Pontos de EV em CAR.",
		"effect": {"type": "ev", "stat": "cha", "amount": 2},
		"consumable": true,
	},
	"hp_up": {
		"display_name": "HP Up",
		"category": "vitamina",
		"price": 8800,
		"description": "Aumenta o PV máximo em um valor igual ao resultado máximo do seu dado de vida. Pode ser usado até 3x em um único Pokémon.",
		"effect": {"type": "max_hp_bonus", "uses_max": 3},
		"consumable": true,
	},
	"pp_up": {
		"display_name": "PP Up",
		"category": "vitamina",
		"price": 8800,
		"description": "Aumenta o máximo de PP de um Move em 2. Pode ser usado até 3x em um único Move.",
		"effect": {"type": "max_pp_bonus", "amount": 2, "uses_max": 3},
		"consumable": true,
	},

	# ============================================================
	# BERRIES (subset mais usadas em combate)
	# ============================================================
	"cheri_berry": {
		"display_name": "Cheri Berry",
		"category": "berry",
		"price": 150,
		"description": "Cura paralisia. Ativado quando o Pokémon fica paralisado.",
		"effect": {"type": "cure_status", "status": ["paralyzed"], "trigger": "on_paralysis"},
		"consumable": true,
	},
	"chesto_berry": {
		"display_name": "Chesto Berry",
		"category": "berry",
		"price": 150,
		"description": "Acorda da condição sonolento ou dormindo.",
		"effect": {"type": "cure_status", "status": ["drowsy", "asleep"], "trigger": "on_sleep"},
		"consumable": true,
	},
	"pecha_berry": {
		"display_name": "Pecha Berry",
		"category": "berry",
		"price": 150,
		"description": "Cura envenenamento. Ativado quando o Pokémon é envenenado ou gravemente envenenado.",
		"effect": {"type": "cure_status", "status": ["poisoned", "badly_poisoned"], "trigger": "on_poison"},
		"consumable": true,
	},
	"rawst_berry": {
		"display_name": "Rawst Berry",
		"category": "berry",
		"price": 150,
		"description": "Cura queimadura. Ativado quando o Pokémon é queimado.",
		"effect": {"type": "cure_status", "status": ["burned"], "trigger": "on_burn"},
		"consumable": true,
	},
	"aspear_berry": {
		"display_name": "Aspear Berry",
		"category": "berry",
		"price": 150,
		"description": "Cura congelamento. Ativado quando o Pokémon é congelado.",
		"effect": {"type": "cure_status", "status": ["frozen"], "trigger": "on_freeze"},
		"consumable": true,
	},
	"leppa_berry": {
		"display_name": "Leppa Berry",
		"category": "berry",
		"price": 400,
		"description": "Restaura 10 PP para um Move. Ativado quando o Pokémon fica sem PP para um Move.",
		"effect": {"type": "restore_pp", "amount": 10, "trigger": "on_pp_empty"},
		"consumable": true,
	},
	"oran_berry": {
		"display_name": "Oran Berry",
		"category": "berry",
		"price": 100,
		"description": "Restaura 2d4+2 PV. Ativado quando o Pokémon cai abaixo de 50% de PV.",
		"effect": {"type": "heal", "dice": "2d4+2", "trigger": "below_50_hp"},
		"consumable": true,
	},
	"persim_berry": {
		"display_name": "Persim Berry",
		"category": "berry",
		"price": 150,
		"description": "Cura confusão. Ativado quando o Pokémon fica confuso.",
		"effect": {"type": "cure_confusion", "trigger": "on_confusion"},
		"consumable": true,
	},
	"lum_berry": {
		"display_name": "Lum Berry",
		"category": "berry",
		"price": 300,
		"description": "Cura qualquer condição de status negativa.",
		"effect": {"type": "cure_status", "status": "all", "trigger": "on_any_status"},
		"consumable": true,
	},
	"sitrus_berry": {
		"display_name": "Sitrus Berry",
		"category": "berry",
		"price": 250,
		"description": "Restaura 5d6 PV. Ativado quando o Pokémon cai abaixo de 50% de PV.",
		"effect": {"type": "heal", "dice": "5d6", "trigger": "below_50_hp"},
		"consumable": true,
	},

	# ============================================================
	# ITENS EVOLUTIVOS (subset de pedras mais usadas)
	# ============================================================
	"fire_stone": {
		"display_name": "Fire Stone",
		"category": "evolutivo",
		"price": 4000,
		"description": "Evolui Vulpix, Growlithe, Eevee e Pansear.",
		"effect": {"type": "evolve", "targets": ["vulpix", "growlithe", "eevee", "pansear"]},
		"consumable": true,
	},
	"water_stone": {
		"display_name": "Water Stone",
		"category": "evolutivo",
		"price": 4000,
		"description": "Evolui Poliwhirl, Shellder, Eevee, Staryu, Lombre e Panpour.",
		"effect": {"type": "evolve", "targets": ["poliwhirl", "shellder", "eevee", "staryu", "lombre", "panpour"]},
		"consumable": true,
	},
	"thunder_stone": {
		"display_name": "Thunder Stone",
		"category": "evolutivo",
		"price": 4000,
		"description": "Evolui Pikachu, Eevee, Eelektrik e Charjabug.",
		"effect": {"type": "evolve", "targets": ["pikachu", "eevee", "eelektrik", "charjabug"]},
		"consumable": true,
	},
	"leaf_stone": {
		"display_name": "Leaf Stone",
		"category": "evolutivo",
		"price": 4000,
		"description": "Evolui Eevee, Gloom, Weepinbell, Exeggcute, Nuzleaf e Pansage.",
		"effect": {"type": "evolve", "targets": ["eevee", "gloom", "weepinbell", "exeggcute", "nuzleaf", "pansage"]},
		"consumable": true,
	},
	"moon_stone": {
		"display_name": "Moon Stone",
		"category": "evolutivo",
		"price": 4000,
		"description": "Evolui Nidorina, Nidorino, Clefairy, Jigglypuff, Skitty e Munna.",
		"effect": {"type": "evolve", "targets": ["nidorina", "nidorino", "clefairy", "jigglypuff", "skitty", "munna"]},
		"consumable": true,
	},
	"sun_stone": {
		"display_name": "Sun Stone",
		"category": "evolutivo",
		"price": 4000,
		"description": "Evolui Gloom, Sunkern, Cottonee, Petilil e Helioptile.",
		"effect": {"type": "evolve", "targets": ["gloom", "sunkern", "cottonee", "petilil", "helioptile"]},
		"consumable": true,
	},
	"shiny_stone": {
		"display_name": "Shiny Stone",
		"category": "evolutivo",
		"price": 4000,
		"description": "Evolui Togetic, Roselia, Minccino e Floette.",
		"effect": {"type": "evolve", "targets": ["togetic", "roselia", "minccino", "floette"]},
		"consumable": true,
	},
	"dusk_stone": {
		"display_name": "Dusk Stone",
		"category": "evolutivo",
		"price": 4000,
		"description": "Evolui Misdreavus, Murkrow, Lampent e Doublade.",
		"effect": {"type": "evolve", "targets": ["misdreavus", "murkrow", "lampent", "doublade"]},
		"consumable": true,
	},
	"dawn_stone": {
		"display_name": "Dawn Stone",
		"category": "evolutivo",
		"price": 4000,
		"description": "Evolui Kirlia e Snorunt.",
		"effect": {"type": "evolve", "targets": ["kirlia", "snorunt"]},
		"consumable": true,
	},
	"ice_stone": {
		"display_name": "Ice Stone",
		"category": "evolutivo",
		"price": 4000,
		"description": "Evolui Eevee, Sandshrew de Alola e Vulpix de Alola.",
		"effect": {"type": "evolve", "targets": ["eevee", "sandshrew_alola", "vulpix_alola"]},
		"consumable": true,
	},

	# ============================================================
	# ITENS SEGURÁVEIS (subset mais usados)
	# ============================================================
	"leftovers": {
		"display_name": "Leftovers",
		"category": "held",
		"price": 4400,
		"description": "Restaura PV = metade de seu nível no final de cada um de seus turnos.",
		"effect": {"type": "end_of_turn_heal", "amount": "half_level"},
		"consumable": false,
	},
	"choice_band": {
		"display_name": "Choice Band",
		"category": "held",
		"price": 4000,
		"description": "O portador só pode usar o primeiro Move escolhido. Em troca, adiciona o bônus de proficiência às jogadas de dano de seus ataques corpo a corpo.",
		"effect": {"type": "lock_move", "boost": "prof", "scope": "physical"},
		"consumable": false,
	},
	"choice_specs": {
		"display_name": "Choice Specs",
		"category": "held",
		"price": 4000,
		"description": "O portador só pode usar o primeiro Move escolhido. Em troca, adiciona o bônus de proficiência às jogadas de dano de seus ataques à distância.",
		"effect": {"type": "lock_move", "boost": "prof", "scope": "ranged"},
		"consumable": false,
	},
	"choice_scarf": {
		"display_name": "Choice Scarf",
		"category": "held",
		"price": 4000,
		"description": "O portador só pode usar o primeiro Move escolhido. Em troca, adiciona o bônus de proficiência em sua iniciativa e seu deslocamento aumenta em 5 pés (1,5 metros).",
		"effect": {"type": "lock_move", "boost": "prof_initiative", "extra_movement": 5},
		"consumable": false,
	},
	"life_orb": {
		"display_name": "Life Orb",
		"category": "held",
		"price": 4400,
		"description": "O portador adiciona o bônus de proficiência às suas rolagens de dano, mas perde pontos de vida igual ao mesmo valor ao causar dano.",
		"effect": {"type": "damage_boost_with_recoil", "amount": "prof"},
		"consumable": false,
	},
	"focus_sash": {
		"display_name": "Focus Sash",
		"category": "held",
		"price": 2000,
		"description": "Se o portador estiver com PV cheios e o primeiro dano recebido for maior que metade de sua vida máxima, esse dano é reduzido pela metade. Se mesmo reduzido for capaz de desmaiá-lo, o portador fica com 1 PV.",
		"effect": {"type": "survive_at_1_hp", "condition": "full_hp_first_hit"},
		"consumable": true,
	},
	"assault_vest": {
		"display_name": "Assault Vest",
		"category": "held",
		"price": 4400,
		"description": "O portador reduz todo dano recebido de ataques à distância em um valor igual ao seu bônus de proficiência, mas só pode usar Moves de dano.",
		"effect": {"type": "ranged_damage_reduction", "amount": "prof", "restrict_to_damage_moves": true},
		"consumable": false,
	},

	# ============================================================
	# ITENS-CHAVE
	# ============================================================
	"pokedex": {
		"display_name": "Pokédex",
		"category": "chave",
		"price": 10000,
		"description": "Usado para registrar Pokémon. Revela SR básico e fatos sobre a espécie.",
		"effect": {"type": "scan_pokemon", "range_ft": 50},
		"consumable": false,
	},
	"rotom_dex": {
		"display_name": "Rotom Dex",
		"category": "chave",
		"price": 50000,
		"description": "Registra automaticamente Pokémon num raio de 50 pés. Permite trocas com o PC até 2x por dia.",
		"effect": {"type": "auto_scan", "range_ft": 50, "pc_trades_per_day": 2},
		"consumable": false,
	},
	"bicicleta_corrida": {
		"display_name": "Bicicleta de Corrida",
		"category": "chave",
		"price": 10000,
		"description": "Move-se até 200 pés (60m) por turno em estradas asfaltadas, aumentando 10 pés a cada turno.",
		"effect": {"type": "movement_boost", "max_ft": 200, "terrain": "paved"},
		"consumable": false,
	},
	"escape_rope": {
		"display_name": "Escape Rope",
		"category": "chave",
		"price": 200,
		"description": "Ao ser amarrada em um nó, indica o caminho de saída de uma caverna.",
		"effect": {"type": "escape_cave"},
		"consumable": true,
	},
	"exp_share": {
		"display_name": "Exp. Share",
		"category": "chave",
		"price": 7500,
		"description": "Uma criatura segurando este item recebe metade da experiência total obtida em cada combate.",
		"effect": {"type": "share_xp", "fraction": 0.5},
		"consumable": false,
	},
	"ability_capsule": {
		"display_name": "Ability Capsule",
		"category": "chave",
		"price": 12000,
		"description": "Permite um Pokémon trocar a habilidade passiva não oculta que ele conhece (se duas opções estiverem disponíveis).",
		"effect": {"type": "swap_ability"},
		"consumable": true,
	},
	"ability_patch": {
		"display_name": "Ability Patch",
		"category": "chave",
		"price": 25000,
		"description": "Permite um Pokémon trocar a habilidade passiva para a habilidade oculta.",
		"effect": {"type": "unlock_hidden_ability"},
		"consumable": true,
	},
	"shiny_charm": {
		"display_name": "Shiny Charm",
		"category": "chave",
		"price": 50000,
		"description": "Aumenta em +5 a margem de sucesso em d100 para encontrar Pokémon Brilhantes.",
		"effect": {"type": "shiny_boost", "amount": 5},
		"consumable": false,
	},
	"mega_bracelete": {
		"display_name": "Mega Bracelete",
		"category": "chave",
		"price": -1,
		"description": "Bracelete capaz de portar uma Pedra-Chave, necessária para realizar a Mega Evolução.",
		"effect": {"type": "enable_mega"},
		"consumable": false,
	},
	"bracelete_z": {
		"display_name": "Bracelete-Z",
		"category": "chave",
		"price": -1,
		"description": "Bracelete capaz de portar um Cristal-Z. Ambos são necessários para realizar um Z-Move.",
		"effect": {"type": "enable_zmove"},
		"consumable": false,
	},
}

static func has_item(id: String) -> bool:
	return DATA.has(id)

static func get_display_name(id: String) -> String:
	return DATA.get(id, {}).get("display_name", id)

static func get_category(id: String) -> String:
	return DATA.get(id, {}).get("category", "")

static func get_price(id: String) -> int:
	return DATA.get(id, {}).get("price", 0)

static func get_description(id: String) -> String:
	return DATA.get(id, {}).get("description", "")

static func get_effect(id: String) -> Dictionary:
	return DATA.get(id, {}).get("effect", {})

static func is_consumable(id: String) -> bool:
	return DATA.get(id, {}).get("consumable", false)

## Lista de ids de itens de uma categoria (ou todos se category_id == "todos").
static func get_ids_by_category(category_id: String) -> Array:
	if category_id == "todos":
		return DATA.keys()
	var result := []
	for id in DATA:
		if DATA[id].get("category", "") == category_id:
			result.append(id)
	return result

static func get_category_display_name(category_id: String) -> String:
	for c in CATEGORIES:
		if c["id"] == category_id:
			return c["display_name"]
	return category_id
