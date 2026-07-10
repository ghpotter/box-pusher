class_name LevelData

enum Level {
	LEVEL_MAP,
	PLAYER_START,
	BOX_STARTS
}

var level_1 := {
	Level.LEVEL_MAP: [[0,0,0,0,0,0,0,0,0,0],
					  [0,0,0,0,2,0,0,0,0,0],
					  [0,0,1,0,0,0,0,1,0,0],
					  [0,0,0,1,0,0,1,0,0,0],
					  [0,0,0,0,1,1,0,0,0,0],
					  [1,0,0,0,1,1,0,0,0,0],
					  [0,0,0,1,0,0,1,0,0,0],
					  [0,0,1,0,0,0,0,1,0,0],
					  [0,2,0,0,0,0,0,0,0,0],
					  [0,0,0,0,0,0,0,0,0,0]
					 ],
	Level.PLAYER_START: Vector2i(0,0),
	Level.BOX_STARTS: [Vector2i(3,1), Vector2i(1,3)]
	}

var level_2 := {
	Level.LEVEL_MAP: [[0,0,0,0,0,0,0,0,0,0],
					  [0,0,0,0,2,0,0,0,0,0],
					  [0,0,1,0,0,0,0,1,0,0],
					  [0,0,0,1,0,0,1,0,0,0],
					  [0,2,0,0,1,1,0,0,0,0],
					  [1,0,0,0,1,1,0,0,0,0],
					  [0,0,0,1,0,0,1,0,0,0],
					  [0,0,1,0,0,0,0,1,0,0],
					  [0,0,0,0,0,0,0,0,0,0],
					  [0,0,0,0,0,0,0,0,0,0]
					 ],
	Level.PLAYER_START: Vector2i(0,0),
	Level.BOX_STARTS: [Vector2i(2,1), Vector2i(1,3)]
	}

var levels := [level_1, level_2]

func get_level(level_number: int) -> Dictionary:
	return levels[level_number]
