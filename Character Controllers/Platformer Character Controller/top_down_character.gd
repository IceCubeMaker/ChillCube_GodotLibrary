extends CharacterBody2D
class_name PlatformerCharacter

signal moving(direction_and_speed : Vector2)
signal started_dashing(direction_and_speed : Vector2)
signal used_a_dash(dashes_left : int, dashes_used : int, max_dashes : int)
signal stopped_dashing

signal jumping
signal moving_down
signal moving_left
signal moving_right

signal touching_floor
signal stopped_moving

signal knocked_back(direction : Vector2 , strength : float)
signal knockback_stopped

@export var speed : float = 200;
@export var down_speed : float = 500;
@export_range(0, 1) var acceleration : float = 1;
@export_range(0, 1) var deceleration : float = 0.1
@export var gravity : float = 300

@export_group("Jumping")
@export var max_jumps : int = 1;
var jumps_used : int = 0;
@export var jump_strength : float = 5.5;
@export var koyote_time : float = 0.3;
var koyote_timer : SceneTreeTimer = null;

@export_group("Dash")
@export var enable_dashing : bool = true;
@export var dash_speed : float = 5;
@export var dash_time : float = 0.5;
@export_range(0, 1) var dash_falloff : float = 0.3
@export var dash_timeout : float = 0.5;
@export var dashes : int = 1;
var dashes_used : int = 0;
var dash_vector : Vector2 = Vector2.ZERO
@onready var dash_timer : SceneTreeTimer = get_tree().create_timer(0);
@onready var dash_timeout_timer : SceneTreeTimer = get_tree().create_timer(0);

@export_group("Knockback")
@export var enable_knockback : bool = true;
@export var knockback_speed : float = 5;
@export var knockback_time : float = 0.5;
@export_range(0, 1) var knockback_falloff : float = 0.3
var knockback_vector : Vector2 = Vector2.ZERO
@onready var knockback_timer : SceneTreeTimer = get_tree().create_timer(0);

@export_category("Controls")
@export var input_dash : String = "dash"

@export_group("Keyboard")
@export var input_left : String = "ui_left"
@export var input_right : String = "ui_right"
@export var input_down : String = "ui_down"
@export var input_jump : String = "ui_up"

@export_group("Controller")
@export var deadzone : float = 0.1

var acceleration_vector : Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	var max_speed = speed
	
	#region GET DIRECTIONAL INPUTS

	var input_vector : Vector2 = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength(input_right) - Input.get_action_strength(input_left)
	
	var joy_stick_strength : Vector2 = Vector2(Input.get_joy_axis(0, JOY_AXIS_LEFT_X), Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
	if joy_stick_strength.length() > deadzone:
		input_vector = Vector2(joy_stick_strength.x, 0);

	input_vector = input_vector.normalized()

#endregion
	
	#region DASH
	if enable_dashing:
		if Input.is_action_just_pressed(input_dash):
			if dash_timeout_timer.time_left < 0.1:
				dashes_used = 0;
			if dashes_used < dashes:
				emit_signal("started_dashing", input_vector)
				emit_signal("used_a_dash", dashes - dashes_used, dashes_used, dashes)
				dash_vector = (input_vector * dash_speed *200);
				dash_timer = get_tree().create_timer(dash_time)
				dash_timeout_timer = get_tree().create_timer(dash_timeout)
				dashes_used += 1;
		if dash_timer.time_left < 0.01:
			dash_vector += (Vector2(0,0) - dash_vector) * dash_falloff
			if dash_vector.length() < 1:
				emit_signal("stopped_dashing")

	#endregion
	
	var max_speed_vector = input_vector * max_speed 
	var deceleration_vector = (Vector2.ZERO - Vector2(velocity.x, 0)) * deceleration
	var acceleration_vector : Vector2 = Vector2(0,0);
	if input_vector.x > 0:
		acceleration_vector.x = ((max_speed_vector.x - velocity.x) * acceleration) + (input_vector.x * deceleration_vector.length())
	elif input_vector.x < 0:
		acceleration_vector.x = ((max_speed_vector.x - velocity.x) * acceleration) + (input_vector.x * deceleration_vector.length())
	else:
		acceleration_vector = Vector2.ZERO
		if velocity.length() < max_speed * 0.1:
			emit_signal("stopped_moving")
	velocity += (acceleration_vector + deceleration_vector) * delta * 10;
	velocity.y += gravity * delta
	if Input.is_action_just_pressed(input_down):
		velocity.y += down_speed * delta * 100;
	var can_jump : bool = false;
	
	# Check if jumping is possible (with koyote time)
	if is_on_floor():
		emit_signal("touching_floor")
		jumps_used = 0;
		can_jump = true;
	else:
		#check for koyote time
		if koyote_timer == null:
			koyote_timer = get_tree().create_timer(koyote_time);
			koyote_timer.connect("timeout", _on_koyote_timeout)
		else:
			can_jump = true;
	# Check for jumping input
	if can_jump and Input.is_action_just_pressed(input_jump) and jumps_used < max_jumps:
		emit_signal("jumping")
		jumps_used += 1;
		velocity.y -= jump_strength *100 * delta
	velocity += dash_vector + knockback_vector * delta
	if velocity.length() > 0.1:
		emit_signal("moving", velocity)
	
	move_and_slide()
	emit_direction()

func _on_koyote_timeout() -> void:
	koyote_timer = null;

## Used to start knockback
func knockback(direction: Vector2, strength : float) -> void:
	emit_signal("knocked_back", direction, strength)
	if enable_knockback:
		knockback_vector = (direction.normalized() * knockback_speed * 200 * strength);
		knockback_timer = get_tree().create_timer(knockback_time)
	if knockback_timer.time_left < 0.01:
		knockback_vector += (Vector2(0,0) - knockback_vector) * knockback_falloff
		if knockback_vector.length() < 0.1:
			emit_signal("knockback_stopped")


func emit_direction() -> void:
	if velocity.length() == 0:
		return

	var angle = velocity.angle()
	
	if angle >= -PI/4 and angle < PI/4:
		emit_signal("moving_right")
	elif angle >= PI/4 and angle < 3 * PI/4:
		emit_signal("moving_down")
	elif angle >= 3 * PI/4 or angle < -3 * PI/4:
		emit_signal("moving_left")
	else: # angle >= -3 * PI/4 and angle < -PI/4
		emit_signal("moving_up")
