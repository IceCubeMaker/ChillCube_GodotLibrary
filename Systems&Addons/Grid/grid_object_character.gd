extends GridObject
class_name GridPlayer

@export var input_left = "move_left"
@export var input_right = "move_right"
@export var input_down = "move_down"
@export var input_up = "move_up"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(input_left):
		coordinate_x -= 1;
	if event.is_action_pressed(input_right):
		coordinate_x += 1;
	if event.is_action_pressed(input_down):
		coordinate_y += 1;
	if event.is_action_pressed(input_up):
		coordinate_y -= 1;
