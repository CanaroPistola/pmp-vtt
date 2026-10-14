extends Button

signal class_chosen(id: String, choices: Dictionary)

const CLASS_SELECTOR := preload("res://scenes/trainer_sheet/class_selector.tscn")

var selector: Window

func _ready() -> void:
	selector = CLASS_SELECTOR.instantiate()
	add_child(selector)
	selector.hide()
	selector.class_chosen.connect(class_chosen.emit)
	pressed.connect(selector.popup_centered)
