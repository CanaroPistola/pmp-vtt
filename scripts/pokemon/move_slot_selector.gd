class_name MoveSlotSelector
extends PanelContainer

signal pressed

@onready var btn: Button = $Button

var move_id: String = ""

func _ready() -> void:
	btn.pressed.connect(func(): pressed.emit())
	setup_empty()

func setup_empty() -> void:
	move_id = ""
	btn.text = "+ Vazio"
	btn.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	
	# Estilo neutro
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.15)
	style.border_color = Color(0.3, 0.3, 0.3)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	add_theme_stylebox_override("panel", style)

func setup_with_move(move: MoveData) -> void:
	move_id = move.id
	btn.text = move.name_en
	btn.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	
	# Estilo igual ao MoveSlot da ficha
	var type_color = MoveSlot.TYPE_COLORS.get(move.type, Color.WHITE)
	var dark_type_color = type_color.darkened(0.4)
	var light_type_color = type_color.lightened(0.2)
	
	var style = StyleBoxFlat.new()
	style.bg_color = light_type_color
	style.border_color = dark_type_color
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	add_theme_stylebox_override("panel", style)
