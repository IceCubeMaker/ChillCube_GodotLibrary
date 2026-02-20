extends Node

class_name ObjectLevel

# Example: branch, apple 
@export var item_id : String = "" ## The identifier the system uses to make the choices
# Example: Tree Branch, Pine Cone...
@export var display_name : String = "" ## Name displayed to the player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
