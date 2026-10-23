class_name ItemSlot
extends RefCounted
## Visual padrão de um slot de item (usado pela Mochila e pelo popup de catálogo):
## nome no próprio botão, ícone no topo e uma legenda (preço ou quantidade) no rodapé.

const SIZE := Vector2(100, 110)
const ICON_SIZE := Vector2(32, 32)

## Cria o botão-slot e conecta `on_pressed` (que recebe nada; use .bind() no id).
static func make(id: String, footer_text: String, footer_color: Color, on_pressed: Callable) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = SIZE
	btn.pressed.connect(on_pressed)
	fill(btn, id, footer_text, footer_color)
	return btn

## Decora um botão existente (o popup cria o botão via CatalogWindow._new_slot).
static func fill(btn: Button, id: String, footer_text: String, footer_color: Color) -> void:
	btn.tooltip_text = ItemData.get_description(id)
	btn.text = ItemData.get_display_name(id)
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	btn.add_theme_font_size_override("font_size", 11)

	# VBox só para ícone (topo) e legenda (rodapé); não captura o texto do Button.
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
	var spacer := Control.new()  # empurra a legenda para o rodapé
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var footer := Label.new()
	footer.text = footer_text
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 11)
	footer.modulate = footer_color

	for c: Control in [icon, spacer, footer]:
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		overlay.add_child(c)
