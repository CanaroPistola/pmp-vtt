extends Window
## Popup de uma especialização já escolhida, com opções de Trocar / Remover / Fechar.

signal change_requested(slot_index: int)
signal remove_requested(slot_index: int)

@onready var title_label: Label = $Panel/Margin/VBox/TitleLabel
@onready var text_label: Label = $Panel/Margin/VBox/Scroll/TextLabel
@onready var change_button: Button = $Panel/Margin/VBox/ButtonsRow/ChangeButton
@onready var remove_button: Button = $Panel/Margin/VBox/ButtonsRow/RemoveButton
@onready var close_button: Button = $Panel/Margin/VBox/ButtonsRow/CloseButton

var _slot_index: int = -1

func _ready() -> void:
	close_button.pressed.connect(hide)
	close_requested.connect(hide)
	change_button.pressed.connect(_on_change)
	remove_button.pressed.connect(_on_remove)

func show_for(slot_index: int, spec_id: String, feature: Dictionary) -> void:
	_slot_index = slot_index
	title_label.text = Specializations.get_display_name(spec_id)
	text_label.text = feature.get("text", "")
	popup_centered()

func _on_change() -> void:
	change_requested.emit(_slot_index)
	hide()

func _on_remove() -> void:
	remove_requested.emit(_slot_index)
	hide()
