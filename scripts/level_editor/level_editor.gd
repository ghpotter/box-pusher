class_name LevelEditor
extends Node2D

enum PLACEMENT {
	NONE,
	PLAYER,
	FLOOR,
	WALL,
	BOX,
	GOAL
}
var editor_state := PLACEMENT.NONE

@onready var TILE_SELECT_BACKGROUND = $LevelEditorUI/TileSelectionBackground
@onready var FLOOR_BUTTON = %FloorButton
@onready var WALL_BUTTON = %WallButton
@onready var GOAL_BUTTON = %GoalButton
@onready var PLAYER_BUTTON = %PlayerButton
@onready var BOX_BUTTON = %BoxButton
@onready var CAMERA = $Camera2D

var dragging := false

var HIGHLIGHTED_TILE = StyleBoxFlat.new()

var tile_map := Grid.new()
var edit_level := {}
var action_list := []
var current_action := 0
var player := Player.new()
var boxes := {}

func _ready() -> void:
	create_ui()
	blank_level()
	add_child(player)

func create_ui() -> void:
	%NewLevelButton.pressed.connect(_on_new_level_requested)
	%QuitGameButton.pressed.connect(_on_quit_requested)
	InputHandler.quit_requested.connect(_on_quit_requested)
	%MainMenuButton.pressed.connect(_on_main_menu_requested)
	%LoadLevelButton.pressed.connect(_on_load_level_requested)
	%SaveLevelButton.pressed.connect(_on_save_level_requested)
	%UndoButton.pressed.connect(_on_undo_requested)
	InputHandler.undo_requested.connect(_on_undo_requested)
	%RedoButton.pressed.connect(_on_redo_requested)
	InputHandler.redo_requested.connect(_on_redo_requested)

	FLOOR_BUTTON.pressed.connect(_on_floor_tile_requested)
	WALL_BUTTON.pressed.connect(_on_wall_tile_requested)
	GOAL_BUTTON.pressed.connect(_on_goal_tile_requested)
	PLAYER_BUTTON.pressed.connect(_on_player_tile_requested)
	BOX_BUTTON.pressed.connect(_on_box_tile_requested)

	HIGHLIGHTED_TILE.border_color = Color(1, 1, 0, 1)
	HIGHLIGHTED_TILE.border_width_bottom = 5
	HIGHLIGHTED_TILE.border_width_left = 5
	HIGHLIGHTED_TILE.border_width_right = 5
	HIGHLIGHTED_TILE.border_width_top = 5

	tile_map.tile_set = preload(FileLocations.TILE_SET_TRES)
	add_child(tile_map)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# This is for click and drag
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			dragging = event.pressed
		# This is for click/unclick to move
		# if event.pressed and event.button_index == MOUSE_BUTTON_MIDDLE:
			#dragging  = not dragging
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				place_tile(editor_state)

	if event is InputEventMouseMotion and dragging:
		CAMERA.position -= event.relative

func place_tile(state: PLACEMENT) -> void:
	if state == PLACEMENT.NONE:
		return
	var grid_pos := tile_map.local_to_map(get_global_mouse_position())
	if grid_pos.x < 0  or grid_pos.x > tile_map.get_width() - 1:
		return
	if grid_pos.y < 0 or grid_pos.y > tile_map.get_height() - 1:
		return
	if state == PLACEMENT.FLOOR:
		tile_map.level_map[grid_pos.y][grid_pos.x] = 0
		clear_tile(grid_pos)
		tile_map.set_cell(grid_pos, tile_map.SOURCE_ID, tile_map.FLOOR)
	elif state == PLACEMENT.WALL:
		tile_map.level_map[grid_pos.y][grid_pos.x] = 1
		clear_tile(grid_pos)
		tile_map.set_cell(grid_pos, tile_map.SOURCE_ID, tile_map.WALL)
	elif state == PLACEMENT.GOAL:
		tile_map.level_map[grid_pos.y][grid_pos.x] = 2
		clear_tile(grid_pos)
		tile_map.set_cell(grid_pos, tile_map.SOURCE_ID, tile_map.GOAL)
	elif state == PLACEMENT.PLAYER:
		if tile_map.level_map[grid_pos.y][grid_pos.x] != 0:
			return
		if grid_pos in tile_map.box_starts:
			return
		player.grid_pos = grid_pos
		tile_map.player_start = grid_pos
		player.update_pixel_position()
	elif state == PLACEMENT.BOX:
		if tile_map.level_map[grid_pos.y][grid_pos.x] != 0:
			return
		if tile_map.player_start == grid_pos:
			return
		if grid_pos in boxes:
			boxes[grid_pos].queue_free()
			boxes.erase(grid_pos)
			tile_map.box_starts.erase(grid_pos)
			return
		tile_map.box_starts.append(grid_pos)
		var box = Box.new(grid_pos)
		add_child(box)
		box.update_pixel_position()
		boxes[grid_pos] = box
	_save_action()


func clear_tile(grid_pos: Vector2i) -> void:
	if tile_map.player_start == grid_pos:
		tile_map.player_start = Vector2i(-1, -1)
	if grid_pos in tile_map.box_starts:
		boxes.erase(grid_pos)

func _on_new_level_requested() -> void:
	blank_level()

func _on_quit_requested() -> void:
	get_tree().quit()

func _on_main_menu_requested() -> void:
	get_tree().change_scene_to_file(FileLocations.MAIN_MENU_TSCN)

func _on_load_level_requested() -> void:
	%LoadLevelDialog.popup()

func _on_save_level_requested() -> void:
	%SaveLevelDialog.popup()

func _on_save_level_dialog_file_selected(file_name: String) -> void:
	if (
			tile_map.player_start.x < 0 or
			tile_map.player_start.y < 0 or
			tile_map.player_start.x > tile_map.get_height() or
			tile_map.player_start.y > tile_map.get_width()
	):
		print("Player not in a legal position")
		return
	if len(tile_map.box_starts) < len(tile_map.goal_tiles):
		print("The number of boxes cannot be less than the number of goal tiles")
		return
	var stringified_level = LevelData.level_to_json(tile_map)
	if not file_name.ends_with(".json"):
		file_name += ".json"
	var file = FileAccess.open(file_name, FileAccess.WRITE)

	if file:
		file.store_string(stringified_level)
	else:
		print("Failed to open file. Error code: ", FileAccess.get_open_error())
	file.close()

func _on_load_level_dialog_file_selected(file_name: String) -> void:
	blank_level()
	tile_map.build_level(LevelData.json_to_level(file_name))
	player = Player.new(tile_map.player_start)
	add_child(player)

	for b in tile_map.box_starts:
		boxes[b] = Box.new(b)
		add_child(boxes[b])

func _on_undo_requested() -> void:
	if current_action > 0:
		current_action -= 1
		var action = action_list[current_action]
		_load_snapshot(action)

func _on_redo_requested() -> void:
	if current_action < len(action_list) - 1:
		current_action += 1
		var action = action_list[current_action]
		_load_snapshot(action)

func _load_snapshot(snapshot: Dictionary) -> void:
	tile_map.level_map = snapshot["level_map"]
	player.grid_pos = snapshot["player_pos"]
	boxes = snapshot["boxes"]
	tile_map.build_level(
		{
			"name": "",
			LevelData.Level.LEVEL_MAP: tile_map.level_map,
			LevelData.Level.PLAYER_START: player.grid_pos,
			LevelData.Level.BOX_STARTS: boxes
		}
	)
	player.update_pixel_position()
	for box in boxes:
		box.update_pixel_position()

func _save_action() -> void:
	if len(action_list) > current_action + 1:
		action_list.resize(current_action + 1)
	var box_data = []
	for box in boxes:
		box_data.append([box.x, box.y])
	var snapshot = {
		"level_map": tile_map.level_map.duplicate(true),
		"player_pos": player.grid_pos,
		"boxes": box_data
	}
	action_list.append(snapshot)
	current_action = len(action_list) - 1

func blank_level() -> void:
	var temp_map := []
	for i in range(10):
		var row := []
		row.resize(10)
		row.fill(0)
		temp_map.append(row)

	for box in boxes:
		boxes[box].queue_free()
	boxes.clear()

	edit_level =  {
		LevelData.Level.LEVEL_NAME: "Temp Name",
		LevelData.Level.LEVEL_MAP: temp_map,
		LevelData.Level.PLAYER_START: Vector2i(0, 0),
		LevelData.Level.BOX_STARTS: []
	}
	tile_map.build_level(edit_level)
	player.grid_pos = Vector2i(0,0)
	player.update_pixel_position()
	_save_action()

func _on_floor_tile_requested() -> void:
	if editor_state == PLACEMENT.FLOOR:
		FLOOR_BUTTON.remove_theme_stylebox_override("normal")
		FLOOR_BUTTON.remove_theme_stylebox_override("hover")
		editor_state = PLACEMENT.NONE
	else:
		WALL_BUTTON.remove_theme_stylebox_override("normal")
		GOAL_BUTTON.remove_theme_stylebox_override("normal")
		PLAYER_BUTTON.remove_theme_stylebox_override("normal")
		BOX_BUTTON.remove_theme_stylebox_override("normal")
		FLOOR_BUTTON.add_theme_stylebox_override("normal", HIGHLIGHTED_TILE)
		FLOOR_BUTTON.add_theme_stylebox_override("hover", HIGHLIGHTED_TILE)
		editor_state = PLACEMENT.FLOOR

func _on_wall_tile_requested() -> void:
	if editor_state == PLACEMENT.WALL:
		WALL_BUTTON.remove_theme_stylebox_override("normal")
		WALL_BUTTON.remove_theme_stylebox_override("hover")
		editor_state = PLACEMENT.NONE
	else:
		FLOOR_BUTTON.remove_theme_stylebox_override("normal")
		GOAL_BUTTON.remove_theme_stylebox_override("normal")
		PLAYER_BUTTON.remove_theme_stylebox_override("normal")
		BOX_BUTTON.remove_theme_stylebox_override("normal")
		WALL_BUTTON.add_theme_stylebox_override("normal", HIGHLIGHTED_TILE)
		WALL_BUTTON.add_theme_stylebox_override("hover", HIGHLIGHTED_TILE)
		editor_state = PLACEMENT.WALL

func _on_goal_tile_requested() -> void:
	if editor_state == PLACEMENT.GOAL:
		GOAL_BUTTON.remove_theme_stylebox_override("normal")
		GOAL_BUTTON.remove_theme_stylebox_override("hover")
		editor_state = PLACEMENT.NONE
	else:
		FLOOR_BUTTON.remove_theme_stylebox_override("normal")
		WALL_BUTTON.remove_theme_stylebox_override("normal")
		PLAYER_BUTTON.remove_theme_stylebox_override("normal")
		BOX_BUTTON.remove_theme_stylebox_override("normal")
		GOAL_BUTTON.add_theme_stylebox_override("normal", HIGHLIGHTED_TILE)
		GOAL_BUTTON.add_theme_stylebox_override("hover", HIGHLIGHTED_TILE)
		editor_state = PLACEMENT.GOAL

func _on_player_tile_requested() -> void:
	if editor_state == PLACEMENT.PLAYER:
		PLAYER_BUTTON.remove_theme_stylebox_override("normal")
		PLAYER_BUTTON.remove_theme_stylebox_override("hover")
		editor_state = PLACEMENT.NONE
	else:
		FLOOR_BUTTON.remove_theme_stylebox_override("normal")
		WALL_BUTTON.remove_theme_stylebox_override("normal")
		GOAL_BUTTON.remove_theme_stylebox_override("normal")
		BOX_BUTTON.remove_theme_stylebox_override("normal")
		PLAYER_BUTTON.add_theme_stylebox_override("normal", HIGHLIGHTED_TILE)
		PLAYER_BUTTON.add_theme_stylebox_override("hover", HIGHLIGHTED_TILE)
		editor_state = PLACEMENT.PLAYER

func _on_box_tile_requested() -> void:
	if editor_state == PLACEMENT.BOX:
		BOX_BUTTON.remove_theme_stylebox_override("normal")
		BOX_BUTTON.remove_theme_stylebox_override("hover")
		editor_state = PLACEMENT.NONE
	else:
		FLOOR_BUTTON.remove_theme_stylebox_override("normal")
		WALL_BUTTON.remove_theme_stylebox_override("normal")
		GOAL_BUTTON.remove_theme_stylebox_override("normal")
		PLAYER_BUTTON.remove_theme_stylebox_override("normal")
		BOX_BUTTON.add_theme_stylebox_override("normal", HIGHLIGHTED_TILE)
		BOX_BUTTON.add_theme_stylebox_override("hover", HIGHLIGHTED_TILE)
		editor_state = PLACEMENT.BOX
