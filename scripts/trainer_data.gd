class_name TrainerData
extends Resource
## Classe base do treinador pokemon
## Todo treinador possui:
## Nome, nivel, exp, pokeslots, max de SR, região de origem, origem de jornada,
## classe, especializações, atributos, pericias treinadas, pericias especialista,
## salvaguardas, CA, iniciativa, deslocamento (caminhada, nado e escalada),
## bônus de proficiência, pokedolares, inventário, talentos, habilidades e
## carrega consigo até 6 pokemons

signal attribute_changed(attr: Constants.Attribute, value: int)
signal skill_changed(skill: Constants.Skill)
signal portrait_changed

const PORTRAIT_MAX_SIZE := 512

const POKESLOTS := {
	1: 3, 2: 3, 3: 3, 4: 3,
	5: 4, 6: 4, 7: 4, 8: 4,
	9: 4, 10: 5, 11: 5, 12: 5,
	13: 5, 14: 5, 15: 6, 16: 6,
	17: 6, 18: 6, 19: 6, 20: 6
}

const MAX_SR := {
	1: "2", 2: "2", 3: "5", 4: "5", 5: "5",
	6: "8", 7: "8", 8: "10", 9: "10", 10: "10",
	11: "12", 12: "12", 13: "12", 14: "14", 15: "14",
	16: "14", 17: "15", 18: "15", 19: "15", 20: "15"
}

@export var aname: String

@export var level: int = 1  # era 0: POKESLOTS[0] e PROFFICIENCY_BONUS[0] não existem
@export var xp: int

@export var max_hp: int
@export var current_hp: int
@export var temp_hp: int

@export var pokeslots: int
@export var max_sr: String

@export var attributes := {
	Constants.Attribute.STR: 8,
	Constants.Attribute.DEX: 8,
	Constants.Attribute.CON: 8,
	Constants.Attribute.INT: 8,
	Constants.Attribute.WIS: 8,
	Constants.Attribute.CHA: 8
}

@export var trained_skills: Array[Constants.Skill]
@export var expert_skills: Array[Constants.Skill]
@export var saving_throws: Array[Constants.Attribute]

@export var movement := {
	Constants.Movement.WALKING: 9,
}

@export var armor_class: int
@export var initiative: int

@export var profficiency_bonus: int

@export var pokedollars: int

## Retrato do treinador: WebP codificado em base64, guardado dentro da própria ficha
@export var portrait_data: String


func set_attribute(attr: Constants.Attribute, value: int) -> void:
	attributes[attr] = clampi(value, 0, 30)
	recalculate()
	attribute_changed.emit(attr, attributes[attr])
	emit_changed()

func set_aname(value: String) -> void:
	if value == aname:
		return
	aname = value
	emit_changed()

func set_current_hp(value: int) -> void:
	value = maxi(value, 0)
	if value == current_hp:
		return
	current_hp = value  # pode passar do máximo: o excesso é o PV temporário
	emit_changed()

func set_portrait(image: Image) -> void:
	if image == null or image.is_empty():
		return
	image = image.duplicate()  # não altera a imagem de quem chamou
	var longest := maxi(image.get_width(), image.get_height())
	if longest > PORTRAIT_MAX_SIZE:
		var factor := float(PORTRAIT_MAX_SIZE) / longest
		image.resize(int(image.get_width() * factor), int(image.get_height() * factor),
				Image.INTERPOLATE_LANCZOS)
	portrait_data = Marshalls.raw_to_base64(image.save_webp_to_buffer(true, 0.9))
	portrait_changed.emit()
	emit_changed()

func get_portrait() -> Image:
	if portrait_data.is_empty():
		return null
	var image := Image.new()
	if image.load_webp_from_buffer(Marshalls.base64_to_raw(portrait_data)) != OK:
		return null
	return image

func set_saving_throw_trained(attr: Constants.Attribute, value: bool) -> void:
	if value and attr not in saving_throws:
		saving_throws.append(attr)
	elif not value:
		saving_throws.erase(attr)
	emit_changed()

func set_level(value: int) -> void:
	level = clampi(value, 1, 20)
	recalculate()
	emit_changed()

func set_skill_trained(skill: Constants.Skill, value: bool) -> void:
	if value and skill not in trained_skills:
		trained_skills.append(skill)
	elif not value:
		trained_skills.erase(skill)
	skill_changed.emit(skill)
	emit_changed()

func set_skill_expert(skill: Constants.Skill, value: bool) -> void:
	if value and skill not in expert_skills:
		expert_skills.append(skill)
	elif not value:
		expert_skills.erase(skill)
	skill_changed.emit(skill)
	emit_changed()

## Recalcula tudo que deriva de nível e atributos
func recalculate() -> void:
	level = clampi(level, 1, 20)
	var old_max_hp := max_hp
	var dex_mod := Constants.get_attribute_modifier(attributes[Constants.Attribute.DEX])
	var con_mod := Constants.get_attribute_modifier(attributes[Constants.Attribute.CON])
	armor_class = 10 + dex_mod
	initiative = dex_mod
	profficiency_bonus = get_profficiency_bonus(level)
	# Treinador começa com 10 + CON de HP.
	# A cada level (acima do 1) recebe 2 + CON de HP (CON retroativa).
	max_hp = 10 + (level * con_mod) + (level * 2 - 2)
	if old_max_hp == 0:
		current_hp = max_hp  # ficha nova começa com PV cheio
	else:
		current_hp = maxi(current_hp + (max_hp - old_max_hp), 0)  # PV máx mudou: PV atual acompanha
	pokeslots = POKESLOTS[level]
	max_sr = MAX_SR[level]

func get_profficiency_bonus(lvl: int) -> int:
	return Constants.PROFFICIENCY_BONUS[lvl]

func get_skill_bonus(skill: Constants.Skill) -> int:
	var attr: Constants.Attribute = Constants.SKILL_DETAILS[skill]["attribute"]
	var mod := Constants.get_attribute_modifier(attributes[attr])
	var prof := get_profficiency_bonus(level)

	# Especialista vem primeiro: quem é especialista também costuma estar treinado
	if skill in expert_skills:
		return mod + prof * 2
	if skill in trained_skills:
		return mod + prof
	return mod

## Salvaguarda = modificador do atributo (+ proficiência, se treinada)
func get_saving_throw_bonus(attr: Constants.Attribute) -> int:
	var bonus := Constants.get_attribute_modifier(attributes[attr])
	if attr in saving_throws:
		bonus += get_profficiency_bonus(level)
	return bonus

## Percepção passiva = 10 + modificador de Sabedoria
func get_passive_perception() -> int:
	return 10 + Constants.get_attribute_modifier(attributes[Constants.Attribute.WIS])
