extends Node2D
class_name GridObject

@export var grid : Grid;
@export var continous_movement : bool = true;
@export var coordinate_x : int = 0
@export var coordinate_y : int = 0

func _process(delta: float) -> void:
	if continous_movement:
		_move(Vector2(coordinate_x, coordinate_y))

func move_to_coordinate(new_coordinate : Vector2) -> void:
	coordinate_x = new_coordinate.x
	coordinate_y = new_coordinate.y
	_move(Vector2(coordinate_x, coordinate_y))

func move_to_position(new_position : Vector2) -> void:
	var new_coordinate : Vector2 = grid.get_grid_coordinate(new_position)
	coordinate_y = new_coordinate.y
	coordinate_x = new_coordinate.x
	_move(Vector2(coordinate_x, coordinate_y))

func _move(coordinate : Vector2) -> void:
	if has_node("SmothMovement"):
		get_node("SmoothMovement").global_target_position = grid.get_grid_position(coordinate)
	else:
		global_position = grid.get_grid_position(coordinate)
