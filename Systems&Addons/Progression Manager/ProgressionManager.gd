extends Node

signal state_changed(new_state_id: String)
signal item_burned_recognized(item_id: String, level: int, outcome: Dictionary)
signal item_burned_unrecognized(item_id: String, level: int)

const DATA = preload("res://Core/progression_data.gd")



var current_state_id: String = "night_one_arrival"
var history: Array[String] = []
var flags: Dictionary = {}

# character_id → Node3D
var _characters: Dictionary = {}

@onready var dialog_manager = get_node("/root/DialogueManager")  # adjust to AutoLoad name


func _ready() -> void:
	_connect_systems()

func _connect_systems() -> void:
	# ProgressionManager → AttractionSystem
	item_burned_recognized.connect(AttractionSystem._on_item_burned)
	item_burned_unrecognized.connect(AttractionSystem._on_item_burned_unrecognized)

	# ProgressionManager → SceneOrchestrator
	state_changed.connect(SceneOrchestrator._on_state_changed)

# ── Registration ──────────────────────────────────────────────────────────────

func register_burnable(burnable: Burnable) -> void:
	print("Registered burnable: ", burnable.burnable_id)
	burnable.object_burned.connect(_on_object_burned)
	print(burnable.object_burned.is_connected(_on_object_burned))

func register_character(character: Node3D) -> void:
	print("Registered character: ", character.character_id)
	_characters[character.character_id] = character

func unregister_character(character: Node3D) -> void:
	_characters.erase(character.character_id)

# ── Burn handler ──────────────────────────────────────────────────────────────

func _on_object_burned(burned_object: ObjectLevel, burnable: Burnable) -> void:
	var item_id: String = burnable.burnable_id
	var level: int = burnable.current_level
	var key: String = "%s__lv%d" % [item_id, level]
	var wildcard: String = "%s__lv*" % item_id

	var state: Dictionary = get_state()
	var burns: Dictionary = state.get("burns", {})

	# Exact level match first, then wildcard, then unrecognised
	var outcome: Dictionary = {}
	if burns.has(key):
		outcome = burns[key]
	elif burns.has(wildcard):
		outcome = burns[wildcard]
	else:
		var fallback: Dictionary = state.get("unrecognised_burn", {})
		_play_dialogue(fallback.get("dialogue", []))
		emit_signal("item_burned_unrecognized", item_id, level)
		return

	var req: String = outcome.get("requires", "")
	if req != "" and not flags.get(req, false):
		_play_dialogue(outcome.get("blocked_dialogue", []))
		return

	_apply_effects(outcome.get("effects", {}))
	emit_signal("item_burned_recognized", item_id, level, outcome)
	_play_dialogue(outcome.get("dialogue", []))

	var next: String = outcome.get("next", "")
	if next != "":
		_transition_after_dialogue(next)

# ── Dialogue ──────────────────────────────────────────────────────────────────

func _play_dialogue(lines: Array) -> void:
	print("_play_dialogue called with ", lines.size(), " lines: ", lines)
	if lines.is_empty():
		print("_play_dialogue: empty, returning")
		return
	_play_dialogue_line(lines, 0)

func _play_dialogue_line(lines: Array, index: int) -> void:
	print("_play_dialogue_line index=", index, " / ", lines.size())
	if index >= lines.size():
		print("_play_dialogue_line: done")
		return

	var line: Dictionary = lines[index]
	print("Line dict: ", line)
	var character_id: String = line.get("character", "")
	var text: String = line.get("text", "")
	print("character_id='", character_id, "' text='", text, "'")
	var speaker: Node3D = _characters.get(character_id, null)
	print("speaker: ", speaker, " | registered characters: ", _characters.keys())

	if not speaker:
		push_warning("ProgressionManager: character '%s' not registered" % character_id)
		_play_dialogue_line(lines, index + 1)
		return

	var camera: Camera3D = get_viewport().get_camera_3d()
	print("camera: ", camera)
	print("dialog_manager: ", dialog_manager)
	var typed_lines: Array[String] = [text]
	print("Calling start_dialog on speaker=", speaker, " with lines=", typed_lines)
	dialog_manager.start_dialog(speaker, camera, typed_lines)
	print("Textbox node: ", dialog_manager.textbox)
	print("Textbox position: ", dialog_manager.textbox.position)
	print("Textbox visible: ", dialog_manager.textbox.visible)
	print("start_dialog returned, is_dialogue_active=", dialog_manager.is_dialogue_active)

	if index + 1 < lines.size():
		print("Scheduling next line (index ", index + 1, ")")
		_await_dialogue_then(lines, index + 1)

func _poll_for_next_line(lines: Array, next_index: int) -> void:
	print("_poll_for_next_line: is_dialogue_active=", dialog_manager.is_dialogue_active)
	if dialog_manager.is_dialogue_active:
		_poll_for_next_line.call_deferred(lines, next_index)
		return
	_play_dialogue_line(lines, next_index)

# ── Transition ────────────────────────────────────────────────────────────────

func _await_dialogue_then(lines: Array, next_index: int) -> void:
	dialog_manager.dialogue_finished.connect(
		func(): _play_dialogue_line(lines, next_index),
		CONNECT_ONE_SHOT
	)

func _transition_after_dialogue(next_id: String) -> void:
	dialog_manager.dialogue_finished.connect(
		func(): _transition_to(next_id),
		CONNECT_ONE_SHOT
	)

func _transition_to(next_id: String) -> void:
	print("_transition_to: '", current_state_id, "' → '", next_id, "'")
	if not DATA.TREE.has(next_id):
		push_error("ProgressionManager: unknown state '%s'" % next_id)
		return
	history.append(current_state_id)
	current_state_id = next_id
	print("State changed to: ", current_state_id)
	emit_signal("state_changed", next_id)
# ── Helpers ───────────────────────────────────────────────────────────────────

func _apply_effects(effects: Dictionary) -> void:
	if effects == null or effects.is_empty():
		return
	for key in effects:
		flags[key] = effects[key]

func get_state(id: String = current_state_id) -> Dictionary:
	return DATA.TREE.get(id, {})

func get_current_characters() -> Array:
	return get_state().get("characters", [])

func has_flag(f: String) -> bool:
	return flags.get(f, false)

func has_visited(state_id: String) -> bool:
	return history.has(state_id)
