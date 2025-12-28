## This node is attached to a sprite or animated sprite to create a hitlflash effect. This can be used for things like indicating damage.
extends Node
class_name HitFlash

@export var length : float = 0.05;
@export var amount : int = 3;
@export var flash_color : Color = Color.TRANSPARENT

signal flash_started
signal flash_ended

func flash(_length : float = length, _amount : int = amount):
	emit_signal("flash_started")
	for i in _amount:
		get_parent().modulate = flash_color
		await get_tree().create_timer(_length).timeout
		get_parent().modulate = Color.WHITE
		await get_tree().create_timer(_length).timeout
		_length *= 1.5
	emit_signal("flash_ended")
