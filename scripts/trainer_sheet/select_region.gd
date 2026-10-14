extends Button
## Botão "Região de Origem" do Trainer Card: abre o popup de seleção e repassa a escolha.
## Quem mostra o nome da região no botão é o trainer_card.gd (a partir do TrainerData).

## choices: {"attr_bonus": {atributo: valor}, "skills": [perícias]}
signal region_chosen(id: String, choices: Dictionary)

const REGION_SELECTOR := preload("res://scenes/trainer_sheet/region_selector.tscn")

var selector: Window

func _ready() -> void:
	selector = REGION_SELECTOR.instantiate()
	add_child(selector)
	selector.hide()
	selector.region_chosen.connect(region_chosen.emit)
	pressed.connect(selector.popup_centered)
