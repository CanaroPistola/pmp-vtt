class_name CatalogWindow
extends Window
## Base dos popups de catálogo (itens, Pokémon): barra de busca, grade de slots
## clicáveis, destaque da seleção e filtro por nome.
##
## A subclasse implementa _build_list() (com _new_grid() / _new_slot() / _new_overlay())
## e _on_add_pressed(). Hooks opcionais: _on_open(), _on_slot_pressed(), _apply_filter(),
## _clear_selection() — estenda-os chamando super().
##
## Desempenho: o catálogo é construído UMA vez (na 1ª abertura) e reaproveitado nas
## seguintes; a janela abre na hora e os slots vão aparecendo em lotes por frame.
## Em _build_list(), chame `await _pace()` a cada slot criado. Se os dados do catálogo
## mudarem, chame invalidate() para forçar a reconstrução na próxima abertura.

const SLOT_MIN_SIZE := Vector2(100, 110)
const SELECTED_COLOR := Color(0.75, 0.9, 1.0)  # azul claro = selecionado
const BUILD_BATCH := 40  # slots criados por frame na 1ª abertura (ver _pace)

@onready var list: VBoxContainer = $Panel/Margin/VBox/Scroll/List
@onready var cancel_button: Button = $Panel/Margin/VBox/Footer/CancelButton
@onready var add_button: Button = $Panel/Margin/VBox/Footer/AddButton

var _search_edit: LineEdit
var _selected_id := ""
## Um por slot: {"id", "name", "slot"} + o que a subclasse acrescentar.
var _entries: Array = []
var _built := false     # catálogo já construído (reaproveitado entre aberturas)
var _building := false  # construção em andamento
var _paced := 0

func _search_placeholder() -> String:
	return ""

func _build_list() -> void:
	pass

func _on_add_pressed() -> void:
	pass

func _on_open() -> void:
	pass

## Número de colunas do grid principal. Subclasses podem sobrescrever.
func _grid_columns() -> int:
	return 5

func _ready() -> void:
	close_requested.connect(hide)
	cancel_button.pressed.connect(hide)
	add_button.pressed.connect(_on_add_pressed)
	_build_search_bar()

func open() -> void:
	list.show()
	_search_edit.text = ""
	_clear_selection()
	_on_open()
	popup_centered()
	if _building:
		return  # reaberta durante a construção inicial: ela continua sozinha
	if not _built:
		_building = true
		await _build_list()
		_building = false
		_built = true
	_apply_filter(_search_edit.text)

## Descarta o catálogo construído; a próxima abertura o reconstrói.
func invalidate() -> void:
	# remove da árvore IMEDIATAMENTE e depois libera; sem isso, queue_free()
	# deixa o nó na árvore até o fim do frame.
	for c in list.get_children():
		list.remove_child(c)
		c.queue_free()
	_entries.clear()
	_built = false

## Devolve o controle ao motor a cada BUILD_BATCH chamadas (use `await _pace()`),
## para a janela continuar responsiva enquanto os slots são criados.
func _pace() -> void:
	_paced += 1
	if _paced % BUILD_BATCH == 0:
		await get_tree().process_frame

# ---------- Construção ----------

## Insere a barra de busca no topo do VBox, logo após o título e antes do Scroll.
func _build_search_bar() -> void:
	var vbox: VBoxContainer = $Panel/Margin/VBox
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)

	var label := Label.new()
	label.text = "Buscar:"
	row.add_child(label)

	_search_edit = LineEdit.new()
	_search_edit.placeholder_text = _search_placeholder()
	_search_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_search_edit.text_changed.connect(_apply_filter)
	row.add_child(_search_edit)

	vbox.add_child(row)
	vbox.move_child(row, 1)

func _new_grid(grid_name: String) -> GridContainer:
	var grid := GridContainer.new()
	grid.name = grid_name
	grid.columns = _grid_columns()
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	list.add_child(grid)
	return grid

## Botão-slot já registrado em _entries. O conteúdo fica por conta de quem chama.
func _new_slot(id: String, display_name: String, extra: Dictionary = {}) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = SLOT_MIN_SIZE
	btn.pressed.connect(_on_slot_pressed.bind(id))
	var entry := {"id": id, "name": display_name, "slot": btn}
	entry.merge(extra)
	_entries.append(entry)
	return btn

## VBox por cima do botão, que ignora o mouse, para ícone e legendas.
func _new_overlay(btn: Button, margin_v: int, margin_h: int, separation: int) -> VBoxContainer:
	var overlay := VBoxContainer.new()
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.offset_top = margin_v
	overlay.offset_bottom = -margin_v
	overlay.offset_left = margin_h
	overlay.offset_right = -margin_h
	overlay.add_theme_constant_override("separation", separation)
	btn.add_child(overlay)
	return overlay

## Filhos do overlay não podem roubar o clique do botão.
func _ignore_mouse(c: Control) -> Control:
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c

# ---------- Seleção e busca ----------

func _on_slot_pressed(id: String) -> void:
	_selected_id = id
	add_button.disabled = false
	_highlight(id)

func _highlight(id: String) -> void:
	for e in _entries:
		e["slot"].modulate = SELECTED_COLOR if e["id"] == id else Color.WHITE

func _clear_selection() -> void:
	_selected_id = ""
	add_button.disabled = true
	_highlight("")

func _apply_filter(text: String) -> void:
	var q := text.strip_edges().to_lower()
	for e in _entries:
		e["slot"].visible = q.is_empty() or e["name"].to_lower().contains(q)
