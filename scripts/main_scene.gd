extends Node2D

@onready var move_slot_scene = preload("res://scenes/pokemon/move_slot.tscn")
@onready var container = $Control/HBoxContainer # Um HBox ou Grid na sua tela

func _ready() -> void:
	# Pega alguns moves do DB para teste
	var move1 = PokemonDB.get_move("curse")
	var move2 = PokemonDB.get_move("thunder_shock")
	var move3 = PokemonDB.get_move("disarming_voice")
	var move4 = PokemonDB.get_move("stomping_tantrum")
	
	# Instancia a cena do Slot e preenche
	var slot1 = move_slot_scene.instantiate()
	container.add_child(slot1)
	slot1.setup(move1, 30)
	
	var slot2 = move_slot_scene.instantiate()
	container.add_child(slot2)
	slot2.setup(move2, 30)
	
	var slot3 = move_slot_scene.instantiate()
	container.add_child(slot3)
	slot3.setup(move3, 20)
	
	var slot4 = move_slot_scene.instantiate()
	container.add_child(slot4)
	slot4.setup(move4, 0)
