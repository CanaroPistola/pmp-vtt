extends Button
## Botão "Origem de Jornada" do Trainer Card: abre a janela de seleção e repassa a escolha.
## Quem mostra o nome da origem no botão é o trainer_card.gd (a partir do TrainerData).

signal journey_chosen(id: String)

const JOURNEY_SELECTOR := preload("res://scenes/trainer_sheet/journey_selector.tscn")

var selector: Window

func _ready() -> void:
	selector = JOURNEY_SELECTOR.instantiate()
	add_child(selector)
	selector.hide()
	selector.journey_chosen.connect(journey_chosen.emit)
	pressed.connect(selector.popup_centered)
