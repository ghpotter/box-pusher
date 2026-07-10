class_name LevelSelect
extends CanvasLayer

const BUTTONS_IN_ROW = 5
const BUTTON_SIZE = Vector2(72, 72)
const BUTTON_COLOR = Color(0, 1, 1, 0.5)

func _ready() -> void:
	for level_number in range(len(LevelData.levels)):
		var divmod = _divmod(level_number, BUTTONS_IN_ROW)
		var row = divmod[0]
		var col = divmod[1]
		var levelRect = ColorRect.new()
		levelRect.position = Vector2(20 + 92 * col, 20 + 92 * row)
		levelRect.size = BUTTON_SIZE
		levelRect.color = BUTTON_COLOR
		var levelButton = Button.new()
		levelButton.size = BUTTON_SIZE
		levelButton.text = "Level %d" % [level_number + 1]
		levelButton.pressed.connect(_on_load_level.bind(level_number))
		levelRect.add_child(levelButton)

		%LevelSelectBackground.add_child(levelRect)

func _divmod(number: int, base: int) -> Array:
	@warning_ignore("integer_division")
	return [number/base, number%base]

func _on_load_level(level: int) -> void:
	LevelData.current_level = level
	get_tree().change_scene_to_file("res://scenes/main.tscn")
