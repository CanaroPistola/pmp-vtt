class_name MovePopup
extends Window

@onready var panel_main: PanelContainer = $PanelContainer
@onready var title_panel: PanelContainer = $PanelContainer/MarginContainer/VBoxContainer/TitlePanel
@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TitlePanel/TitleLabel

@onready var pp_value: Label = $PanelContainer/MarginContainer/VBoxContainer/StatsGrid/PPBox/Value
@onready var damage_value: Label = $PanelContainer/MarginContainer/VBoxContainer/StatsGrid/DamageBox/Value
@onready var cost_value: Label = $PanelContainer/MarginContainer/VBoxContainer/StatsGrid/CostBox/Value
@onready var range_value: Label = $PanelContainer/MarginContainer/VBoxContainer/StatsGrid/RangeBox/Value
@onready var power_value: Label = $PanelContainer/MarginContainer/VBoxContainer/StatsGrid/PowerBox/Value
@onready var duration_value: Label = $PanelContainer/MarginContainer/VBoxContainer/StatsGrid/DurationBox/Value

@onready var desc_panel: PanelContainer = $PanelContainer/MarginContainer/VBoxContainer/DescPanel
@onready var desc_label: Label = $PanelContainer/MarginContainer/VBoxContainer/DescPanel/MarginContainer/ScrollContainer/DescriptionLabel
@onready var type_image: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/BottomBox/TypeImage
@onready var type_name: Label = $PanelContainer/MarginContainer/VBoxContainer/BottomBox/TypeNameLabel

const TYPE_ASSET_DIR := "res://assets/types/"

const TYPE_COLORS := {
	Constants.PokemonType.NORMAL: Color("#A8A878"),
	Constants.PokemonType.FIRE: Color("#F08030"),
	Constants.PokemonType.WATER: Color("#6890F0"),
	Constants.PokemonType.ELECTRIC: Color("#F8D030"),
	Constants.PokemonType.GRASS: Color("#78C850"),
	Constants.PokemonType.ICE: Color("#98D8D8"),
	Constants.PokemonType.FIGHTING: Color("#C03028"),
	Constants.PokemonType.POISON: Color("#A040A0"),
	Constants.PokemonType.GROUND: Color("#E0C068"),
	Constants.PokemonType.FLYING: Color("#A890F0"),
	Constants.PokemonType.PSYCHIC: Color("#F85888"),
	Constants.PokemonType.BUG: Color("#A8B820"),
	Constants.PokemonType.ROCK: Color("#B8A038"),
	Constants.PokemonType.GHOST: Color("#705898"),
	Constants.PokemonType.DRAGON: Color("#7038F8"),
	Constants.PokemonType.DARK: Color("#705848"),
	Constants.PokemonType.STEEL: Color("#B8B8D0"),
	Constants.PokemonType.FAIRY: Color("#EE99AC"),
}

const TYPE_NAMES := {
	Constants.PokemonType.NORMAL: "NORMAL",
	Constants.PokemonType.FIRE: "FOGO",
	Constants.PokemonType.WATER: "ÁGUA",
	Constants.PokemonType.ELECTRIC: "ELÉTRICO",
	Constants.PokemonType.GRASS: "GRAMA",
	Constants.PokemonType.ICE: "GELO",
	Constants.PokemonType.FIGHTING: "LUTADOR",
	Constants.PokemonType.POISON: "VENENOSO",
	Constants.PokemonType.GROUND: "TERRA",
	Constants.PokemonType.FLYING: "VOADOR",
	Constants.PokemonType.PSYCHIC: "PSÍQUICO",
	Constants.PokemonType.BUG: "INSETO",
	Constants.PokemonType.ROCK: "PEDRA",
	Constants.PokemonType.GHOST: "FANTASMA",
	Constants.PokemonType.DRAGON: "DRAGÃO",
	Constants.PokemonType.DARK: "SOMBRIO",
	Constants.PokemonType.STEEL: "AÇO",
	Constants.PokemonType.FAIRY: "FADA",
}

var _type_textures: Dictionary = {}

func _ready() -> void:
	close_requested.connect(hide)
	
	# Opcional: Deixa o texto do título e do nome do tipo mais bonito
	title_label.add_theme_font_size_override("font_size", 24)
	type_name.add_theme_font_size_override("font_size", 16)

## Preenche os dados do popup. Chame este método ao clicar no MoveSlot.
func setup(move: MoveData, pkmn: PokemonInstance, current_pp: int) -> void:
	if not move or not pkmn: return
	
	# 1. Textos Básicos
	title_label.text = move.display_name.to_upper()
	pp_value.text = "%d/%d" % [current_pp, move.pp]
	cost_value.text = move.get_activation_display()
	range_value.text = move.get_range_display()
	duration_value.text = move.get_duration_display()
	power_value.text = move.get_move_power_string()
	desc_label.text = move.description

	# 2. Cálculo de Dano
	_calculate_damage(move, pkmn)

	# 3. Cores e Imagem do Tipo
	_apply_type_visuals(move.type)
	
	# Abre a janela centralizada na tela
	popup_centered()

func _calculate_damage(move: MoveData, pkmn: PokemonInstance) -> void:
	if move.damage_by_level.is_empty():
		damage_value.text = "Status"
		return
		
	# Pega a string de dados baseada no nível (ex: "2d12")
	var dice_str = move.get_damage_string(pkmn.level)
	if dice_str == "":
		damage_value.text = "Status"
		return
		
	# Pega o modificador do atributo (ex: FOR ou DES)
	var mod_value = 0
	if not move.move_power_attributes.is_empty():
		# Se tiver mais de um (ex: FOR/DES), pega o maior modificador entre eles
		for attr in move.move_power_attributes:
			var mod = pkmn.get_attribute_modifier(attr)
			if mod > mod_value:
				mod_value = mod
				
	# Aplica a penalidade/acréscimo do Move (ex: -2)
	mod_value += move.move_power_modifier
	
	# Calcula STAB
	var stab = 0
	# Verifica se o tipo do move está nos tipos do Pokémon
	var pkmn_types = pkmn.get_form_data().get("types", [])
	if move.type in pkmn_types:
		stab = pkmn.stab
		
	# Monta o texto final. Ex: 2d12 + 3 + 2
	var final_text = dice_str
	if mod_value != 0:
		final_text += (" + %d" % mod_value) if mod_value > 0 else (" - %d" % abs(mod_value))
	if stab != 0:
		final_text += " + %d (STAB)" % stab
		
	damage_value.text = final_text

func _apply_type_visuals(type: Constants.PokemonType) -> void:
	var color = TYPE_COLORS.get(type, Color.WHITE)
	var dark_color = color.darkened(0.4)
	var light_color = color.lightened(0.2)
	
	# Pinta o painel principal (Borda e Fundo)
	var style_main = StyleBoxFlat.new()
	style_main.bg_color = light_color
	style_main.border_color = dark_color
	style_main.set_border_width_all(4) # Borda grossa igual a imagem de referência
	style_main.set_corner_radius_all(8)
	panel_main.add_theme_stylebox_override("panel", style_main)
	
	# Pinta o painel do título (Fundo escuro)
	var title_style = StyleBoxFlat.new()
	title_style.bg_color = dark_color
	title_style.set_corner_radius_all(4)
	title_panel.add_theme_stylebox_override("panel", title_style)
	
	# Ajusta a cor da fonte do título (Preto se a cor for clara, Branco se for escura)
	var text_color = Color.BLACK if color.get_luminance() > 0.5 else Color.WHITE
	title_label.add_theme_color_override("font_color", text_color)
	
	# Pinta o painel de descrição (Fundo bege/creme)
	var desc_style = StyleBoxFlat.new()
	desc_style.bg_color = Color(0.96, 0.93, 0.86) # Cor creme
	desc_style.set_corner_radius_all(4)
	desc_style.content_margin_left = 8
	desc_style.content_margin_right = 8
	desc_style.content_margin_top = 8
	desc_style.content_margin_bottom = 8
	desc_panel.add_theme_stylebox_override("panel", desc_style)
	
	# Coloca o nome do tipo no rodapé
	type_name.text = TYPE_NAMES.get(type, "???")
	type_name.add_theme_color_override("font_color", Color.WHITE) # Como o fundo é colorido, a fonte fica branca
	
	# Carrega a imagem do tipo
	var type_name_str = Constants.PokemonType.keys()[type].to_lower()
	var path = TYPE_ASSET_DIR + type_name_str + ".png"
	if ResourceLoader.exists(path):
		type_image.texture = load(path)
		type_image.show()
	else:
		type_image.hide()
