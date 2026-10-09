extends Control
## Aba "Trainer Card": nome, nível, controle de S/R, CA, proficiência e PV.
## Anexe este script ao node TabContainer/TrainerCard.

@onready var name_edit: LineEdit = $NomeContainer/NomeEdit
@onready var level_edit: LineEdit = $NivelExpContainer/NivelContainer/NivelEdit
@onready var sr_edit: LineEdit = $NivelExpContainer/MaxSRContainer/SREdit
@onready var ac_edit: LineEdit = $ACPanel/LineEdit
@onready var prof_edit: LineEdit = $ProfficiencyPanel/LineEdit
@onready var hp_panel: Panel = $HPPanel
@onready var portrait_button: Button = $TrainerImage/ImageChange

var data: TrainerData

func _ready() -> void:
	# Campos calculados: só exibição
	for le in [sr_edit, ac_edit, prof_edit]:
		le.editable = false

	name_edit.text_submitted.connect(_on_name_submitted)
	name_edit.focus_exited.connect(_on_name_focus_exited)

	level_edit.text_changed.connect(_on_digits_only.bind(level_edit))
	level_edit.text_submitted.connect(_apply_level)
	level_edit.focus_exited.connect(_on_level_focus_exited)

func setup(trainer: TrainerData) -> void:
	data = trainer
	data.changed.connect(_refresh)
	hp_panel.setup(data)

	portrait_button.image_selected.connect(data.set_portrait)  # UI -> dados
	portrait_button.show_image(data.get_portrait())            # dados -> UI (ao abrir)
	_refresh()

# ---------- UI -> dados ----------

func _on_name_submitted(text: String) -> void:
	data.set_aname(text.strip_edges())

func _on_name_focus_exited() -> void:
	data.set_aname(name_edit.text.strip_edges())

func _on_level_focus_exited() -> void:
	_apply_level(level_edit.text)

func _apply_level(text: String) -> void:
	if text.is_valid_int():
		data.set_level(int(text))  # recalcula SR, proficiência, PV, CA, perícias
	_refresh()  # campo vazio/inválido volta ao valor salvo

func _on_digits_only(new_text: String, line_edit: LineEdit) -> void:
	var filtered := ""
	for c in new_text:
		if c.is_valid_int():
			filtered += c
	if filtered != new_text:
		var caret_pos := line_edit.caret_column
		line_edit.text = filtered
		line_edit.caret_column = caret_pos - (new_text.length() - filtered.length())

# ---------- dados -> UI ----------

func _refresh() -> void:
	if name_edit.text != data.aname:
		name_edit.text = data.aname
	level_edit.text = str(data.level)
	sr_edit.text = data.max_sr
	ac_edit.text = str(data.armor_class)
	prof_edit.text = "%+d" % data.profficiency_bonus
