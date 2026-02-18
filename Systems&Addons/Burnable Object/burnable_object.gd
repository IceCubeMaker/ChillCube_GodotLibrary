extends RigidBody3D

class_name Burnable

var camera : Camera3D

# @export var burn_levels_dict : Dictionary[int, Resource]

@export var burn_levels_scenes : Array[Resource]
@export var burn_levels_objects : Array[Node]

@export var current_level_object : Node

@export var initial_level = 0
@export var current_level = 0

signal object_burned(effect : String)

func render_2d() -> void:
	var vp_position = camera.unproject_position(self.global_position)
	current_level_object.global_position = vp_position
	pass

func _process(delta: float) -> void:
	if current_level_object is Node2D:
		render_2d()

func _ready():
	camera = get_viewport().get_camera_3d()
	burn_levels_objects.resize(burn_levels_scenes.size())
	for i in range(0, burn_levels_scenes.size()):
		#burn_levels_objects[i] = burn_levels_scenes[i].instantiate()
		pass
	current_level_object = burn_levels_scenes[initial_level].instantiate()
	self.add_child(current_level_object)
	

func _on_fire_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("fire"):
		current_level += 1
		if current_level >= burn_levels_scenes.size():
			queue_free()
		else:
			current_level_object.queue_free()
			current_level_object = burn_levels_scenes[current_level].instantiate()
			
			self.add_child(current_level_object)
			pass
