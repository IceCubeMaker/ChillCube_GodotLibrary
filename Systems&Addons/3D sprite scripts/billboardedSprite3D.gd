extends Sprite3D
class_name BillboardedSprite3D

@export var camera : Camera3D;
@export var billboard_x : bool = true;
@export var billboard_y : bool = true;
@export var billboard_z : bool = true;

func _process(delta: float) -> void:
	pass

func _face_camera_x(delta: float, sprite: Sprite3D, camera: Camera3D, lerp_speed: float = 10.0):
	sprite.rotation.x = lerp_angle(sprite.rotation.x, camera.global_rotation.x, delta * lerp_speed)
