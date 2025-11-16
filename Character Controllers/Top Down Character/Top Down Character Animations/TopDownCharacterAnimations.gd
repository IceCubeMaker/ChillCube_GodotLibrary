extends AnimatedSprite2D
class_name TopDownCharacterAnimator

var is_dashing = false;

func _ready() -> void:
	get_parent().connect("moving_up", _on_moving_up)
	get_parent().connect("moving_down", _on_moving_down)
	get_parent().connect("moving_left", _on_moving_left)
	get_parent().connect("moving_right", _on_moving_right)
	get_parent().connect("stopped_moving", _on_stopped_moving)
	get_parent().connect("started_dashing", _on_started_dashing)
	get_parent().connect("stopped_dashing", _on_dash_stopped)

func _on_started_dashing(direction_and_speed: Vector2) -> void:
	is_dashing = true;

func _on_dash_stopped():
	is_dashing = false;

func _on_stopped_moving():
	stop()

func _on_moving_up():
	if is_dashing:
		play("dashing_back")
	else:
		play("back")
	flip_h = false

func _on_moving_down():
	if is_dashing:
		play("dashing_front")
	else:
		play("front")
	flip_h = false

func _on_moving_left():
	if is_dashing:
		play("dashing_side")
	else:
		play("side")
	flip_h = false

func _on_moving_right():
	if is_dashing:
		play("dashing_side")
	else:
		play("side")
	flip_h = true
