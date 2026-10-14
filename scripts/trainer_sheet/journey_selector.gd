extends Window
## Janela modal de seleção de Origem de Jornada.
## Uma etapa só: grade de origens, clique fecha e emite journey_chosen(id).
##
## Regiões sem dados em Journeys ficam desabilitadas.

signal journey_chosen(id: String)

@onready var grid: GridContainer = $Panel/Margin/VBox/GridContainer

func _ready() -> void:
	for cell in grid.get_children():
		var id := String(cell.name)
		var btn: TextureButton = cell.get_node("TextureButton")
		btn.disabled = not Journeys.has_data(id)
		btn.pressed.connect(_on_journey_pressed.bind(id))
	close_requested.connect(_on_close_requested)

func _on_close_requested() -> void:
	hide()

func _on_journey_pressed(id: String) -> void:
	journey_chosen.emit(id)
	hide()
