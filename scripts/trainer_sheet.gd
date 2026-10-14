extends Window

const SAVE_PATH := "user://trainer.tres"

@export var trainer_data: TrainerData

@onready var card := $TabContainer/TrainerCard
@onready var attributes_tab := $TabContainer/AtributosPericias
@onready var talents_tab := $TabContainer/TalentosHabilidades

func _ready() -> void:
	close_requested.connect(_on_close_requested)
	trainer_data = _load_or_create()
	trainer_data.recalculate()
	trainer_data.changed.connect(save)
	card.setup(trainer_data)
	attributes_tab.setup(trainer_data)
	talents_tab.setup(trainer_data)

func _load_or_create() -> TrainerData:
	if ResourceLoader.exists(SAVE_PATH):
		var loaded := ResourceLoader.load(SAVE_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
		if loaded is TrainerData:
			return loaded
	return TrainerData.new()

func save() -> void:
	var err := ResourceSaver.save(trainer_data, SAVE_PATH)
	if err != OK:
		push_error("Falha ao salvar a ficha: %s" % error_string(err))

func _on_close_requested() -> void:
	save()
	hide()
