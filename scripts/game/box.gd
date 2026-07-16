class_name Box
extends GameEntity

var ACTIVE_BOX : Rect2
var WIN_BOX : Rect2

func _ready() -> void:
	ACTIVE_BOX = Rect2(
			1 * LevelData.TILE_SIZE,
			1 * LevelData.TILE_SIZE,
			LevelData.TILE_SIZE,
			LevelData.TILE_SIZE)
	WIN_BOX = Rect2(
			2 * LevelData.TILE_SIZE,
			1 * LevelData.TILE_SIZE,
			LevelData.TILE_SIZE,
			LevelData.TILE_SIZE)
	super._build_sprite(1, 1)
	super.update_pixel_position()

func update_visuals(on_goal_tile: bool) -> void:
	var my_texture = sprite.texture
	if on_goal_tile:
		my_texture.region = WIN_BOX
	else:
		if my_texture.region == WIN_BOX:
			my_texture.region = ACTIVE_BOX
