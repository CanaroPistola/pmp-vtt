extends Window
## Popup de catálogo. Grid de itens agrupados por categoria.
## Clicar num item seleciona; ajusta a quantidade; clica em Adicionar.
## Tem barra de busca que filtra por nome em tempo real.

signal item_chosen(id: String, quantity: int)

const SLOT_MIN_SIZE := Vector2(100, 110)
const ICON_SIZE := Vector2(32, 32)
const GRID_COLUMNS := 5

@onready var list: VBoxContainer = $Panel/Margin/VBox/Scroll/List
@onready var qty_edit: LineEdit = $Panel/Margin/VBox/Footer/QtyEdit
@onready var cancel_button: Button = $Panel/Margin/VBox/Footer/CancelButton
@onready var add_button: Button = $Panel/Margin/VBox/Footer/AddButton

var _selected_id: String = ""
var _search_edit: LineEdit

# Guarda cada slot criado para poder filtrar sem reconstruir tudo
# { "id": String, "category": String, "slot": Button, "header": Label }
var _entries: Array = []
var _headers: Array = []
var _grids: Array = []

func _ready() -> void:
	close_requested.connect(hide)
	cancel_button.pressed.connect(hide)
	add_button.pressed.connect(_on_add_pressed)
	qty_edit.text_changed.connect(_on_qty_changed)
	_build_search_bar()

func open() -> void:
	_build_list()
	_clear_selection()
	if _search_edit:
		_search_edit.text = ""
	_apply_filter("")
	qty_edit.text = "1"
	popup_centered()

# ---------- Construção ----------

func _build_search_bar() -> void:
	# Insere uma barra de busca no topo do VBox, antes do Scroll
	var vbox: VBoxContainer = $Panel/Margin/VBox
	var search_row := HBoxContainer.new()
	search_row.name = "SearchRow"
	search_row.add_theme_constant_override("separation", 6)

	var search_label := Label.new()
	search_label.text = "Buscar:"
	search_row.add_child(search_label)

	_search_edit = LineEdit.new()
	_search_edit.name = "SearchEdit"
	_search_edit.placeholder_text = "Nome do item..."
	_search_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_search_edit.text_changed.connect(_apply_filter)
	search_row.add_child(_search_edit)

	vbox.add_child(search_row)
	vbox.move_child(search_row, 1)  # logo após o título, antes do Scroll

func _build_list() -> void:
	# remove da árvore IMEDIATAMENTE e depois libera; sem isso, queue_free()
	# deixa o nó na árvore até o fim do frame e polui a próxima abertura.
	for c in list.get_children():
		list.remove_child(c)
		c.queue_free()
	_entries.clear()
	_headers.clear()
	_grids.clear()

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
		_headers.append({"category": cat["id"], "node": header})

		var grid := GridContainer.new()
		grid.name = "Grid_" + cat["id"]
		grid.columns = GRID_COLUMNS
		grid.add_theme_constant_override("h_separation", 8)
		grid.add_theme_constant_override("v_separation", 8)
		list.add_child(grid)
		_grids.append({"category": cat["id"], "node": grid})

		for id in ids:
			var slot := _make_item_slot(id, cat["id"])
			grid.add_child(slot)
			_entries.append({"id": id, "category": cat["id"], "slot": slot})

# ---------- Slot visual (mesmo padrão do mochila.gd) ----------

func _make_item_slot(id: String, _category: String) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = SLOT_MIN_SIZE
	btn.toggle_mode = false
	btn.pressed.connect(_on_item_pressed.bind(id))
	btn.tooltip_text = ItemData.get_description(id)

	# Texto do próprio Button: nome do item
	btn.text = ItemData.get_display_name(id)
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	btn.add_theme_font_size_override("font_size", 11)

	# Overlay para o ícone (topo) e o preço (rodapé)
	var overlay := VBoxContainer.new()
	overlay.name = "Overlay"
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.offset_top = 6
	overlay.offset_bottom = -6
	overlay.offset_left = 4
	overlay.offset_right = -4
	overlay.add_theme_constant_override("separation", 0)
	btn.add_child(overlay)

	var icon := ColorRect.new()
	icon.custom_minimum_size = ICON_SIZE
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon.color = Color(0.3, 0.3, 0.3)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(icon)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(spacer)

	var price_label := Label.new()
	var price: int = ItemData.get_price(id)
	price_label.text = "₽%d" % price if price >= 0 else "—"
	price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	price_label.add_theme_font_size_override("font_size", 11)
	price_label.modulate = Color(0.85, 0.85, 0.85)
	price_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(price_label)

	return btn

# ---------- Seleção ----------

func _clear_selection() -> void:
	_selected_id = ""
	add_button.disabled = true
	for entry in _entries:
		entry["slot"].modulate = Color(1, 1, 1)

func _on_item_pressed(id: String) -> void:
	_selected_id = id
	add_button.disabled = false
	for entry in _entries:
		if entry["id"] == id:
			entry["slot"].modulate = Color(0.75, 0.9, 1.0)  # azul claro = selecionado
		else:
			entry["slot"].modulate = Color(1, 1, 1)

# ---------- Busca ----------

func _apply_filter(text: String) -> void:
	var q := text.strip_edges().to_lower()
	var searching := not q.is_empty()

	# Headers: escondem durante a busca
	for h in _headers:
		h["node"].visible = not searching

	# Slots: cada um decide se aparece
	for entry in _entries:
		var slot: Button = entry["slot"]
		if not searching:
			slot.visible = true
			continue
		var display: String = ItemData.get_display_name(entry["id"]).to_lower()
		slot.visible = display.contains(q)

	# Grids: esconde só os que não têm nenhum slot visível.
	# Usa _grids (não list.get_children()) — sobrevive a queue_free tardio.
	for g in _grids:
		var cat_id: String = g["category"]
		var any_visible := false
		for entry in _entries:
			if entry["category"] == cat_id and entry["slot"].visible:
				any_visible = true
				break
		g["node"].visible = any_visible

	# Seleção some se o item selecionado não estiver mais visível
	if searching and not _selected_id.is_empty():
		var still_visible := false
		for entry in _entries:
			if entry["id"] == _selected_id and entry["slot"].visible:
				still_visible = true
				break
		if not still_visible:
			_clear_selection()

# ---------- Quantidade ----------

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
