extends Node
## Autoload global: carrega e mantém em cache todas as PokemonSpecies e MoveData.

const SPECIES_DIR := "res://data/pokemon/"
const MOVES_DIR := "res://data/moves/"
const SPRITE_DIR := "res://assets/pc_sprites/"

var _species: Dictionary = {}
var _moves: Dictionary = {} # { "tackle": MoveData, ... }
var _sprite_cache: Dictionary = {}
var _loaded: bool = false

func _ready() -> void:
	_load_all_data()

# ---------- Carregamento ----------

func _load_all_data() -> void:
	if _loaded: return
	_load_all_species()
	_load_all_moves()
	_loaded = true

func _load_all_species() -> void:
	var dir = DirAccess.open(SPECIES_DIR)
	if not dir:
		push_error("PokemonDB: pasta de espécies não encontrada: " + SPECIES_DIR)
		return
	
	var count := 0
	for file in dir.get_files():
		if not file.ends_with(".tres"): continue
		var path = SPECIES_DIR + file
		var species = load(path)
		if species is PokemonSpecies:
			_species[species.id] = species
			count += 1
	print("[PokemonDB] Carregadas %d espécies." % count)

func _load_all_moves() -> void:
	var dir = DirAccess.open(MOVES_DIR)
	if not dir:
		push_warning("PokemonDB: pasta de moves não encontrada: " + MOVES_DIR)
		return

	var count := 0
	for file in dir.get_files():
		if not file.ends_with(".tres"): continue
		var path = MOVES_DIR + file
		var move = load(path)
		if move is MoveData:
			_moves[move.id] = move
			count += 1
	print("[PokemonDB] Carregados %d Moves." % count)

# ---------- Consultas (Espécies) ----------

func get_species(id: String) -> PokemonSpecies:
	if not _loaded: _load_all_data()
	return _species.get(id, null)

func get_all_species() -> Array:
	if not _loaded: _load_all_data()
	return _species.values()

func has_species(id: String) -> bool:
	if not _loaded: _load_all_data()
	return _species.has(id)

# ---------- Consultas (Moves) ----------

func get_move(id: String) -> MoveData:
	var normalized_id = id.to_lower().replace(" ", "_")
	if not _loaded: _load_all_data()
	return _moves.get(normalized_id, null)

func get_all_moves() -> Array:
	if not _loaded: _load_all_data()
	return _moves.values()

func has_move(id: String) -> bool:
	if not _loaded: _load_all_data()
	return _moves.has(id.to_lower().replace(" ", "_"))

# ---------- Sprites ----------

func get_sprite(id: String) -> Texture2D:
	if _sprite_cache.has(id):
		return _sprite_cache[id]
	var path = SPRITE_DIR + id + ".png"
	if ResourceLoader.exists(path):
		var tex = load(path)
		_sprite_cache[id] = tex
		return tex
	_sprite_cache[id] = null
	return null

func get_all_ids() -> Array:
	if not _loaded: _load_all_data()
	return _species.keys()
