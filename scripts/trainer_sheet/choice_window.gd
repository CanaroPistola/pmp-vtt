class_name ChoiceWindow
extends Window
## Base dos seletores modais em duas etapas (Região, Classe, Especialização, Talento).
## Etapa 1: grade de células (o nome do nó é o id nos dados).
## Etapa 2 (opcional): opções montadas por código dentro da ChoiceContainer.
##
## A subclasse implementa _has_data() e _on_cell_pressed(), monta a etapa 2 com
## _begin_choice() + _add_option() + _add_confirm() e, ao terminar, emite o seu
## sinal e chama _close(). Quem guarda estado extra estende _reset() com super().

@onready var grid: GridContainer = $Panel/Margin/VBox/GridContainer
@onready var choice_scroll: ScrollContainer = $Panel/Margin/VBox/ChoiceScroll
@onready var choice_container: VBoxContainer = $Panel/Margin/VBox/ChoiceScroll/ChoiceContainer

var _choice_box: VBoxContainer
var _confirm: Button
var _pickers: Array[CheckBox] = []
var _needed := 0       # quantas opções precisam estar marcadas para confirmar
var _current_id := ""

## O id existe nos dados? Se não, a célula fica desabilitada.
func _has_data(_id: String) -> bool:
	return false

func _on_cell_pressed(_id: String) -> void:
	pass

func _ready() -> void:
	for cell in grid.get_children():
		var id := String(cell.name)
		var btn: TextureButton = cell.get_node("TextureButton")
		btn.disabled = not _has_data(id)
		btn.pressed.connect(_on_cell_pressed.bind(id))
	close_requested.connect(_close)

func _close() -> void:
	_reset()
	hide()

# ---------- etapa 2: construção ----------

func _begin_choice(titulo: String) -> VBoxContainer:
	grid.hide()
	choice_scroll.show()
	_pickers.clear()
	_choice_box = VBoxContainer.new()
	choice_container.add_child(_choice_box)

	var label := Label.new()
	label.text = titulo
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_choice_box.add_child(label)
	return _choice_box

## Adiciona uma opção (radio se houver `group`, senão checkbox). `value` fica
## guardado para _picked_values(). Sem `handler`, usa _on_picker_toggled.
func _add_option(parent: Control, text: String, value, group: ButtonGroup = null,
		handler: Callable = Callable()) -> CheckBox:
	var cb := CheckBox.new()
	cb.text = text
	cb.set_meta("value", value)
	cb.button_group = group
	cb.toggled.connect(handler if handler.is_valid() else _on_picker_toggled)
	parent.add_child(cb)
	_pickers.append(cb)
	return cb

func _add_confirm(parent: Control, on_pressed: Callable) -> void:
	_confirm = Button.new()
	_confirm.text = "Confirmar (0/%d)" % _needed if _needed > 1 else "Confirmar"
	_confirm.disabled = true
	_confirm.pressed.connect(on_pressed)
	parent.add_child(_confirm)

## Valores (meta "value") das opções marcadas.
func _picked_values() -> Array:
	return _pickers.filter(func(c: CheckBox) -> bool: return c.button_pressed) \
			.map(func(c: CheckBox): return c.get_meta("value"))

## Habilita Confirmar quando há exatamente `_needed` marcadas; com mais de uma
## necessária, mostra o contador e trava as não marcadas ao atingir o limite.
func _on_picker_toggled(_pressed: bool) -> void:
	var n := _picked_values().size()
	_confirm.disabled = n != _needed
	if _needed <= 1:
		return
	_confirm.text = "Confirmar (%d/%d)" % [n, _needed]
	for cb in _pickers:
		cb.disabled = n >= _needed and not cb.button_pressed

func _reset() -> void:
	if _choice_box:
		_choice_box.queue_free()
		_choice_box = null
	_pickers.clear()
	_confirm = null
	_current_id = ""
	_needed = 0
	grid.show()
	choice_scroll.hide()
