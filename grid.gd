class_name Grid
extends TileMapLayer

const SOURCE_ID = 0
const FLOOR = Vector2i(0,0)
const WALL = Vector2i(1,0)
const GOAL = Vector2i(2,0)
const TILE_SIZE = 64

var level_map: Array
var goal_tiles: Array[Vector2i]
var player_start: Vector2i
var box_starts: Array

func build_level(level_data: Dictionary) -> void:
	clear()
	goal_tiles.clear()
	level_map = level_data[LevelData.Level.LEVEL_MAP]
	player_start = level_data[LevelData.Level.PLAYER_START]
	box_starts = level_data[LevelData.Level.BOX_STARTS]
	for y in range(len(level_map)):
		for x in range(len(level_map[y])):
			var tile = FLOOR
			if level_map[y][x] == 1:
				tile = WALL
			elif level_map[y][x] == 2:
				tile = GOAL
				goal_tiles.append(Vector2i(x,y))
			set_cell(Vector2i(x, y), SOURCE_ID, tile)

func get_width() -> int:
	return len(level_map[0])

func get_height() -> int:
	return len(level_map)
