extends Panel

const TEMP_MULTIPLIER := 5

@onready var hp_bar: ProgressBar = $HPLine
@onready var max_hp: LineEdit = $MaxHP
@onready var current_hp: LineEdit = $CurrentHP
@onready var temp_hp: ProgressBar = $TempHPLine

@onready var popup: Popup = $Popup
@onready var show_popup_button: Button = $ShowPopup
@onready var popup_button: Button = $Popup/PopupButton
@onready var pv_change: LineEdit = $Popup/PvChange

var data: TrainerData

func _ready() -> void:
	max_hp.editable = false  # calculado: 10 + CON, +2 + CON por nível

	current_hp.text_changed.connect(_on_line_edit_text_changed.bind(current_hp))
	current_hp.text_submitted.connect(_commit_current_hp)
	current_hp.focus_exited.connect(_on_current_hp_focus_exited)

	show_popup_button.pressed.connect(_show_popup)
	popup_button.pressed.connect(_on_apply_pressed)
	pv_change.text_submitted.connect(apply_hp_change)

func setup(trainer: TrainerData) -> void:
	data = trainer
	data.changed.connect(_refresh)
	_refresh()

func _refresh() -> void:
	max_hp.text = str(data.max_hp)
	current_hp.text = str(data.current_hp)

	hp_bar.max_value = maxi(data.max_hp, 1)
	hp_bar.value = mini(data.current_hp, data.max_hp)

	# PV acima do máximo é tratado como PV temporário
	temp_hp.max_value = maxi(data.max_hp * TEMP_MULTIPLIER, 1)
	temp_hp.value = maxi(data.current_hp - data.max_hp, 0)

func _on_current_hp_focus_exited() -> void:
	_commit_current_hp(current_hp.text)

func _commit_current_hp(text: String) -> void:
	if text.is_valid_int():
		data.set_current_hp(text.to_int())
	_refresh()

func _on_line_edit_text_changed(new_text: String, line_edit: LineEdit) -> void:
	var filtered := ""
	for c in new_text:
		if c.is_valid_int():
			filtered += c

	if filtered != new_text:
		var caret_pos := line_edit.caret_column
		line_edit.text = filtered
		line_edit.caret_column = caret_pos - (new_text.length() - filtered.length())

func _show_popup() -> void:
	popup.show()

## "12" substitui o PV, "+5" cura, "-5" dano
func apply_hp_change(text: String) -> void:
	text = text.strip_edges()
	if text.is_empty():
		return

	var new_value: int
	if text.begins_with("+") or text.begins_with("-"):
		var amount_str := text.substr(1)
		if not amount_str.is_valid_int():
			return
		var amount := amount_str.to_int()
		new_value = data.current_hp + (amount if text.begins_with("+") else -amount)
	else:
		if not text.is_valid_int():
			return
		new_value = text.to_int()

	data.set_current_hp(new_value)
	_refresh()
	popup.hide()
	pv_change.text = ""

func _on_apply_pressed() -> void:
	apply_hp_change(pv_change.text)
	pv_change.text = ""  # limpa o campo depois de aplicar
