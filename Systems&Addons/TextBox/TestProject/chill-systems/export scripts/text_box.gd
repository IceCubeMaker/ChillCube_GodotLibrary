extends Node2D
class_name TextBox

@onready var label = $TextBox/MarginContainer/Label
@export var MAX_WIDTH : int = 256
@export var positionOffset : Vector2 = Vector2(0, -40)  # Negative Y = above object

var reference_object : Node3D
var camera : Camera3D
var is_ready_to_track : bool = false

signal finished_displaying(text : String)

func setup_tracking(ref_object : Node3D, cam : Camera3D):
	reference_object = ref_object
	camera = cam
	#print("=== SETUP TRACKING ===")
	#print("Tracking object: ", ref_object)
	#print("Using camera: ", cam)

func display_text(textToDisplay : String):
	#print("=== DISPLAY TEXT ===")
	#print("Text to display: ", textToDisplay)
	
	var formatted_text = "[typed]" + textToDisplay + "[/typed]"
	label.text = formatted_text
	
	await $TextBox.resized
	#print("Initial TextBox size: ", $TextBox.size)
	
	$TextBox.custom_minimum_size.x = min($TextBox.size.x, MAX_WIDTH)
	
	if $TextBox.size.x > MAX_WIDTH:
		print("Text exceeds MAX_WIDTH, enabling word wrap")
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await $TextBox.resized
		await $TextBox.resized
		$TextBox.custom_minimum_size.y = $TextBox.size.y
	
	#print("Final TextBox size: ", $TextBox.size)
	
	is_ready_to_track = true
	_update_position()
	
	finished_displaying.emit(formatted_text)

func _update_position():
	if not is_ready_to_track or not reference_object or not camera:
		return
	
	# Get the 2D screen position of the 3D object
	var screen_pos = camera.unproject_position(reference_object.global_position)
	
	# Position textbox:
	# - Centered horizontally on the object
	# - Offset vertically (negative offset = above the object in screen space)
	var pos_x = screen_pos.x - (label.size.x / 12.0)
	var pos_y = screen_pos.y + (label.size.y * -0.33333333333) + positionOffset.y  # SUBTRACT because negative offset should go UP
	# -0.5 * ($TextBox.size.y * .33333333333) + positionOffset.y
	# Clamp to viewport
	var viewport_size = get_viewport().get_visible_rect().size
	#pos_x = clamp(pos_x, 10, viewport_size.x - label.size.x - 10)
	#pos_y = clamp(pos_y, 10, viewport_size.y - label.size.y - 10)
	
	global_position = Vector2(pos_x, pos_y)

func _process(delta: float) -> void:
	_update_position()

func _ready() -> void:
	#print("=== TEXTBOX READY ===")
	pass
	
