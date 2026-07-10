class_name Player
extends GameEntity

func _ready() -> void:
	super._build_sprite(0,1)
	update_pixel_position()
