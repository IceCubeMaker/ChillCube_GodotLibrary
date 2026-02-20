extends Node

# Map character_id → their .tscn resource
@export var character_scenes : Dictionary = {}
# Map character_id → seat position (Vector3) around the fire
@export var seat_positions : Dictionary = {}

# Spawn offset distance outside camera view
@export var spawn_distance : float = 8.0

var _active_npcs : Dictionary = {}  # character_id → Npc3D instance
var _camera : Camera3D

func _ready() -> void:
	_camera = get_viewport().get_camera_3d()
	# Don't connect here — ProgressionManager._connect_systems() handles it
	# But DO trigger the initial state load after all systems are ready
	call_deferred("_load_scene_for_state", ProgressionManager.current_state_id)
# ── State change ──────────────────────────────────────────────────────────────

func _on_state_changed(new_state_id: String) -> void:
	var state : Dictionary = ProgressionManager.get_state(new_state_id)
	if state.get("type", "") == "terminal":
		_dismiss_all()
		return
	_load_scene_for_state(new_state_id)

func _load_scene_for_state(state_id: String) -> void:
	var state : Dictionary = ProgressionManager.get_state(state_id)

	# Characters explicitly required by the tree state always spawn
	var required : Array = state.get("characters", [])

	# Probabilistic candidates on top of required
	var candidates : Array = AttractionSystem.roll_spawns()

	# Merge, dedup
	var needed : Array = required.duplicate()
	for id in candidates:
		if id not in needed:
			needed.append(id)

	var to_dismiss : Array = _active_npcs.keys().filter(func(id): return id not in needed)
	var to_spawn   : Array = needed.filter(func(id): return id not in _active_npcs)

	for id in to_dismiss:
		_dismiss_character(id)
	for id in to_spawn:
		_spawn_character(id)

func is_character_active(character_id: String) -> bool:
	return _active_npcs.has(character_id)

# ── Spawn ─────────────────────────────────────────────────────────────────────

func _spawn_character(character_id: String) -> void:
	if not character_scenes.has(character_id):
		push_error("SceneOrchestrator: no scene registered for '%s'" % character_id)
		return

	var scene : PackedScene = character_scenes[character_id]
	var npc : Npc3D = scene.instantiate()
	get_tree().root.add_child(npc)

	# Place just outside camera view
	npc.global_position = _offscreen_spawn_point()
	_active_npcs[character_id] = npc

	# Walk to seat, then become idle
	var seat : Vector3 = seat_positions.get(character_id, Vector3.ZERO)
	npc.walk_to(seat)
	await npc.arrived
	print("SceneOrchestrator: '%s' arrived at seat" % character_id)

func _offscreen_spawn_point() -> Vector3:
	if _camera == null:
		_camera = get_viewport().get_camera_3d()
	# Pick a random angle and push out spawn_distance units from the camera on XZ
	var angle : float = randf() * TAU
	var offset : Vector3 = Vector3(cos(angle), 0.0, sin(angle)) * spawn_distance
	# Spawn at camera XZ position offset, grounded at Y=0
	return Vector3(_camera.global_position.x + offset.x, 0.0, _camera.global_position.z + offset.z)

# ── Dismiss ───────────────────────────────────────────────────────────────────

func _dismiss_character(character_id: String) -> void:
	if not _active_npcs.has(character_id):
		return
	var npc : Npc3D = _active_npcs[character_id]
	_active_npcs.erase(character_id)
	ProgressionManager.unregister_character(npc)

	# Walk offscreen then free
	var exit : Vector3 = _offscreen_spawn_point()
	npc.walk_to(exit)
	await npc.arrived
	npc.queue_free()

func _dismiss_all() -> void:
	for id in _active_npcs.keys():
		_dismiss_character(id)
