class_name MyMain
extends Node2D

var tile_map := Grid.new()
var boxes: Dictionary = {}
var player: Player

var level_data := LevelData.new()
var current_level := 0
var max_level := len(level_data.levels)

var move_list : Array

enum Entity { PLAYER, BOX }
enum GameState { START, PLAYING, ANIMATION, TRANSITION, COMPLETE }
var game_state : GameState

func _ready() -> void:
	%StartGameButton.pressed.connect(_on_start_requested)
	%MenuQuitButton.pressed.connect(_on_quit_requested)
	%QuitGameButton.pressed.connect(_on_quit_requested)
	InputHandler.quit_requested.connect(_on_quit_requested)
	InputHandler.restart_level_requested.connect(_on_restart_level_requested)
	%RestartLevelButton.pressed.connect(_on_restart_level_requested)
	InputHandler.undo_move_requested.connect(_on_undo_move_requested)
	InputHandler.move_requested.connect(_on_move_requested)
	%RestartGameButton.pressed.connect(_on_restart_game_requested)

	tile_map.tile_set = preload("res://box_pusher_tile_set.tres")
	add_child(tile_map)
	game_state = GameState.START

func _on_start_requested() -> void:
	%MainMenu.visible = false
	load_level(0)


func _on_quit_requested() -> void:
	get_tree().quit()

func _on_restart_level_requested() -> void:
	if game_state == GameState.PLAYING:
		restart_level()

func _on_undo_move_requested() -> void:
	if game_state == GameState.PLAYING:
		undo_move()

func _on_move_requested(dir: Vector2i) -> void:
	if game_state != GameState.PLAYING:
		return
	var box_pos: Vector2i

	if not try_move(player.grid_pos, dir):
		return
	var target := player.grid_pos + dir
	if target in boxes:
		if not try_move(target, dir, true):
			return
		box_pos = target
		save_move(player.grid_pos, dir, box_pos)
		move_box(boxes[target], target + dir)
		flag_victory()
	else:
		box_pos = Vector2i(-1,-1)
		save_move(player.grid_pos, dir, box_pos)
	player.grid_pos = target
	if game_state == GameState.TRANSITION:
		advance_level()

func _on_restart_game_requested() -> void:
	%CompleteGameScreen.visible = false
	current_level = 0
	load_level(0)

func load_level(level_number: int) -> void:
	clear_level()
	%LevelLabel.text = "Level %d of %d" % [(current_level + 1), max_level]
	tile_map.build_level(level_data.get_level(level_number))
	player = Player.new(tile_map.player_start)
	player.tile_map = tile_map
	add_child(player)

	for b in tile_map.box_starts:
		boxes[b] = Box.new(b)
		boxes[b].tile_map = tile_map
		add_child(boxes[b])

	game_state = GameState.PLAYING

func clear_level() -> void:
	move_list.clear()
	tile_map.clear()
	if player:
		player.queue_free()
		player = null
	for b in boxes.values():
		b.queue_free()
	boxes.clear()

func restart_level() -> void:
	load_level(current_level)

func try_move(pos: Vector2i, dir: Vector2i, is_box: bool = false) -> bool:
	var target = pos + dir
	if target.x < 0 or target.x >= tile_map.get_width():
		return false
	if target.y < 0 or target.y >= tile_map.get_height():
		return false
	if tile_map.get_cell_atlas_coords(target) == tile_map.WALL:
		return false
	if is_box and target in boxes:
		return false
	return true

func move_box(box: Box, target: Vector2i) -> void:
	boxes.erase(box.grid_pos)
	box.grid_pos = target
	box.update_visuals()
	boxes[target] = box
	%BoxPushSoundPlayer.play()

func save_move(player_pos: Vector2i, dir: Vector2i, box_pos: Vector2i) -> void:
	var move = {Entity.PLAYER: [player_pos, player_pos + dir]}
	if box_pos != Vector2i(-1,-1):
		move[Entity.BOX] = [boxes[box_pos], box_pos, box_pos + dir]
	move_list.append(move)
	animate_move()

func undo_move() -> void:
	if len(move_list) < 1:
		return
	animate_move(true)
	var move = move_list.pop_back()
	player.grid_pos = move[Entity.PLAYER][0]
	if Entity.BOX in move:
		move_box(move[Entity.BOX][0],move[Entity.BOX][1] )

func animate_move(undo: bool = false) -> void:
	game_state = GameState.ANIMATION
	var move = move_list[-1]
	var tween = create_tween()
	tween.set_parallel()
	if undo:
		tween.tween_property(player, "position", Vector2(move[Entity.PLAYER][0] * tile_map.TILE_SIZE), 0.25)
		if Entity.BOX in move:
			tween.tween_property(move[Entity.BOX][0],"position", Vector2(move[Entity.BOX][1] * tile_map.TILE_SIZE), 0.25)

	else:
		tween.tween_property(player, "position", Vector2(move[Entity.PLAYER][1] * tile_map.TILE_SIZE), 0.25)
		if Entity.BOX in move:
			tween.tween_property(move[Entity.BOX][0],"position", Vector2(move[Entity.BOX][2] * tile_map.TILE_SIZE), 0.25)
	await tween.finished
	if game_state == GameState.ANIMATION:
		game_state = GameState.PLAYING

func flag_victory() -> void:
	var count = 0
	for goal in tile_map.goal_tiles:
		if goal in boxes:
			count += 1
	if count == len(tile_map.goal_tiles):
		game_state = GameState.TRANSITION
		%VictorySoundPlayer.play()

func advance_level() -> void:
		current_level += 1
		if current_level < max_level:
			%LevelCompleteLabel.visible = true
			await get_tree().create_timer(5).timeout
			%LevelCompleteLabel.visible = false
			load_level(current_level)
		else:
			%CompleteGameScreen.visible = true
			game_state = GameState.COMPLETE
