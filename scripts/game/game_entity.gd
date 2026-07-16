class_name GameEntity
extends Node2D

const ATLAS := preload(FileLocations.TILE_MAP_PNG)
var grid_pos := Vector2i(0,0)
var sprite : Sprite2D

func _init(pos: Vector2i = Vector2i.ZERO) -> void:
	grid_pos = pos

func _ready() -> void:
	update_pixel_position()

func _build_sprite(x: int, y: int) -> void:
	sprite = Sprite2D.new()
	var atlas_tex := AtlasTexture.new()
	atlas_tex.atlas = ATLAS
	atlas_tex.region = Rect2(
			x * LevelData.TILE_SIZE,
			y * LevelData.TILE_SIZE,
			LevelData.TILE_SIZE,
			LevelData.TILE_SIZE)
	sprite.texture = atlas_tex
	sprite.centered = false
	add_child(sprite)

func update_pixel_position() -> void:
	position = Vector2(grid_pos.x * LevelData.TILE_SIZE, grid_pos.y * LevelData.TILE_SIZE)
