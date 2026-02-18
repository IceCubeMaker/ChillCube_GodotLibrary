extends Node3D

@export var camera : Camera3D
@export var static_sprite : Sprite2D
@export var animated_sprite : AnimatedSprite2D

var is_dragging = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var sprite_pos = camera.unproject_position(self.position)
	static_sprite.position = sprite_pos
	animated_sprite.position = sprite_pos
	
	#if Input.is_action_just_pressed("left_click"):
		#is_dragging = true
		#animated_sprite.frame = 0
		#animated_sprite.play("start_drag")
	#if animated_sprite.animation == "start_drag" and animated_sprite.frame == 11 and is_dragging:
		#animated_sprite.play("drag_loop")
	#
	#if Input.is_action_just_released("left_click") and is_dragging:
		#animated_sprite.play("drag_end")
		#pass
	pass
