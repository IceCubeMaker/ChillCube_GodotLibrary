extends Resource
class_name SpriteAnimations3D

## This is a collection of function used for animating sprites

static func speechwobble(delta: float, sprite : Sprite3D, is_moving: bool, target_scale : float, squash : float):
	var time = Time.get_ticks_msec() * 0.001
	
	if is_moving:
		# Using abs(sin) creates a rhythmic "stepping" motion
		var bounce = abs(sin(time * 20.0)) 
		
		sprite.scale.y = lerp(sprite.scale.y, target_scale - (bounce * squash), delta * 20)
		sprite.scale.x = lerp(sprite.scale.x, target_scale + (bounce * squash), delta * 20)
		
	else:
		# Smoothly brings the sprite back to its original shape when stopped
		sprite.scale = sprite.scale.lerp(Vector3(target_scale, target_scale, target_scale), delta * 10.0)

static func idle_sway(delta: float, sprite: Sprite3D, camera: Camera3D, is_idle: bool = true, max_rotation_deg: float = 5, speed: float = 0.5):
	var time = Time.get_ticks_msec() * 0.001
	
	if is_idle and camera:
		# This prevents the "sway" from looking skewed if the camera turns
		sprite.rotation.y = lerp_angle(sprite.rotation.y, camera.rotation.y, delta * 10.0)

		# Calculate the sway (sin wave)
		var sway_rad = sin(time * speed) * deg_to_rad(max_rotation_deg)
		
		# Apply the sway to the Z axis (the "roll" relative to the camera view)
		sprite.rotation.z = lerp(sprite.rotation.z, sway_rad, delta * 2.0)
		
		# Vertical bobbing
		var bob = abs(sin(time * speed * 2.0)) * 0.1
		sprite.position.y = lerp(sprite.position.y, bob, delta * 5.0)
		
	else:
		# Smoothly return to neutral
		sprite.rotation.z = lerp(sprite.rotation.z, 0.0, delta * 5.0)
		sprite.position.y = lerp(sprite.position.y, 0.0, delta * 5.0)
