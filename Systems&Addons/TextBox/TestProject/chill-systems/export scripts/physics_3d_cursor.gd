extends Node3D

# Reference to the camera used to project mouse rays into 3D space
@export var camera: Camera3D
# Default setup settings
@export var ray_length := 1000.0
@export var drag_height := 0.0
@export var drag_force := 25.0
@export var max_speed := 10.0
@export var drag_action : String
@export var draggable_group_name : String
@export var visible_cursor_node : Node3D

# State exports to debug in inspector or modify in runtime
@export_group("STATE EXPORTS")
@export var is_dragging := false
@export var being_dragged: RigidBody3D

@export var grab_offset := Vector3.ZERO


func _physics_process(delta):
	# Moves the dragged object according to the mouse position
	if is_dragging and being_dragged:
		var hit_pos = get_mouse_plane_intersection()

		if hit_pos:
			var target = hit_pos + grab_offset

			# Horizontal direction only
			var pos = being_dragged.global_position
			var dir = Vector3(
				target.x - pos.x,
				0,
				target.z - pos.z
			)

			# Physics movement
			var velocity = dir * drag_force
			if max_speed != 0:
				velocity = velocity.limit_length(max_speed)
				

			being_dragged.linear_velocity.x = velocity.x
			being_dragged.linear_velocity.z = velocity.z
	
	

func _process(delta):
	var hit = get_mouse_plane_intersection()
	if hit:
		visible_cursor_node.global_position = Vector3(hit.x, drag_height, hit.z)
		#print(visible_cursor_node.global_position)

# Raycasts from the camera according to the mouse position on window.
func get_mouse_plane_intersection():
	var mouse_pos = get_viewport().get_mouse_position()

	var from = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)
	
	# Dragging plane to avoid floor clipping
	var plane = Plane(Vector3.UP, drag_height)
	return plane.intersects_ray(from, dir)


func _input(event):
	if event.is_action_pressed(drag_action):
		start_drag_try()

	if event.is_action_released(drag_action):
		stop_drag()


func start_drag_try():
	var mouse_pos = get_viewport().get_mouse_position()

	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length

	var query = PhysicsRayQueryParameters3D.create(from, to)
	var hit = get_world_3d().direct_space_state.intersect_ray(query)

	if hit:
		var body = hit.collider
		if body is RigidBody3D and body.is_in_group(draggable_group_name):
			being_dragged = body
			is_dragging = true

			drag_height = body.global_position.y

			var plane_hit = get_mouse_plane_intersection()
			grab_offset = body.global_position - plane_hit


func stop_drag():
	is_dragging = false

	if being_dragged:
		being_dragged.linear_velocity.x = 0
		being_dragged.linear_velocity.z = 0
		being_dragged = null
