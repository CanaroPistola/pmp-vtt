extends Window
## Popup de catálogo. Lista os itens agrupados por categoria.
## Clique em um item, define a quantidade, clica em Adicionar.

signal item_chosen(id: String, quantity: int)

@onready var list: VBoxContainer = $Panel/Margin/VBox/Scroll/List
@onready var qty_edit: LineEdit = $Panel/Margin/VBox/Footer/QtyEdit
@onready var cancel_button: Button = $Panel/Margin/VBox/Footer/CancelButton
@onready var add_button: Button = $Panel/Margin/VBox/Footer/AddButton

var _selected_id: String = ""

func _ready() -> void:
	close_requested.connect(hide)
	cancel_button.pressed.connect(hide)
	add_button.pressed.connect(_on_add_pressed)
	qty_edit.text_changed.connect(_on_qty_changed)

func open() -> void:
	_build_list()
	_selected_id = ""
	add_button.disabled = true
	qty_edit.text = "1"
	popup_centered()

func _build_list() -> void:
	for c in list.get_children():
		c.queue_free()

	for cat in ItemData.CATEGORIES:
		if cat["id"] == "todos":
			continue
		var ids := ItemData.get_ids_by_category(cat["id"])
		if ids.is_empty():
			continue

		var header := Label.new()
		header.text = cat["display_name"]
		header.add_theme_font_size_override("font_size", 16)
		list.add_child(header)

		for id in ids:
			var btn := Button.new()
			btn.text = "%s — ₽%d" % [ItemData.get_display_name(id), ItemData.get_price(id)]
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			btn.tooltip_text = ItemData.get_description(id)
			btn.pressed.connect(_on_item_pressed.bind(id))
			list.add_child(btn)

func _on_item_pressed(id: String) -> void:
	_selected_id = id
	add_button.disabled = false

func _on_qty_changed(text: String) -> void:
	var filtered := ""
	for c in text:
		if c.is_valid_int():
			filtered += c
	if filtered != text:
		qty_edit.text = filtered
		qty_edit.caret_column = filtered.length()

func _on_add_pressed() -> void:
	if _selected_id.is_empty():
		return
	var qty := qty_edit.text.to_int()
	if qty <= 0:
		qty = 1
	item_chosen.emit(_selected_id, qty)
	hide()
