extends Node

signal move_requested(dir: Vector2i)
signal undo_requested
signal redo_requested
signal restart_level_requested
signal quit_requested

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		quit_requested.emit()
		return
	if event.is_action_pressed("ui_restart"):
		restart_level_requested.emit()
		return
	if event.is_action_pressed("ui_undo"):
		undo_requested.emit()
		return
	if event.is_action_pressed("ui_redo"):
		redo_requested.emit()
		return
	if event.is_action_pressed("ui_up"):
		move_requested.emit(Vector2i(0, -1))
	elif event.is_action_pressed("ui_down"):
		move_requested.emit(Vector2i(0, 1))
	elif event.is_action_pressed("ui_left"):
		move_requested.emit(Vector2i(-1, 0))
	elif event.is_action_pressed("ui_right"):
		move_requested.emit(Vector2i(1, 0))
	return
