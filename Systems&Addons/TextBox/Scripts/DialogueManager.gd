extends Node

@onready var textbox_scene = preload("res://export scenes/text_box.tscn")

var dialog_lines : Array[String] = []
var curr_dialog_index = 0
var textbox
var reference_object : Node3D  # Store the 3D object reference
var camera : Camera3D  # Store camera reference
var is_dialogue_active = false
var can_advance = false

func start_dialog(ref_object : Node3D, cam : Camera3D, lines : Array[String]):
	#print("=== START DIALOG ===")
	#print("Reference object: ", ref_object)
	#print("Camera: ", cam)
	#print("Lines count: ", lines.size())
	
	if is_dialogue_active:
		#print("Dialog already active, returning")
		return
	
	dialog_lines = lines
	reference_object = ref_object
	camera = cam
	_show_text_box()
	
	is_dialogue_active = true

func _show_text_box():
	#print("=== SHOW TEXT BOX ===")
	textbox = textbox_scene.instantiate()
	textbox.MAX_WIDTH = 1080
	textbox.finished_displaying.connect(_on_text_box_finished_displaying)
	get_tree().root.add_child(textbox)
	
	#print("Current dialog: ", dialog_lines[curr_dialog_index])
	
	# Pass the object and camera to the textbox for tracking
	textbox.setup_tracking(reference_object, camera)
	textbox.display_text(dialog_lines[curr_dialog_index])
	
	can_advance = false

func _on_text_box_finished_displaying(text : String):
	#print("=== TEXT BOX FINISHED ===")
	if curr_dialog_index >= dialog_lines.size():
		is_dialogue_active = false
	can_advance = true

func _unhandled_input(event: InputEvent) -> void:
	if(event.is_action_pressed("advance_dialog") && is_dialogue_active && can_advance):
		#print("=== ADVANCING DIALOG ===")
		textbox.queue_free()
		curr_dialog_index += 1
		
		if curr_dialog_index >= dialog_lines.size():
			#print("Dialog finished, resetting")
			is_dialogue_active = false
			curr_dialog_index = 0
			return
		_show_text_box()
