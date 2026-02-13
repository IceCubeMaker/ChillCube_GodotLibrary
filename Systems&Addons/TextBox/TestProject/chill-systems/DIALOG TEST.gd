extends StaticBody3D

@export var camera : Camera3D

func _ready() -> void:
	#print("=== DEBUG OBJECT READY ===")
	#print("Object position: ", global_position)
	#print("Camera assigned: ", camera != null)
	pass

func _process(delta: float) -> void:
	var mouse_position = get_viewport().get_mouse_position()
	var vp_pos = camera.unproject_position(self.global_position)
	
	if Input.is_action_just_pressed("left_click"):
		var distance = mouse_position.distance_to(vp_pos)
		#print("=== CLICK DETECTED ===")
		#print("Mouse position: ", mouse_position)
		#print("Object screen position: ", vp_pos)
		#print("Distance: ", distance)
		
		if distance < 30:
			#print("CLICK IS CLOSE ENOUGH - Starting dialog")
			DialogueManager.start_dialog(
				self,
				camera,
				[
					"Primer diálogo, no sé cuanto durará esto", 
					"Este es el segundo: [wave connected=0]Supercalifragilisticoespialidoso[/wave]", 
					"Tercero y último: [color=red][shake connected=0 level=25]IM THE SCATMAN![/shake][/color], bidibidibidomdorobdob... bidibidibidomdob... I'M THE SCATMAN!"
				]
			)
		#print("Click too far from object") 
