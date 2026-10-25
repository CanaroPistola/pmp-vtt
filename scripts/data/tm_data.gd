class_name TmData
extends RefCounted

const JSON_PATH := "res://data/json/tm_data.json"

# Dicionário estático, preenchido na primeira chamada (cache)
static var _data: Dictionary = {}
static var _loaded: bool = false

static func _ensure_loaded() -> void:
	if _loaded: return
	_loaded = true
	
	var file = FileAccess.open(JSON_PATH, FileAccess.READ)
	if not file:
		push_error("TmData: JSON não encontrado em " + JSON_PATH)
		return
	
	var json = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		push_error("TmData: erro ao ler o JSON.")
		return
	
	# Converte as chaves de string ("1") para int (1)
	var raw_data = json.data
	for key in raw_data:
		_data[int(key)] = raw_data[key]

static func has_data(num: int) -> bool:
	_ensure_loaded()
	return _data.has(num)

static func get_move_id(num: int) -> String:
	_ensure_loaded()
	var move_name = _data.get(num, {}).get("name", "")
	if move_name == "": return ""
	# Normalização exata que usamos no PokemonDB (minúsculo, sem espaços, sem apóstrofo/hífen)
	return move_name.to_lower().replace(" ", "_").replace("'", "").replace("-", "_").replace(".", "")

static func get_display_name(num: int) -> String:
	_ensure_loaded()
	var move_name = _data.get(num, {}).get("name", "Desconhecido")
	return "TM%03d %s" % [num, move_name]

static func get_price(num: int) -> int:
	_ensure_loaded()
	return int(_data.get(num, {}).get("price", 0))

static func get_all_numbers() -> Array:
	_ensure_loaded()
	var keys = _data.keys()
	keys.sort()
	return keys
