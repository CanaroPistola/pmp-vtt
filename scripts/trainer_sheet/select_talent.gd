extends Button
## Botão para abrir o seletor de talentos.

signal talent_chosen(id: String, choices: Dictionary)

const TALENT_SELECTOR := preload("res://scenes/trainer_sheet/talent_selector.tscn")

var selector: Window

func _ready() -> void:
	selector = TALENT_SELECTOR.instantiate()
	add_child(selector)
	selector.hide()
	selector.talent_chosen.connect(talent_chosen.emit)
	pressed.connect(selector.popup_centered)
