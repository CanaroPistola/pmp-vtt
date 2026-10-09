extends Button

signal image_selected(image: Image)

@export var file_dialog: FileDialog
@export var texture_rect: TextureRect

func _ready() -> void:
	pressed.connect(_on_import_button_pressed)
	if file_dialog:
		file_dialog.file_selected.connect(_on_file_selected)

func _on_import_button_pressed() -> void:
	if file_dialog:
		file_dialog.popup_centered_ratio(0.7)

func _on_file_selected(path: String) -> void:
	var image := Image.load_from_file(path)
	if image == null or image.is_empty():
		push_warning("Não foi possível abrir a imagem: %s" % path)
		return
	show_image(image)
	image_selected.emit(image)  # quem guarda a imagem é o TrainerData

## Mostra a imagem no TextureRect (também usada ao carregar uma ficha salva)
func show_image(image: Image) -> void:
	if image == null or texture_rect == null:
		return
	texture_rect.texture = ImageTexture.create_from_image(image)
