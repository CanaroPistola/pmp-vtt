extends Button

@onready var Sheet = preload("res://scenes/TrainerSheet.tscn")
var sheet_instance

func _on_button_press() -> void:
	sheet_instance.show()
	
func _ready() -> void:
	sheet_instance = Sheet.instantiate()
	add_child(sheet_instance)
	sheet_instance.hide()
	
	self.pressed.connect(_on_button_press)
