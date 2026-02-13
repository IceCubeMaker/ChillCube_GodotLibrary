extends Node3D
class_name Cursor3D

## Reference to the camera used to project mouse rays into 3D space
@export var camera: Camera3D


# ============================
# DRAG STATE (EXPORTED FOR DEBUGGING IN EDITOR)
# ============================

@export_group("INPUT")
@export var mouse_click := "left_click"

@export_group("STATE EXPORTS")

## True while an object is currently being dragged
@export var is_dragging := false

## The rigidbody currently being dragged
@export var being_dragged: RigidBody3D

## The Y height of the horizontal dragging plane (usually the object's height when drag started)
@export var drag_height := 0.0

## Offset between mouse hit point and object's center. Prevents snapping the object to cursor center
@export var grab_offset := Vector3.ZERO


# ============================
# BUGS PREVENTION
# ============================

func _ready() -> void:
	# Check for a child named "OmniLight3D"
	assert(has_node("MeshInstance3D"), "ERROR: Draggeable Mouse Objects need a MeshInstance3D! It needs to be named 'MeshInstance3D'")

# ============================
# MAIN LOOP
# ============================

func _process(delta):
	# Update the visual 3D cursor position every frame
	update_cursor()

	# If dragging an object, move it along the horizontal plane
	if is_dragging and being_dragged:
		var hit_pos = get_mouse_plane_intersection()

		if hit_pos:
			# Desired position on the plane + grab offset
			var target = hit_pos + grab_offset

			# Get current object position
			var pos = being_dragged.global_position

			# Move only on X and Z (horizontal)
			pos.x = target.x
			pos.z = target.z

			# Apply new position (snap-style dragging)
			being_dragged.global_position = pos


# ============================
# CURSOR UPDATE
# ============================

## Update the visual 3D cursor position every frame
func update_cursor():
	# Find where the mouse ray hits the dragging plane
	var hit_pos = get_mouse_plane_intersection()

	# Move the visual cursor mesh to that position
	if hit_pos:
		$MeshInstance3D.global_position = hit_pos


# ============================
# MOUSE → PLANE INTERSECTION
# ============================

func get_mouse_plane_intersection() -> Vector3:
	# Current mouse position in viewport space
	var mouse_pos = get_viewport().get_mouse_position()

	# Ray origin from camera
	var from = camera.project_ray_origin(mouse_pos)

	# Ray direction from camera
	var dir = camera.project_ray_normal(mouse_pos)

	# Create an infinite horizontal plane at drag_height (Y axis)
	var plane = Plane(Vector3.UP, drag_height)

	# Calculate ray intersection with the plane
	var hit = plane.intersects_ray(from, dir)

	# If ray hit the plane, return world position
	if hit != null:
		return hit

	# Otherwise return zero vector (no hit)
	return Vector3(0,0,0)


# ============================
# INPUT HANDLING
# ============================

func _input(event):
	# Start dragging when left click pressed
	if event.is_action_pressed(mouse_click):
		try_start_drag()

	# Stop dragging when left click released
	if event.is_action_released(mouse_click):
		stop_drag()


# ============================
# TRY TO BEGIN DRAGGING
# ============================

func try_start_drag():
	# Mouse screen position
	var mouse_pos = get_viewport().get_mouse_position()

	# Build a ray from camera through mouse
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000

	# Physics raycast query
	var query = PhysicsRayQueryParameters3D.create(from, to)

	# Perform raycast in world
	var result = get_world_3d().direct_space_state.intersect_ray(query)

	# If something was hit
	if result:
		var body = result.collider

		# Only drag rigidbodies in "draggable" group
		if body is RigidBody3D and body.is_in_group("draggable"):
			
			# Store dragged body
			being_dragged = body
			is_dragging = true

			# Set plane height to object's current Y
			drag_height = body.global_position.y

			# Find mouse hit point on plane
			var hit_pos = get_mouse_plane_intersection()

			# Store offset so object doesn't snap to cursor
			grab_offset = body.global_position - hit_pos


# ============================
# STOP DRAGGING
# ============================

func stop_drag():
	# Clear dragging state
	is_dragging = false
	being_dragged = null
