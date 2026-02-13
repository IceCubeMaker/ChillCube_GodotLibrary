extends Cursor3D
class_name DynamicCursor3D

# ---- MODE SWITCH ----
@export var use_physics_drag := true   # can toggle in editor or runtime

# ---- PHYSICS MODE SETTINGS ----
@export var ray_length := 1000.0
@export var drag_force := 25.0
@export var max_speed := 10.0


# ---------------------------
# MAIN LOOPS
# ---------------------------

func _process(delta):
	update_cursor()

	if is_dragging and being_dragged and !use_physics_drag:
		plane_snap_drag()


func _physics_process(delta):
	if is_dragging and being_dragged and use_physics_drag:
		physics_plane_drag()


# ---------------------------
# DRAG MODES
# ---------------------------

func plane_snap_drag():
	var hit_pos = get_mouse_plane_intersection()
	if !hit_pos:
		return

	var target = hit_pos + grab_offset

	var pos = being_dragged.global_position
	pos.x = target.x
	pos.z = target.z

	being_dragged.global_position = pos


func physics_plane_drag():
	var hit_pos = get_mouse_plane_intersection()
	if !hit_pos:
		return

	var target = hit_pos + grab_offset

	var pos = being_dragged.global_position

	var dir = Vector3(
		target.x - pos.x,
		0,
		target.z - pos.z
	)

	var velocity = dir * drag_force
	if max_speed != 0.0:
		velocity = velocity.limit_length(max_speed)
	

	being_dragged.linear_velocity.x = velocity.x
	being_dragged.linear_velocity.z = velocity.z


# ---------------------------
# CURSOR + PLANE
# ---------------------------

func update_cursor():
	var hit_pos = get_mouse_plane_intersection()
	if hit_pos:
		$MeshInstance3D.global_position = hit_pos


func get_mouse_plane_intersection():
	var mouse_pos = get_viewport().get_mouse_position()

	var from = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)

	var plane = Plane(Vector3.UP, drag_height)
	return plane.intersects_ray(from, dir)


# ---------------------------
# INPUT
# ---------------------------

func _input(event):
	if event.is_action_pressed(mouse_click):
		try_start_drag()

	if event.is_action_released(mouse_click):
		stop_drag()


func try_start_drag():
	var mouse_pos = get_viewport().get_mouse_position()

	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length

	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 0xFFFFFFFF # This tells the ray to hit EVERY layer
	var hit = get_world_3d().direct_space_state.intersect_ray(query)

	if hit:
		var body = hit.collider

		if body is RigidBody3D and body.is_in_group("draggable"):
			being_dragged = body
			is_dragging = true

			drag_height = body.global_position.y

			var plane_hit = get_mouse_plane_intersection()
			grab_offset = body.global_position - plane_hit


func stop_drag():
	is_dragging = false

	if being_dragged:
		if use_physics_drag:
			being_dragged.linear_velocity.x = 0
			being_dragged.linear_velocity.z = 0

		being_dragged = null


# ---------------------------
# SIGNAL FRIENDLY SWITCH
# ---------------------------

func set_drag_mode_physics(enabled: bool):
	use_physics_drag = enabled
