extends Window
## Popup reutilizável para exibir a descrição completa de uma habilidade.
## Use show_feature(title, text) para preencher e abrir.

@onready var title_label: Label = $Panel/Margin/VBox/TitleLabel
@onready var subtitle_label: Label = $Panel/Margin/VBox/SubtitleLabel
@onready var text_label: Label = $Panel/Margin/VBox/Scroll/TextLabel
@onready var close_button: Button = $Panel/Margin/VBox/CloseButton

func _ready() -> void:
	close_button.pressed.connect(hide)
	close_requested.connect(hide)

func show_feature(titulo: String, text: String, subtitle: String = "") -> void:
	title_label.text = titulo
	text_label.text = text
	subtitle_label.visible = not subtitle.is_empty()
	subtitle_label.text = subtitle
	popup_centered()
