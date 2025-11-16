extends CharacterBody2D
class_name VehicleBody2D

signal moving(direction_and_speed : Vector2)
signal started_dashing(direction_and_speed : Vector2)
signal used_a_dash(dashes_left : int, dashes_used : int, max_dashes : int)
signal stopped_dashing

signal moving_up
signal moving_backward
signal moving_left
signal moving_forward

signal stopped_moving

signal knocked_back(direction : Vector2 , strength : float)
signal knockback_stopped

@export var speed : float = 250;
@export var max_speed : float = 1000;
@export_range(0, 1) var acceleration : float = 1;
@export_range(0, 1) var deceleration : float = 0.1

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
@export var input_backward : String = "ui_down"
@export var input_forward : String = "ui_up"

@export_group("Controller")
@export var deadzone : float = 0.1

var current_speed : float = 0;
var acceleration_vector : Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:

	var input_vector : Vector2 = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength(input_right) - Input.get_action_strength(input_left)
	var forward = Input.get_action_strength(input_forward)
	var backward = Input.get_action_strength(input_backward)
	
	current_speed = min(current_speed + forward * speed, max_speed)
	current_speed = max(current_speed - backward * speed * 0.1, -max_speed * 0.5)
	if current_speed > 0:
		current_speed -= speed*0.05
	else:
		current_speed += speed*0.05
	rotation += input_vector.x * 0.00005 * current_speed
	velocity = Vector2.from_angle(rotation) * current_speed
	
	move_and_slide()
