extends CatalogWindow
## Popup de catálogo. Grid de itens agrupados por categoria.
## Clicar num item seleciona; ajusta a quantidade; clica em Adicionar.
## A barra de busca filtra por nome em tempo real.

signal item_chosen(id: String, quantity: int)

@onready var qty_edit: LineEdit = $Panel/Margin/VBox/Footer/QtyEdit

# { "category": String, "node": Control }
var _headers: Array = []
var _grids: Array = []

func _ready() -> void:
	super()
	qty_edit.text_changed.connect(_on_qty_changed)

func _search_placeholder() -> String:
	return "Nome do item..."

func _on_open() -> void:
	qty_edit.text = "1"

# ---------- Construção ----------

func _build_list() -> void:
	_headers.clear()
	_grids.clear()
	for cat in ItemData.CATEGORIES:
		var ids: Array = [] if cat["id"] == "todos" else ItemData.get_ids_by_category(cat["id"])
		if ids.is_empty():
			continue

		var header := Label.new()
		header.text = cat["display_name"]
		header.add_theme_font_size_override("font_size", 16)
		list.add_child(header)
		_headers.append({"category": cat["id"], "node": header})

		var grid := _new_grid("Grid_" + cat["id"])
		_grids.append({"category": cat["id"], "node": grid})
		for id in ids:
			grid.add_child(_make_item_slot(id, cat["id"]))
			await _pace()

func _make_item_slot(id: String, category: String) -> Button:
	var btn := _new_slot(id, ItemData.get_display_name(id), {"category": category})
	var price: int = ItemData.get_price(id)
	ItemSlot.fill(btn, id, "₽%d" % price if price >= 0 else "—", Color(0.85, 0.85, 0.85))
	return btn

# ---------- Busca ----------

## Além de filtrar os slots: durante a busca esconde os títulos, esconde as grades
## sem slot visível e limpa a seleção se o item selecionado sumiu.
func _apply_filter(text: String) -> void:
	super(text)
	var searching := not text.strip_edges().is_empty()
	for h in _headers:
		h["node"].visible = not searching
	var shown: Array = _entries.filter(func(e: Dictionary) -> bool: return e["slot"].visible)
	for g in _grids:
		g["node"].visible = shown.any(func(e: Dictionary) -> bool: return e["category"] == g["category"])
	if searching and shown.all(func(e: Dictionary) -> bool: return e["id"] != _selected_id):
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
	item_chosen.emit(_selected_id, maxi(qty_edit.text.to_int(), 1))
	hide()
