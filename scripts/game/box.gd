class_name Box
extends GameEntity

var ACTIVE_BOX : Rect2
var WIN_BOX : Rect2

func _ready() -> void:
	ACTIVE_BOX = Rect2(1 * tile_map.TILE_SIZE, 1 * tile_map.TILE_SIZE, tile_map.TILE_SIZE, tile_map.TILE_SIZE)
	WIN_BOX = Rect2(2 * tile_map.TILE_SIZE, 1 * tile_map.TILE_SIZE, tile_map.TILE_SIZE, tile_map.TILE_SIZE)
	super._build_sprite(1, 1)
	super.update_pixel_position()

func update_visuals() -> void:
	var my_texture = sprite.texture
	if grid_pos in tile_map.goal_tiles:
		my_texture.region = WIN_BOX
	else:
		if my_texture.region == WIN_BOX:
			my_texture.region = ACTIVE_BOX
