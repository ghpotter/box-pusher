class_name GameEntity
extends Node2D

const ATLAS := preload("res://resources/bitmap/BoxPusherTileMap.png")
var tile_map: Grid = null
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
	atlas_tex.region = Rect2(x * tile_map.TILE_SIZE, y * tile_map.TILE_SIZE, tile_map.TILE_SIZE, tile_map.TILE_SIZE)
	sprite.texture = atlas_tex
	sprite.centered = false
	add_child(sprite)

func update_pixel_position() -> void:
	position = Vector2(grid_pos.x * tile_map.TILE_SIZE, grid_pos.y * tile_map.TILE_SIZE)
