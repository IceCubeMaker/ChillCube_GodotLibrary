extends Node

# character_id → CharacterProfile
var _profiles : Dictionary = {}

# character_id → current spawn probability (0.0 - 1.0)
var _probabilities : Dictionary = {}

# Elapsed game time in seconds
var _elapsed_time : float = 0.0

func _ready() -> void:
	pass  # Connected by ProgressionManager._connect_systems()

func _process(delta: float) -> void:
	_elapsed_time += delta
	_decay_probabilities(delta)

# ── Registration ──────────────────────────────────────────────────────────────

func register_profile(profile: CharacterProfile) -> void:
	_profiles[profile.character_id] = profile
	_probabilities[profile.character_id] = profile.base_probability
	print("AttractionSystem: registered '%s' at p=%.2f" % [profile.character_id, profile.base_probability])

# ── Burn events ───────────────────────────────────────────────────────────────

func _on_item_burned(item_id: String, level: int, outcome: Dictionary) -> void:
	_apply_item_effect(item_id)

func _on_item_burned_unrecognized(item_id: String, level: int) -> void:
	_apply_item_effect(item_id)

func _apply_item_effect(item_id: String) -> void:
	for character_id in _profiles:
		var profile : CharacterProfile = _profiles[character_id]
		if profile.item_affinity.has(item_id):
			_adjust_probability(character_id, profile.item_affinity[item_id])

func _adjust_probability(character_id: String, delta: float) -> void:
	var current : float = _probabilities.get(character_id, 0.0)
	_probabilities[character_id] = clamp(current + delta, 0.0, 1.0)
	print("AttractionSystem: '%s' probability %.2f → %.2f" % [
		character_id, current, _probabilities[character_id]
	])

# ── Decay ─────────────────────────────────────────────────────────────────────

func _decay_probabilities(delta: float) -> void:
	for character_id in _probabilities:
		var profile : CharacterProfile = _profiles[character_id]
		var current : float = _probabilities[character_id]
		# Decay toward base, not toward zero
		var diff : float = current - profile.base_probability
		if abs(diff) > 0.001:
			_probabilities[character_id] = move_toward(
				current,
				profile.base_probability,
				profile.decay_rate * delta
			)

# ── Eligibility ───────────────────────────────────────────────────────────────

func get_eligible_characters() -> Array:
	var depth : int = ProgressionManager.history.size()
	var eligible : Array = []

	for character_id in _profiles:
		var profile : CharacterProfile = _profiles[character_id]

		# Hard requirements first
		if _elapsed_time < profile.min_time:
			continue
		if depth < profile.min_depth:
			continue

		# Already active — don't re-evaluate
		if SceneOrchestrator.is_character_active(character_id):
			continue

		eligible.append({
			"character_id": character_id,
			"probability":  _probabilities[character_id],
		})

	return eligible

func roll_spawns() -> Array:
	# Returns list of character_ids that pass their probability roll
	var spawning : Array = []
	for entry in get_eligible_characters():
		if randf() <= entry["probability"]:
			spawning.append(entry["character_id"])
	return spawning

# ── Queries ───────────────────────────────────────────────────────────────────

func get_probability(character_id: String) -> float:
	return _probabilities.get(character_id, 0.0)
