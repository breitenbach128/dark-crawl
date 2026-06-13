extends Node3D


@export var player : Player
@export var anim_player : AnimationPlayer
const DIRECTIONS = ["front", "right", "back", "left"]

var velocity : Vector3 = Vector3(0,0,-1) #Forward
var speed : float = 0.001

func _physics_process(delta):
	position+= velocity*speed
	
	if player.camera:
		var camera : Camera3D = player.camera
		# Get the camera's local forward vector in 3D
		var forward3d: Vector3 = -global_transform.basis.z
		# Convert to a 2D vector using the X and Z axes (top-down)
		var dir2d = Vector2(forward3d.x, forward3d.z).normalized()
		# Calculate the angle between the character's movement and the camera's position
		var pos_2d = Vector2(global_position.x,global_position.z)
		var pos_2d_camera = Vector2(camera.global_position.x,camera.global_position.z)
		var angle_to_camera = pos_2d.angle_to_point(pos_2d_camera)
		
		# Map the angle to one of the 8 directions (0 to 7)
		var angle_diff = dir2d.angle() - angle_to_camera
		var sector = wrapi(int(snappedf(angle_diff, PI/2) / (PI/2)), 0, 4)
		
		# Play the corresponding animation (e.g., Walk_Right)
		var anim_name = "idle_" + DIRECTIONS[sector]
		if anim_player.current_animation != anim_name:
			anim_player.play(anim_name)
			anim_player.seek(anim_player.current_animation_position, true)
