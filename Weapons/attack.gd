extends RigidBody3D
class_name Attack

var attack_damage
var projectile_speed : float = 0.0
const DIRECTIONS = ["front", "right", "back", "left"]

@export var directional_attack : bool = false

func _physics_process(delta: float) -> void:
	if directional_attack:
		set_direction_anim()

func set_direction_anim():
		var camera : Camera3D = Globals.local_player.camera
		# Get the camera's local forward vector in 3D
		var forward3d: Vector3 = -global_transform.basis.z
		# Convert to a 2D vector using the X and Z axes (top-down)
		var dir2d = Vector2(forward3d.x, forward3d.z).normalized()
		# Calculate the angle between the character's movement and the camera's position
		var pos_2d = Vector2(global_position.x,global_position.z)
		var pos_2d_camera = Vector2(camera.global_position.x,camera.global_position.z)
		var angle_to_camera = pos_2d.angle_to_point(pos_2d_camera)
		
		# Map the angle to one of the 4 directions (0 to 3)
		var angle_diff = dir2d.angle() - angle_to_camera
		var sector = wrapi(int(snappedf(angle_diff, PI/2) / (PI/2)), 0, 4)
		
		# Play the corresponding animation (e.g., Walk_Right)
		var anim_name = "attack_" + DIRECTIONS[sector]
		if $Anim.animation != anim_name:
			$Anim.play(anim_name)
			

func attack(damage):
	attack_damage = damage
	if directional_attack:
		set_direction_anim()
	else:
		$Anim.play("attack")

func _on_body_entered(body: Node) -> void:
	if multiplayer.is_server():
		if body is Enemy:
			#print("Hit Enemy ", attack_damage)
			if body.health_component:
				body.health_component.take_damage(attack_damage)
				$SoundOnHit.play()
		#Check for any hit effects
		for effect: Effect in get_children().filter(func(x): return x is Effect):
			effect.activate_effect()
		#Free
		call_deferred("queue_free")
		
	#Play impact animation	
	

	

	

func _on_anim_animation_finished() -> void:
	#print("Anim finished ", name)
	queue_free()


func _on_lifespan_timeout() -> void:
	#print("Attack Timeout ", name)
	queue_free()
