extends Control

const FEATURE_POPUP := preload("res://scenes/trainer_sheet/feature_popup.tscn")
const REGION_SELECTOR := preload("res://scenes/trainer_sheet/region_selector.tscn")
const JOURNEY_SELECTOR := preload("res://scenes/trainer_sheet/journey_selector.tscn")
const CLASS_SELECTOR := preload("res://scenes/trainer_sheet/class_selector.tscn")
const TALENT_SELECTOR := preload("res://scenes/trainer_sheet/talent_selector.tscn")

const TALENT_SLOTS := 5


var _talent_selector: Window

@onready var region_slot: PanelContainer = $Root/LeftColumn/TopRow/RegionSlot
@onready var journey_slot: PanelContainer = $Root/LeftColumn/TopRow/JourneySlot
@onready var talents_slot: PanelContainer = $Root/LeftColumn/TalentsSlot
@onready var class_slot: PanelContainer = $Root/RightColumn

var data: TrainerData
var _popup: Window
var _region_selector: Window
var _journey_selector: Window
var _class_selector: Window

func setup(trainer: TrainerData) -> void:
	data = trainer

	_popup = FEATURE_POPUP.instantiate()
	add_child(_popup)
	_popup.hide()

	_region_selector = REGION_SELECTOR.instantiate()
	add_child(_region_selector)
	_region_selector.hide()
	_region_selector.region_chosen.connect(_on_region_chosen)

	_journey_selector = JOURNEY_SELECTOR.instantiate()
	add_child(_journey_selector)
	_journey_selector.hide()
	_journey_selector.journey_chosen.connect(_on_journey_chosen)

	_class_selector = CLASS_SELECTOR.instantiate()
	add_child(_class_selector)
	_class_selector.hide()
	_class_selector.class_chosen.connect(_on_class_chosen)

	data.changed.connect(_refresh)
	_talent_selector = TALENT_SELECTOR.instantiate()
	add_child(_talent_selector)
	_talent_selector.hide()
	_talent_selector.talent_chosen.connect(_on_talent_chosen)
	
	#data.changed.connect(_refresh)
	_refresh()

func _refresh() -> void:
	_build_region_slot()
	_build_journey_slot()
	_build_talents_slot()
	_build_class_slot()

# ---------- Região ----------

func _build_region_slot() -> void:
	for c in region_slot.get_children():
		c.queue_free()
	var vbox := _make_slot_vbox(region_slot, "Região de Origem")

	if data.region.is_empty():
		vbox.add_child(_make_empty_slot_button("+ Escolher região", _open_region_selector))
		return

	var features := Regions.get_features(data.region)
	if features.is_empty():
		vbox.add_child(_make_empty_slot_button(data.region, func() -> void:
			popup_feature(data.region, "Região de Origem", "", "Nenhuma habilidade registrada.")))
		return

	for f in features:
		var title: String = f.get("title", "?")
		var text: String = f.get("text", "")
		var subtitle := "Região de Origem — %s" % data.region
		vbox.add_child(_make_feature_button(title, func() -> void:
			popup_feature(title, subtitle, "", text)))

# ---------- Jornada ----------

func _build_journey_slot() -> void:
	for c in journey_slot.get_children():
		c.queue_free()
	var vbox := _make_slot_vbox(journey_slot, "Origem de Jornada")

	if data.journey.is_empty():
		vbox.add_child(_make_empty_slot_button("+ Escolher jornada", _open_journey_selector))
		return

	var f := Journeys.get_feature(data.journey)
	if f.is_empty():
		vbox.add_child(_make_empty_slot_button(data.journey, func() -> void:
			popup_feature(data.journey, "Origem de Jornada", "", "Nenhuma habilidade registrada.")))
		return

	var title: String = f.get("title", "?")
	var text: String = f.get("text", "")
	var subtitle := "Origem de Jornada — %s" % data.journey
	vbox.add_child(_make_feature_button(title, func() -> void:
		popup_feature(title, subtitle, "", text)))

# ---------- Talentos ----------

func _build_talents_slot() -> void:
	for c in talents_slot.get_children():
		c.queue_free()
	var vbox := _make_slot_vbox(talents_slot, "Talentos")

	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	vbox.add_child(grid)

	for i in TALENT_SLOTS:
		var t_data := {}
		if i < data.talents.size():
			t_data = data.talents[i]
			
		var btn := Button.new()
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(0, 60)
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.clip_text = true
		btn.add_theme_font_size_override("font_size", 11)
		
		if t_data.is_empty():
			btn.text = "+"
			btn.pressed.connect(_open_talent_selector.bind(i))
		else:
			var t_id: String = t_data.get("id", "")
			var display_name: String = TrainersTalents.get_display_name(t_id)
			
			# Adiciona o tipo entre parênteses se for o Mestre do Tipo
			if t_id == "mestre_do_tipo":
				var choices: Dictionary = t_data.get("choices", {})
				var type_id = choices.get("pokemon_type", -1)
				if type_id != -1:
					var type_name = Constants.PokemonType.keys()[type_id].capitalize()
					display_name += " (%s)" % type_name
					
			btn.text = display_name
			btn.pressed.connect(_open_talent_popup.bind(t_id, i))
			
		grid.add_child(btn)

var _active_talent_slot := -1

func _open_talent_selector(slot_index: int) -> void:
	_active_talent_slot = slot_index
	
	# Coleta os tipos permitidos baseado nas especializações atuais
	var allowed_types: Array[int] = []
	for spec in data.specializations:
		var spec_id = spec.get("id", "")
		if not spec_id.is_empty() and Specializations.TYPE_MAP.has(spec_id):
			var type_id = Specializations.TYPE_MAP[spec_id]
			if type_id not in allowed_types:
				allowed_types.append(type_id)
				
	_talent_selector.set_allowed_types(allowed_types)
	_talent_selector.popup_centered()

func _on_talent_chosen(id: String, choices: Dictionary) -> void:
	if _active_talent_slot < 0: return
	data.set_talent(_active_talent_slot, id, choices)
	_active_talent_slot = -1

func _open_talent_popup(id: String, slot_index: int) -> void:
	var popup := Window.new()
	popup.title = TrainersTalents.get_display_name(id)
	popup.size = Vector2i(450, 300)
	popup.max_size = Vector2i(450, 300)
	popup.unresizable = true
	popup.exclusive = true
	popup.always_on_top = true
	
	# Faz o botão X da janela fechar o popup
	popup.close_requested.connect(popup.queue_free)
	
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	popup.add_child(margin)
	
	var vbox := VBoxContainer.new()
	margin.add_child(vbox)
	
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(scroll)
	
	var label := Label.new()
	label.text = TrainersTalents.get_description(id)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(label)
	
	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_END
	vbox.add_child(hbox)
	
	var remove_btn := Button.new()
	remove_btn.text = "Remover"
	remove_btn.pressed.connect(func():
		data.remove_talent(slot_index)
		popup.queue_free()
	)
	hbox.add_child(remove_btn)
	
	add_child(popup)
	popup.popup_centered()

# ---------- Classe ----------

func _build_class_slot() -> void:
	for c in class_slot.get_children():
		c.queue_free()

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	class_slot.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)

	var header := Label.new()
	header.text = "Classe de Treinador"
	header.add_theme_font_size_override("font_size", 18)
	vbox.add_child(header)

	if data.trainer_class.is_empty():
		vbox.add_child(_make_empty_slot_button("+ Escolher classe", _open_class_selector))
		return

	var class_name_label := Label.new()
	class_name_label.text = TrainersClasses.get_display_name(data.trainer_class)
	class_name_label.add_theme_font_size_override("font_size", 14)
	class_name_label.modulate = Color(0.85, 0.85, 0.85)
	vbox.add_child(class_name_label)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	vbox.add_child(grid)

	var features := TrainersClasses.get_features(data.trainer_class)
	for f in features:
		var level: int = f.get("level", 0)
		var unlocked := level <= data.level
		var title: String = f.get("title", "?")
		var text: String = f.get("text", "")
		var prefix := "Nv %d" % level
		if not unlocked:
			prefix += " (bloq.)"

		var btn := Button.new()
		btn.text = "%s\n%s" % [prefix, title]
		btn.flat = false
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(0, 80)
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if not unlocked:
			btn.modulate = Color(0.55, 0.55, 0.55)
		var subtitle := "Classe de Treinador — %s" % TrainersClasses.get_display_name(data.trainer_class)
		btn.pressed.connect(func() -> void:
			popup_feature(title, subtitle, "Nível %d%s" % [level, "" if unlocked else " — bloqueada"], text))
		grid.add_child(btn)

# ---------- helpers ----------

func _make_slot_vbox(parent: PanelContainer, title: String) -> VBoxContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)

	var header := Label.new()
	header.text = title
	header.add_theme_font_size_override("font_size", 18)
	vbox.add_child(header)

	return vbox

func _make_empty_slot_button(label: String, callback: Callable) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.flat = false
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
	btn.custom_minimum_size = Vector2(0, 48)
	btn.modulate = Color(0.85, 0.85, 0.85)
	btn.pressed.connect(callback)
	return btn

func _make_feature_button(label: String, callback: Callable) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.flat = false
	btn.alignment = HORIZONTAL_ALIGNMENT_CENTER     # centro (padrão)
	btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
	btn.custom_minimum_size = Vector2(0, 48)
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	btn.pressed.connect(callback)
	return btn

func popup_feature(title: String, subtitle: String, _unused: String, text: String) -> void:
	_popup.show_feature(title, text, subtitle)

func _open_region_selector() -> void:
	_region_selector.popup_centered()

func _open_journey_selector() -> void:
	_journey_selector.popup_centered()

func _open_class_selector() -> void:
	if data.level < 2:
		popup_feature("Classe de Treinador", "Classe de Treinador",
			"", "Classe só pode ser escolhida a partir do nível 2.")
		return
	_class_selector.popup_centered()

func _on_region_chosen(id: String, choices: Dictionary) -> void:
	data.set_region(id, choices)

func _on_journey_chosen(id: String) -> void:
	data.set_journey(id)

func _on_class_chosen(id: String, choices: Dictionary) -> void:
	data.set_class(id, choices)
