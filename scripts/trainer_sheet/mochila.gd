extends Control
## Aba "Mochila".
## Sidebar com categorias + grid de itens + rodapé com detalhe do item selecionado.
## Tudo construído por código a partir de Items.DATA.

const ITEM_PICKER := preload("res://scenes/trainer_sheet/item_picker_popup.tscn")
const SIDEBAR_SCROLL_NAME := "SidebarScroll"

@onready var sidebar_vbox: VBoxContainer = $Root/Sidebar/SidebarVBox
@onready var top_bar: HBoxContainer = $Root/Content/TopBar/TopBarHBox
@onready var items_grid: GridContainer = $Root/Content/ItemsScroll/ItemsGrid
@onready var footer: PanelContainer = $Root/Content/Footer

var data: TrainerData
var _picker: Window

var _active_category: String = "todos"
var _selected_item_id: String = ""

# Botões de categoria (para destacar o ativo)
var _category_buttons: Array[Button] = []

func setup(trainer: TrainerData) -> void:
	data = trainer

	_picker = ITEM_PICKER.instantiate()
	add_child(_picker)
	_picker.hide()
	_picker.item_chosen.connect(_on_item_chosen)

	data.changed.connect(_refresh)
	_build_sidebar()
	_build_topbar()
	_build_footer()
	_refresh()

# ---------- Construção estática ----------

func _build_sidebar() -> void:
	for c in sidebar_vbox.get_children():
		c.queue_free()
	_category_buttons.clear()

	# Cabeçalho fixo (não rola com as categorias)
	var header := Label.new()
	header.text = "MOCHILA"
	header.add_theme_font_size_override("font_size", 20)
	sidebar_vbox.add_child(header)

	# ScrollContainer que vai segurar as categorias roláveis
	var scroll := ScrollContainer.new()
	scroll.name = SIDEBAR_SCROLL_NAME
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sidebar_vbox.add_child(scroll)

	# VBoxContainer interno que realmente lista as categorias
	var list := VBoxContainer.new()
	list.name = "CategoryList"
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)

	for cat in ItemData.CATEGORIES:
		var btn := Button.new()
		btn.text = cat["display_name"]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.toggle_mode = false
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_category_pressed.bind(cat["id"]))
		list.add_child(btn)
		_category_buttons.append(btn)

func _build_topbar() -> void:
	for c in top_bar.get_children():
		c.queue_free()

	var label := Label.new()
	label.text = "Pokédólares:"
	top_bar.add_child(label)

	var pd_edit := LineEdit.new()
	pd_edit.name = "PokedollarsEdit"
	pd_edit.text = str(data.pokedollars)
	pd_edit.alignment = HORIZONTAL_ALIGNMENT_RIGHT
	pd_edit.custom_minimum_size.x = 120
	pd_edit.text_changed.connect(_on_pokedollars_changed.bind(pd_edit))
	top_bar.add_child(pd_edit)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(spacer)

	var add_btn := Button.new()
	add_btn.text = "+ Adicionar item"
	add_btn.pressed.connect(_open_picker)
	top_bar.add_child(add_btn)

func _build_footer() -> void:
	_refresh_footer()

func _refresh_footer() -> void:
	for c in footer.get_children():
		c.queue_free()

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 8)
	footer.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	margin.add_child(hbox)

	if _selected_item_id.is_empty() or not ItemData.has_item(_selected_item_id):
		var empty := Label.new()
		empty.text = "Selecione um item para ver os detalhes."
		empty.modulate = Color(0.6, 0.6, 0.6)
		hbox.add_child(empty)
		return

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)

	var name_label := Label.new()
	name_label.text = ItemData.get_display_name(_selected_item_id)
	name_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(name_label)

	var desc_label := Label.new()
	desc_label.text = ItemData.get_description(_selected_item_id)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc_label)

	var use_btn := Button.new()
	use_btn.text = "USAR"
	use_btn.custom_minimum_size = Vector2(80, 0)
	use_btn.disabled = true  # vem na 3c
	use_btn.tooltip_text = "Uso automático ainda não implementado."
	hbox.add_child(use_btn)

	var remove_btn := Button.new()
	remove_btn.text = "Remover"
	remove_btn.pressed.connect(_on_remove_pressed)
	hbox.add_child(remove_btn)

# ---------- Refresh dinâmico ----------

func _refresh() -> void:
	_update_pokedollars_field()
	_update_category_highlight()
	_rebuild_items_grid()
	_refresh_footer()

func _update_pokedollars_field() -> void:
	var pd := top_bar.get_node_or_null("PokedollarsEdit")
	if pd is LineEdit and pd.text != str(data.pokedollars):
		pd.text = str(data.pokedollars)

func _update_category_highlight() -> void:
	for i in ItemData.CATEGORIES.size():
		var cat_id: String = ItemData.CATEGORIES[i]["id"]
		var btn := _category_buttons[i]
		btn.modulate = Color(1, 1, 1) if cat_id == _active_category else Color(0.7, 0.7, 0.7)

func _rebuild_items_grid() -> void:
	for c in items_grid.get_children():
		c.queue_free()

	var ids: Array = ItemData.get_ids_by_category(_active_category)

	# Sempre filtra só pelos que o jogador tem
	for id in ids:
		var qty := data.get_item_quantity(id)
		if qty <= 0:
			continue
		var slot := _make_item_slot(id, qty)
		items_grid.add_child(slot)

func _make_item_slot(id: String, qty: int) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(100, 110)
	btn.toggle_mode = false
	btn.pressed.connect(_on_item_pressed.bind(id))
	btn.tooltip_text = ItemData.get_description(id)

	# Texto do próprio Button — o Godot cuida do wrap e do alinhamento.
	btn.text = ItemData.get_display_name(id)
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	btn.add_theme_font_size_override("font_size", 11)

	# VBox só para o ícone (topo) e a quantidade (rodapé).
	# Ele NÃO captura o texto do Button, então não conflita.
	var overlay := VBoxContainer.new()
	overlay.name = "Overlay"
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_theme_constant_override("separation", 0)
	overlay.offset_top = 6
	overlay.offset_bottom = -6
	overlay.offset_left = 4
	overlay.offset_right = -4
	btn.add_child(overlay)

	# Ícone no topo
	var icon := ColorRect.new()
	icon.custom_minimum_size = Vector2(32, 32)
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon.color = Color(0.3, 0.3, 0.3)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(icon)

	# Espaçador que empurra o qty pro rodapé
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(spacer)

	# Quantidade no rodapé
	var qty_label := Label.new()
	qty_label.text = "x%d" % qty
	qty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	qty_label.add_theme_font_size_override("font_size", 11)
	qty_label.modulate = Color(0.8, 0.8, 0.8)
	qty_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(qty_label)

	return btn

# ---------- Handlers ----------

func _on_category_pressed(category_id: String) -> void:
	_active_category = category_id
	_refresh()

func _on_item_pressed(id: String) -> void:
	_selected_item_id = id
	_refresh_footer()

func _on_pokedollars_changed(new_text: String, _line_edit: LineEdit) -> void:
	if new_text.is_valid_int():
		data.set_pokedollars(new_text.to_int())

func _on_remove_pressed() -> void:
	if _selected_item_id.is_empty():
		return
	data.remove_item(_selected_item_id, 1)
	# Se a quantidade chegou a 0, limpa a seleção
	if not data.has_item(_selected_item_id):
		_selected_item_id = ""

func _open_picker() -> void:
	_picker.open()

func _on_item_chosen(id: String, qty: int) -> void:
	data.add_item(id, qty)
