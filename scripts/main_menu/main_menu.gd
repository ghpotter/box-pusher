class_name MainMenu
extends Node2D

const MAIN_GAME = "res://scenes/main.tscn"

func _ready() -> void:
	%StartGameButton.pressed.connect(_on_start_requested)
	%QuitGameButton.pressed.connect(_on_quit_requested)
	InputHandler.quit_requested.connect(_on_quit_requested)
	%LevelSelectButton.pressed.connect(_on_level_select_requested)

func _on_start_requested() -> void:
	get_tree().change_scene_to_file(MAIN_GAME)

func _on_quit_requested() -> void:
	get_tree().quit()

func _on_level_select_requested() -> void:
	%Background.visible = false
	%LevelSelectBackground.visible = true
