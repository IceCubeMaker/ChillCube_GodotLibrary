## This node is used to create in game grid coordinates. It can take both grid coordinates and the actual position as input and convert into the other.
## This can be used for strategy games like chess, or games with grid movement, like pokemon. 
extends Node2D
class_name Grid

@export var tile_size_x : float = 100;
@export var tile_size_y : float = 100;

## defines whether the grid should have borders or not
@export var borders : bool = true;
@export var max_tiles_x : int = 100;
@export var max_tiles_y : int = 100;

func get_grid_coordinate(_position: Vector2) -> Vector2:
	var x : int = round((_position.x - global_position.x)/ tile_size_x) 
	var y : int = round((_position.y - global_position.y)/ tile_size_y) 
	return Vector2(x,y)

func get_grid_position(coordinate : Vector2) -> Vector2:
	var x : int = global_position.x + (coordinate.x * tile_size_x) 
	var y : int = global_position.y + (coordinate.y * tile_size_y) 
	return Vector2(x,y)
