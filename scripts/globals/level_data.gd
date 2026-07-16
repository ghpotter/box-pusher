extends Node

enum Level {
	LEVEL_NAME,
	LEVEL_MAP,
	PLAYER_START,
	BOX_STARTS
}

const LEVEL_PATH = "res://resources/levels/"
const TILE_SIZE = 64

var levels := []
var current_level := 0

func _ready() -> void:
	load_saved_levels()

func get_level(level_number: int) -> Dictionary:
	return levels[level_number]

func load_saved_levels() -> void:
	var dir = DirAccess.open(LEVEL_PATH)
	if dir:
		var files = dir.get_files()
		files.sort()
		for file in files:
			if file.ends_with(".json"):
				var level_data = json_to_level(LEVEL_PATH + file)
				if level_data:
					levels.append(level_data)
	else:
		print("An error occurred when trying to access the path.")

func json_to_level(file_name: String) -> Dictionary:
	var file = FileAccess.open(file_name, FileAccess.READ)
	if not file:
		print("Error: Could not open file. Code: ", FileAccess.get_open_error())
		return {}

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_text)

	if error != OK:
		print("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())
		return {}

	var level_name = file_name.get_file().get_basename()
	if "level_map" not in json.data:
		print("Level map data missing on load")
		return {}
	if "player_start" not in json.data:
		print("Player start missing on load")
		return {}
	if len(json.data["player_start"]) != 2:
		print("Player start does not have two values")
		return {}
	if "box_starts" not in json.data:
		print("Box starts data missing")
		return {}
	var level_map = json.data["level_map"]
	var player_start = Vector2i(json.data["player_start"][0], json.data["player_start"][1])
	var json_box_starts = json.data["box_starts"]
	var box_starts = []
	for json_box_start in json_box_starts:
		box_starts.append(Vector2i(json_box_start[0], json_box_start[1]))

	return {
		Level.LEVEL_NAME: level_name,
		Level.LEVEL_MAP: level_map,
		Level.PLAYER_START: player_start,
		Level.BOX_STARTS: box_starts
	}

func level_to_json(level_data: Grid) -> String:
	var player_data := [level_data.player_start.x, level_data.player_start.y]
	var box_data := []
	for box in level_data.box_starts:
		box_data.append([box.x, box.y])

	return JSON.stringify(
		{
			"level_map": level_data.level_map,
			"player_start": player_data,
			"box_starts": box_data
		}
	)
