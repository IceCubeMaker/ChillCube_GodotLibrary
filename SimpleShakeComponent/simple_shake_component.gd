## Simple shake component.
## Usage: Append to a Camera2D Node to add screen shake. Set defaults and call the shake() function to shake.
## To stop the shake call the stop function.
## Alternatively, call the shake function with values.
@tool
extends Node
class_name SimpleShakeComponent

signal shake_start
signal shake_stop

@export var root: Node
@export var shaking: bool = false:
	set(flag):
		shaking = flag
		if Engine.is_editor_hint():
			_current_shake_strength = default_strength
			_current_shake_dropoff = default_dropoff
			shake_start.emit()
@export var default_strength: float = 10
@export var default_dropoff: float = 5
@export var debug: bool = false

var _current_shake_strength: float = 0.0
var _current_shake_dropoff: float = 0.0


func _ready() -> void:
	if !root:
		root = get_parent()
		if debug: printerr("The root was not explicitly set and was 
			therefore set to the parent automatically.")


func _physics_process(delta: float) -> void:
	if shaking:
		_process_shake(delta)


func _process_shake(delta: float) -> void:
	_current_shake_strength = lerp(_current_shake_strength, 0.0, delta * _current_shake_dropoff)
	var rand_x = randf_range(-_current_shake_strength, _current_shake_strength)
	var rand_y = randf_range(-_current_shake_strength, _current_shake_strength)
	var offset: Vector2 = Vector2(rand_x, rand_y)
	if _current_shake_strength < 0.5:
		stop()
	root.offset = offset

## Starts a shake with default parameters
func shake(strength: float = default_strength, dropoff: float = default_dropoff) -> void:
	shaking = true
	_current_shake_strength = strength
	_current_shake_dropoff = dropoff
	shake_start.emit()

## Stops the current shake.
func stop() -> void:
	shaking = false
	_current_shake_strength = 0
	shake_stop.emit()
