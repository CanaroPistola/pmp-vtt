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

@export var level: int = 1
@export var xp: int

@export var max_hp: int
@export var current_hp: int
@export var temp_hp: int

@export var pokeslots: int
@export var max_sr: String

## VALOR BASE do atributo (o que o jogador digita no LineEdit).
## Bônus de região e de especializações NÃO são aplicados aqui; são somados
## em leitura por get_effective_attribute(). Isso evita que o bônus seja
## duplicado a cada save/load.
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

## Região de origem (id de Regions.DATA, ex.: "Kanto"; vazio = nenhuma)
@export var region: String = ""
## Bônus que a região concede em cada atributo (atributo -> valor).
## Somado em leitura por get_effective_attribute(); `attributes` permanece base.
@export var region_attr_bonus := {}
## Perícia fixa da região (Constants.Skill) ou -1
@export var region_skill: int = -1
## Perícias escolhidas livremente pela região (Unova)
@export var region_extra_skills: Array = []

@export var movement := {
	Constants.Movement.WALKING: 9,
}

@export var armor_class: int
@export var initiative: int

@export var profficiency_bonus: int

@export var pokedollars: int

## Retrato do treinador: WebP codificado em base64, guardado dentro da própria ficha
@export var portrait_data: String


# ---------------------------------------------------------------------------
# Atributos: base + efetivo
# ---------------------------------------------------------------------------

## Valor efetivo de um atributo: base digitada + bônus de região + bônus de specs.
## É a fonte única de verdade para cálculo de modificadores, CA, PV, perícias etc.
func get_effective_attribute(attr: Constants.Attribute) -> int:
	var value: int = attributes.get(attr, 8)
	value += int(region_attr_bonus.get(attr, 0))
	value += _spec_attr_bonus_for(attr)
	value += _talent_attr_bonus_for(attr) # NOVO
	return clampi(value, 0, 30)

func _talent_attr_bonus_for(attr: Constants.Attribute) -> int:
	var total := 0
	for slot in talents:
		var t_id := ""
		var choices := {}
		if typeof(slot) == TYPE_STRING:
			t_id = slot
		elif typeof(slot) == TYPE_DICTIONARY:
			t_id = slot.get("id", "")
			choices = slot.get("choices", {})
			
		if t_id == "": continue
		
		var b := TrainersTalents.get_attribute_bonus(t_id)
		if b.has(attr):
			total += b[attr]
		elif b.has("choice"):
			if choices.get("attribute", -1) == attr:
				total += 1
	return total

func _spec_attr_bonus_for(attr: Constants.Attribute) -> int:
	var total := 0
	var vistas := {}

	for slot in specializations:
		var id: String = slot.get("id", "")
		if id.is_empty() or vistas.has(id):
			continue
		
		vistas[id] = true

		if Specializations.get_attribute_fixed(id) == attr:
			total += 1
		
		if slot.get("attribute", -1) == attr:
			total += 1
			
	return total

func set_attribute(attr: Constants.Attribute, value: int) -> void:
	attributes[attr] = clampi(value, 0, 30)
	recalculate()
	attribute_changed.emit(attr, get_effective_attribute(attr))
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

## Aplica uma região de origem (id "" limpa a região).
## choices: {"attr_bonus": {atributo: valor}, "skills": [perícias]}, já com as escolhas resolvidas.
## O bônus de atributo é guardado em `region_attr_bonus` e somado em leitura;
## `attributes` permanece como valor base. Perícias/salvaguardas ficam em
## campos próprios e são consultadas por is_skill_trained()/is_saving_throw_trained().
func set_region(id: String, choices: Dictionary = {}) -> void:
	var attr_bonus: Dictionary = choices.get("attr_bonus", {})
	var extra_skills: Array = choices.get("skills", [])
	if id == region and attr_bonus == region_attr_bonus and extra_skills == region_extra_skills:
		return
	region = id
	region_attr_bonus = attr_bonus.duplicate()
	region_extra_skills = extra_skills.duplicate()
	region_skill = Regions.get_skill(id)
	recalculate()  # CA (Sinnoh), PV (CON) etc.
	for attr in Constants.Attribute.values():
		attribute_changed.emit(attr, get_effective_attribute(attr))
	emit_changed()

func is_skill_from_region(skill: Constants.Skill) -> bool:
	return skill == region_skill or skill in region_extra_skills

func is_skill_trained(skill: Constants.Skill) -> bool:
	for slot in talents:
		var t_id := ""
		var choices := {}
		if typeof(slot) == TYPE_STRING:
			t_id = slot
		elif typeof(slot) == TYPE_DICTIONARY:
			t_id = slot.get("id", "")
			choices = slot.get("choices", {})
			
		if t_id == "": continue
		
		if skill in TrainersTalents.get_skills_fixed(t_id):
			return true
		if t_id == "perito" and skill in choices.get("skills", []):
			return true
			
	return skill in trained_skills \
		or is_skill_from_region(skill) \
		or is_skill_from_journey(skill) \
		or is_skill_from_class(skill) \
		or is_skill_from_specialization(skill)

func is_saving_throw_from_region(attr: Constants.Attribute) -> bool:
	return attr in Regions.get_saving_throws(region)

func is_saving_throw_trained(attr: Constants.Attribute) -> bool:
	return attr in saving_throws or is_saving_throw_from_region(attr)

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

## Recalcula tudo que deriva de nível e dos atributos EFETIVOS
## (base + região + especializações).
## Recalcula CA e PV considerando também os talentos.
func recalculate() -> void:
	level = clampi(level, 1, 20)
	var old_max_hp := max_hp
	var dex_mod := Constants.get_attribute_modifier(get_effective_attribute(Constants.Attribute.DEX))
	var con_mod := Constants.get_attribute_modifier(get_effective_attribute(Constants.Attribute.CON))
	
	var ca_bonus := 0
	var hp_bonus := 0
	
	for slot in talents:
		var t_id := ""
		if typeof(slot) == TYPE_STRING:
			t_id = slot
		elif typeof(slot) == TYPE_DICTIONARY:
			t_id = slot.get("id", "")
			
		if t_id == "aumento_ca":
			ca_bonus += 1
		elif t_id == "robusto":
			hp_bonus += 2 * level
			
	armor_class = 10 + dex_mod + Regions.get_ac_bonus(region) + ca_bonus
	initiative = dex_mod
	profficiency_bonus = get_profficiency_bonus(level)
	max_hp = 10 + (level * con_mod) + (level * 2 - 2) + hp_bonus
	
	if old_max_hp == 0:
		current_hp = max_hp
	else:
		current_hp = maxi(current_hp + (max_hp - old_max_hp), 0)
	pokeslots = POKESLOTS[level]
	max_sr = MAX_SR[level]

func get_profficiency_bonus(lvl: int) -> int:
	return Constants.PROFFICIENCY_BONUS[lvl]

## Bônus de perícia, checando se é especialista por talento.
func get_skill_bonus(skill: Constants.Skill) -> int:
	var attr: Constants.Attribute = Constants.SKILL_DETAILS[skill]["attribute"]
	var mod := Constants.get_attribute_modifier(get_effective_attribute(attr))
	var prof := get_profficiency_bonus(level)

	if skill in expert_skills:
		return mod + prof * 2
		
	for slot in talents:
		var t_id := ""
		if typeof(slot) == TYPE_STRING:
			t_id = slot
		elif typeof(slot) == TYPE_DICTIONARY:
			t_id = slot.get("id", "")
		
		if t_id != "" and skill in TrainersTalents.get_skills_expert(t_id):
			return mod + prof * 2
			
	if is_skill_trained(skill):
		return mod + prof
	return mod

## Salvaguarda = modificador do atributo efetivo (+ proficiência, se treinada)
func get_saving_throw_bonus(attr: Constants.Attribute) -> int:
	var bonus := Constants.get_attribute_modifier(get_effective_attribute(attr))
	if is_saving_throw_trained(attr):
		bonus += get_profficiency_bonus(level)
	return bonus

## Percepção passiva = 10 + mod(SAB efetivo) + proficiência (se treinado em Percepção)
func get_passive_perception() -> int:
	var mod := Constants.get_attribute_modifier(
		get_effective_attribute(Constants.Attribute.WIS))
	var bonus := 10 + mod
	if is_skill_trained(Constants.Skill.PERCEPCAO):
		bonus += get_profficiency_bonus(level)
	return bonus

## Origem de Jornada (id de Journeys.DATA, ex.: "Atleta"; vazio = nenhuma)
@export var journey: String = ""
## Perícias fixas da origem de jornada
@export var journey_skills: Array = []

## (futuro) conhecimento de itens e equipamento bônus, guardados como dado cru
@export var journey_item_knowledge: String = ""
@export var journey_bonus_equipment: Dictionary = {}

func set_journey(id: String) -> void:
	if id == journey:
		return
	journey = id
	journey_skills = Journeys.get_skills(id).duplicate()
	journey_item_knowledge = Journeys.get_item_knowledge(id)
	journey_bonus_equipment = Journeys.get_bonus_equipment(id).duplicate()
	recalculate()
	emit_changed()

func is_skill_from_journey(skill: Constants.Skill) -> bool:
	return skill in journey_skills

## Classe de Treinador (id de TrainersClasses.DATA, ex.: "treinador_as"; vazio = nenhuma)
@export var trainer_class: String = ""
## Perícias fixas garantidas pela classe
@export var class_skills: Array = []
## Perícias escolhidas livremente pela classe (Pesquisador / Versátil)
@export var class_skills_chosen: Array = []

func set_class(id: String, choices: Dictionary = {}) -> void:
	if id == trainer_class and choices.is_empty():
		return
	trainer_class = id
	class_skills = TrainersClasses.get_skills_fixed(id).duplicate()
	class_skills_chosen = choices.get("skills", []).duplicate()
	recalculate()
	emit_changed()

func is_skill_from_class(skill: Constants.Skill) -> bool:
	return skill in class_skills or skill in class_skills_chosen

## Especializações escolhidas. Array de até 3 dicionários:
##   {"id": String, "skill": int, "attribute": int}
## Skill/attribute guardam a escolha feita na etapa 2, ou -1 se não se aplicam.
## O bônus de atributo é derivado em leitura por _spec_attr_bonus_for();
## `attributes` permanece como valor base.
@export var specializations: Array = []

const SPECIALIZATION_SLOT_LEVELS := [1, 7, 18]

func is_specialization_slot_unlocked(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= SPECIALIZATION_SLOT_LEVELS.size():
		return false
	return level >= SPECIALIZATION_SLOT_LEVELS[slot_index]

func set_specialization(slot_index: int, id: String, choices: Dictionary = {}) -> void:
	if not is_specialization_slot_unlocked(slot_index):
		return

	# Garante que o array tenha o tamanho certo
	while specializations.size() <= slot_index:
		specializations.append({"id": "", "skill": -1, "attribute": -1})

	specializations[slot_index] = {
		"id": id,
		"skill": choices.get("skill", -1),
		"attribute": choices.get("attribute", -1),
	}
	recalculate()
	for attr in Constants.Attribute.values():
		attribute_changed.emit(attr, get_effective_attribute(attr))
	emit_changed()

func remove_specialization(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= specializations.size():
		return
	specializations[slot_index] = {"id": "", "skill": -1, "attribute": -1}
	recalculate()
	for attr in Constants.Attribute.values():
		attribute_changed.emit(attr, get_effective_attribute(attr))
	emit_changed()

func get_specialization(slot_index: int) -> Dictionary:
	if slot_index < 0 or slot_index >= specializations.size():
		return {}
	return specializations[slot_index]

func is_skill_from_specialization(skill: Constants.Skill) -> bool:
	for slot in specializations:
		var id: String = slot.get("id", "")
		if id.is_empty():
			continue
		if Specializations.get_skill_fixed(id) == skill:
			return true
		if slot.get("skill", -1) == skill:
			return true
	return false

## Inventário. Array de {"id": String, "quantity": int}
@export var inventory: Array = []

# ---------- Pokédólares ----------

func set_pokedollars(value: int) -> void:
	value = maxi(value, 0)
	if value == pokedollars:
		return
	pokedollars = value
	emit_changed()

func add_pokedollars(amount: int) -> void:
	set_pokedollars(pokedollars + amount)

## Tenta descontar; retorna false se não houver saldo
func spend_pokedollars(amount: int) -> bool:
	if amount <= 0:
		return true
	if pokedollars < amount:
		return false
	set_pokedollars(pokedollars - amount)
	return true

# ---------- Inventário ----------

func add_item(id: String, quantity: int = 1) -> void:
	if quantity <= 0:
		return

	# Pacotes são "atalhos": ao adicionar, expandem nos itens que os compõem
	# e não aparecem no inventário por si mesmos.
	if ItemData.has_item(id):
		var eff: Dictionary = ItemData.get_effect(id)
		if eff.get("type", "") == "package":
			for entry in eff.get("contents", []):
				var child_id: String = entry.get("id", "")
				var child_qty: int = int(entry.get("qty", 1)) * quantity
				if not child_id.is_empty() and child_qty > 0:
					add_item(child_id, child_qty)
			return

	for entry in inventory:
		if entry.get("id", "") == id:
			entry["quantity"] = entry.get("quantity", 0) + quantity
			emit_changed()
			return
	inventory.append({"id": id, "quantity": quantity})
	emit_changed()

func remove_item(id: String, quantity: int = 1) -> void:
	if quantity <= 0:
		return
	for i in range(inventory.size()):
		if inventory[i].get("id", "") == id:
			inventory[i]["quantity"] = inventory[i].get("quantity", 0) - quantity
			if inventory[i]["quantity"] <= 0:
				inventory.remove_at(i)
			emit_changed()
			return

func get_item_quantity(id: String) -> int:
	for entry in inventory:
		if entry.get("id", "") == id:
			return entry.get("quantity", 0)
	return 0

func has_item(id: String, quantity: int = 1) -> bool:
	return get_item_quantity(id) >= quantity

## Talentos escolhidos. Array de IDs de talentos.
@export var talents: Array = []

## Escolhas feitas nos talentos que pedem opções.
@export var talent_choices: Dictionary = {} 

func set_talent(slot_index: int, id: String, choices: Dictionary = {}) -> void:
	if not TrainersTalents.has_data(id):
		return
		
	while talents.size() <= slot_index:
		talents.append({})
		
	talents[slot_index] = {"id": id, "choices": choices}
	
	recalculate()
	for attr in Constants.Attribute.values():
		attribute_changed.emit(attr, get_effective_attribute(attr))
	emit_changed()

func remove_talent(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= talents.size():
		return
	talents[slot_index] = {}
	recalculate()
	for attr in Constants.Attribute.values():
		attribute_changed.emit(attr, get_effective_attribute(attr))
	emit_changed()

## Retorna o tipo de Pokémon escolhido no talento "Mestre do Tipo",
## ou -1 se não tiver escolhido ou não tiver o talento.
func get_master_type() -> int:
	for slot in talents:
		if typeof(slot) == TYPE_DICTIONARY and slot.get("id", "") == "mestre_do_tipo":
			var choices = slot.get("choices", {})
			return choices.get("pokemon_type", -1)
	return -1
