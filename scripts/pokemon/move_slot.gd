class_name MoveSlot
extends PanelContainer

signal move_clicked(move: MoveData, pkmn: PokemonInstance)

const TYPE_ASSET_DIR := "res://assets/types/"
const MOVE_POPUP_SCENE = preload("res://scenes/pokemon/move_popup.tscn") # Ajuste o caminho se necessário

@onready var move_name_label: Label = $MarginContainer/VBoxContainer/MoveNameLabel
@onready var type_image: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer/TypeImage
@onready var pp_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/PPLabel

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

var _type_textures: Dictionary = {}
var _popup_instance: Window

# Variáveis para guardar os dados atuais do slot
var _current_move: MoveData
var _current_pkmn: PokemonInstance
var _current_pp: int

func _ready() -> void:
	# --- Configuração do Layout ---
	move_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	move_name_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	move_name_label.clip_text = true
	move_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	pp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	pp_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pp_label.size_flags_horizontal = Control.SIZE_SHRINK_END

	type_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	type_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	type_image.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	type_image.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	type_image.custom_minimum_size = Vector2(60, 20)
	
	# Trava o tamanho do painel para todos ficarem iguais
	custom_minimum_size.x = 140
	custom_minimum_size.y = 50

	# --- Configuração de Interação ---
	# Transforma o painel em um botão clicável
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	gui_input.connect(_on_gui_input)

	# Instancia o Popup escondido (para não criar toda hora que clicar)
	_popup_instance = MOVE_POPUP_SCENE.instantiate()
	add_child(_popup_instance)
	_popup_instance.hide()

## Preenche o slot com os dados do Move
func setup(move: MoveData, pkmn: PokemonInstance, current_pp: int) -> void:
	if not move or not pkmn:
		return
		
	# Salva os dados para quando o usuário clicar
	_current_move = move
	_current_pkmn = pkmn
	_current_pp = current_pp
	
	# --- 1. Cálculos de Cor e PP ---
	var safe_pp = clampi(current_pp, 0, move.pp)
	var type_color: Color = TYPE_COLORS.get(move.type, Color.WHITE)
	var dark_type_color := type_color.darkened(0.4)
	var light_type_color := type_color.lightened(0.2)

	# --- 2. Fundo e Borda Colorida ---
	var style_main := StyleBoxFlat.new()
	style_main.bg_color = light_type_color
	style_main.border_color = dark_type_color
	style_main.set_border_width_all(2)
	style_main.set_corner_radius_all(4)
	add_theme_stylebox_override("panel", style_main)

	# --- 3. Textos ---
	move_name_label.text = move.name_en
	# Ajusta a cor da fonte para preto ou branco dependendo do fundo ser claro/escuro
	move_name_label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))

	pp_label.text = "PP %d/%d" % [safe_pp, move.pp]
	pp_label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	
	# --- 4. Imagem do Tipo ---
	_load_type_image(move.type)

## Carrega a imagem do tipo e define no TextureRect
func _load_type_image(type: Constants.PokemonType) -> void:
	var type_name: String = Constants.PokemonType.keys()[type].to_lower()
	
	if not _type_textures.has(type_name):
		var path := TYPE_ASSET_DIR + type_name + ".png"
		if ResourceLoader.exists(path):
			_type_textures[type_name] = load(path)
		else:
			push_warning("Imagem do tipo não encontrada: " + path)
			_type_textures[type_name] = null
	
	var tex = _type_textures[type_name]
	if tex:
		type_image.texture = tex
		type_image.show()
	else:
		type_image.hide()

## Detecta o clique com o botão esquerdo
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if _current_move and _current_pkmn:
			# Atualiza os dados do popup antes de abrir
			_popup_instance.setup(_current_move, _current_pkmn, _current_pp)
			# Emite o sinal caso a ficha do Pokémon queira saber do clique (opcional)
			move_clicked.emit(_current_move, _current_pkmn)
