@tool
extends Sprite2D
class_name SmoothButton

@onready var smooth_mover_scene = preload("res://Systems&Addons/Essentials/SmoothMovement/smooth_movement.tscn")
var mover : Node 

# --- Text Logic ---
enum TextPosition { CENTER, TOP, BOTTOM, LEFT, RIGHT }
var _label : Label

# --- Static Controller Logic ---
static var focused_button : SmoothButton = null

# --- Internal Lerp Logic ---
var _visual_tween : Tween

@export_group("Text Settings")
@export var button_text : String = "Button":
	set(val):
		button_text = val
		if _label: _label.text = val
@export var text_position : TextPosition = TextPosition.CENTER:
	set(val):
		text_position = val
		_update_label_position()
@export var text_offset : float = 10.0:
	set(val):
		text_offset = val
		_update_label_position()
@export var label_settings : LabelSettings:
	set(val):
		label_settings = val
		if _label: _label.label_settings = val

@export_group("Textures")
@export var spr_button_not_pressed : Texture2D:
	set(val):
		spr_button_not_pressed = val
		texture = val 
		_update_label_position()
@export var spr_button_pressed : Texture2D

@export_group("Controller & Selection")
@export var is_selected : bool = false:
	set(val):
		if val == true and button_hidden: return
		if is_selected == val: return 
		is_selected = val
		
		if is_selected:
			if focused_button and focused_button != self:
				focused_button.is_selected = false
			focused_button = self
		else:
			_silent_unpress()
			if focused_button == self:
				focused_button = null
			
		_handle_selection_visuals()

@export var selected_scale : float = 1.1
@export var selected_color : Color = Color(1.2, 1.2, 1.2, 1.0)
@export var lerp_time : float = 0.15

@export_group("Adaptive Positioning")
var anchor_point : Vector2 = Vector2(0.5, 0.5):
	set(val):
		anchor_point = val
		_update_anchor_position()

@export var _position : Vector2 = Vector2.ZERO:
	set(val):
		_position = val
		_update_anchor_position()

@export var _off_screen_position : Vector2 = Vector2(0.0, 0.6):
	set(val):
		_off_screen_position = val
		_update_anchor_position()

@export var button_hidden : bool = false:
	set(val):
		button_hidden = val
		if button_hidden and is_selected:
			is_selected = false

@export_group("Movement Settings")
@export var bounce : bool = false
@export var rotation_on : bool = false
@export var speed : float = 10

var original_position : Vector2
var current_off_screen_pixels : Vector2
var _base_label_pos : Vector2 # Stores the "rest" position of the label

signal button_pressed
signal button_released

func _ready() -> void:
	_setup_label()
	_update_anchor_position()
	add_to_group("smooth_buttons")
	
	if Engine.is_editor_hint(): return 
	
	get_tree().get_root().size_changed.connect(_update_anchor_position)
	if spr_button_not_pressed: texture = spr_button_not_pressed
	_area2D_creation()
	
	mover = smooth_mover_scene.instantiate()
	add_child(mover)
	mover.set("bounce", bounce)
	mover.set("rotation_on", rotation_on)
	mover.set("speed", speed)

func _setup_label() -> void:
	if not _label:
		_label = Label.new()
		add_child(_label)
	
	_label.text = button_text
	if label_settings:
		_label.label_settings = label_settings
	
	_update_label_position()

func _update_label_position() -> void:
	if not _label or not texture: return
	
	var half_size = texture.get_size() / 2.0
	_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_label.grow_vertical = Control.GROW_DIRECTION_BOTH
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	var target_center = Vector2.ZERO
	
	match text_position:
		TextPosition.CENTER:
			target_center = Vector2.ZERO
		TextPosition.TOP:
			target_center = Vector2(0, -half_size.y - text_offset)
			_label.grow_vertical = Control.GROW_DIRECTION_BEGIN
		TextPosition.BOTTOM:
			target_center = Vector2(0, half_size.y + text_offset)
			_label.grow_vertical = Control.GROW_DIRECTION_END
		TextPosition.LEFT:
			target_center = Vector2(-half_size.x - text_offset, 0)
			_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			_label.grow_horizontal = Control.GROW_DIRECTION_BEGIN
		TextPosition.RIGHT:
			target_center = Vector2(half_size.x + text_offset, 0)
			_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			_label.grow_horizontal = Control.GROW_DIRECTION_END
	
	# Calculate the position relative to Sprite (0,0)
	match text_position:
		TextPosition.CENTER: _base_label_pos = target_center - (_label.size / 2.0)
		TextPosition.LEFT: _base_label_pos = target_center - Vector2(_label.size.x, _label.size.y / 2.0)
		TextPosition.RIGHT: _base_label_pos = target_center - Vector2(0, _label.size.y / 2.0)
		TextPosition.TOP: _base_label_pos = target_center - Vector2(_label.size.x / 2.0, _label.size.y)
		TextPosition.BOTTOM: _base_label_pos = target_center - Vector2(_label.size.x / 2.0, 0)
	
	_label.position = _base_label_pos

func _handle_selection_visuals() -> void:
	if _visual_tween: _visual_tween.kill()
	_visual_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	var target_scale_val = selected_scale if is_selected else 1.0
	var target_scale = Vector2.ONE * target_scale_val
	var target_color = selected_color if is_selected else Color.WHITE
	
	_visual_tween.tween_property(self, "scale", target_scale, lerp_time)
	_visual_tween.tween_property(self, "self_modulate", target_color, lerp_time)
	
	if _label:
		if text_position != TextPosition.CENTER:
			# 1. Keep text size constant
			_visual_tween.tween_property(_label, "scale", Vector2.ONE / target_scale, lerp_time)
			# 2. Counter-act the parent scale so the position remains fixed in global space
			# Since child_pos * parent_scale = global_pos, we set child_pos to base_pos / target_scale
			_visual_tween.tween_property(_label, "position", _base_label_pos / target_scale_val, lerp_time)
		else:
			# If centered, let it scale and stay at (0,0) relative center
			_visual_tween.tween_property(_label, "scale", Vector2.ONE, lerp_time)
			_visual_tween.tween_property(_label, "position", _base_label_pos, lerp_time)

# --- Remaining Logic (Navigation, Input, etc. remains same) ---

func _process(_delta: float) -> void:
	var target = original_position
	if button_hidden: target = original_position + current_off_screen_pixels
	if Engine.is_editor_hint():
		global_position = target
		if not _label: _setup_label()
		_update_label_position()
		return
	if mover: mover.set("global_target_position", target)
	if focused_button == null: _check_for_initial_navigation()
	if is_selected and not button_hidden: _handle_controller_input()

func _check_for_initial_navigation() -> void:
	if _get_dpad_direction() != Vector2.ZERO:
		var buttons = get_tree().get_nodes_in_group("smooth_buttons")
		for b in buttons:
			if b is SmoothButton and not b.button_hidden:
				b.is_selected = true
				return

func _handle_controller_input() -> void:
	if Input.is_action_just_pressed("ui_accept"): _press_button()
	if Input.is_action_just_released("ui_accept"):
		if texture == spr_button_pressed: _release_button()
	var d_pad_dir = _get_dpad_direction()
	if d_pad_dir != Vector2.ZERO: _navigate_to_closest(d_pad_dir)

func _get_dpad_direction() -> Vector2:
	var dir = Vector2.ZERO
	if Input.is_action_just_pressed("ui_up"): dir = Vector2.UP
	elif Input.is_action_just_pressed("ui_down"): dir = Vector2.DOWN
	elif Input.is_action_just_pressed("ui_left"): dir = Vector2.LEFT
	elif Input.is_action_just_pressed("ui_right"): dir = Vector2.RIGHT
	return dir

func _navigate_to_closest(dir: Vector2) -> void:
	var buttons = get_tree().get_nodes_in_group("smooth_buttons")
	if buttons.size() <= 1:
		return
	var best_candidate : SmoothButton = null
	var min_score = INF
	for b in buttons:
		if b == self or b.button_hidden or not b is SmoothButton: 
			continue
		var vector_to_next = b.global_position - self.global_position
		var distance = vector_to_next.length()
		var dot = vector_to_next.normalized().dot(dir)
		if dot > 0.0:
			var score = distance / (dot + 0.1) 
			if score < min_score:
				min_score = score
				best_candidate = b
	if best_candidate:
		self.is_selected = false
		best_candidate.is_selected = true

func _press_button() -> void:
	button_pressed.emit()
	texture = spr_button_pressed

func _release_button() -> void:
	button_released.emit()
	texture = spr_button_not_pressed

func _silent_unpress() -> void:
	if texture == spr_button_pressed: texture = spr_button_not_pressed

func _update_anchor_position() -> void:
	var viewport_size = get_viewport_rect().size
	if viewport_size == Vector2.ZERO: return
	original_position = (viewport_size * anchor_point) + (viewport_size * _position)
	current_off_screen_pixels = viewport_size * _off_screen_position
func _area2D_creation() -> void:
	if Engine.is_editor_hint(): return
	var area = Area2D.new()
	area.input_pickable = true 
	add_child(area)
	var collision_shape = CollisionShape2D.new()
	area.add_child(collision_shape)
	var rect = RectangleShape2D.new()
	if texture:
		rect.size = texture.get_size()
		collision_shape.shape = rect
		area.input_event.connect(_on_area_2d_input_event)
		area.mouse_exited.connect(_on_mouse_exited)
		area.mouse_entered.connect(func(): if not button_hidden: is_selected = true)

func _on_mouse_exited() -> void:
	is_selected = false 

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed: _press_button()
		else: if texture == spr_button_pressed: _release_button()
