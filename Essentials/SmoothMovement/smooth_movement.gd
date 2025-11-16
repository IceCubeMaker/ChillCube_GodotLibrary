## Use this node to enable smooth movement on a node. To do this, attach the node to another node as a child. This node contains a "global_target_position" variable that you will be using instead of the regular position.
extends Node
class_name SmoothMovement

@export var speed = 20;

@export_group("bouncing")
@export var bounce : bool = true;
var velocity = Vector2.ZERO
@export var damping = 50.0

@export_group("Rotation")
## Disable or enable rotation (Note: Only the sprite is rotated)
@export var rotation_on : bool = true;
@export var rotation_strength : float = 2
@export var max_rotation : float = 1.5
## Seperates rotation to the sprite, rather than the parent node
@export var sprite_rotation : bool = false
## Sprite, used for rotation when dragging
@export var sprite_node : Node2D

var global_target_position : Vector2
var global_target_rotation : float

func _process(delta: float) -> void:
	var change = global_target_position - get_parent().global_position
	if rotation_on:
		_rotate_to_movement(delta)
	if bounce:
		_bounce(delta, global_target_position, global_target_rotation)
	else:
		_move(delta, global_target_position, global_target_rotation)

func _bounce(delta: float, target_pos, target_rot) -> void:
	var acceleration = (target_pos - get_parent().global_position) * speed * 3
	velocity += acceleration * delta
	velocity *= pow(damping, -delta)
	get_parent().global_position += velocity * delta
	get_parent().global_rotation = lerp_angle(get_parent().global_rotation, target_rot, delta * 5.0)

func _move(delta: float, target_pos, target_rot) -> void:
	get_parent().global_rotation += (target_rot - get_parent().global_rotation) * speed * delta
	get_parent().global_position += (target_pos - get_parent().global_position) * speed * delta

func _rotate_to_movement(delta) -> void:
		var change : Vector2 = (global_target_position - get_parent().global_position) * delta
		global_target_rotation = max(-max_rotation, min(max_rotation, change.x * rotation_strength));
