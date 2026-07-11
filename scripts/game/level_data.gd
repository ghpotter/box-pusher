extends Node

enum Level {
	LEVEL_NAME,
	LEVEL_MAP,
	PLAYER_START,
	BOX_STARTS
}

const LEVEL_PATH = "res://resources/levels/"

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
				var level_data =load_level_from_json(file)
				if level_data:
					levels.append(level_data)
	else:
		print("An error occurred when trying to access the path.")

func load_level_from_json(file_name: String) -> Dictionary:
	# 1. Open the file in Read-Only mode
	var file = FileAccess.open(LEVEL_PATH + file_name, FileAccess.READ)
	if not file:
		print("Error: Could not open file. Code: ", FileAccess.get_open_error())
		return {}

	# 3. Pull the text content and safely close the file resource
	var json_text = file.get_as_text()
	file.close()

	# 4. Initialize the parser and parse the data string
	var json = JSON.new()
	var error = json.parse(json_text)

	# 5. Check if the parser ran into any format issues
	if error != OK:
		print("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())
		return {}

	var level_name = file_name.get_basename()
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
