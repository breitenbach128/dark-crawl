extends Node3D

class_name Prop

@export var prop_name : String = "prop"
@export var rigid_body : RigidBody3D
@export var hit_sound : AudioStreamPlayer3D
@export var debris : Resource
@export var reward : Resource
@export var reward_chance : float = 0.00
@export var prop_health : int  = 1


var prev_global_position : Vector3 = Vector3(0,0,0)

func _enter_tree() -> void:
	#Only enable the sync if the game has started and this is added
	if Globals.start_game:
		$MultiplayerSynchronizer.public_visibility = true

func _process(delta: float) -> void:
	prev_global_position = rigid_body.global_position

func spawn_debris():
	if debris:
		var new_debris = debris.instantiate()
		Globals.current_main.visuals_root.add_child(new_debris)
		new_debris.global_position = prev_global_position

func _on_rigid_body_3d_body_entered(body: Node) -> void:
	if hit_sound:
		var speed = rigid_body.linear_velocity.length()	
		print("Name:", name, "Hit body: ", body, "at speed: ", speed )	
		if speed > 1.0:
			hit_sound.play()
	

func _on_area_3d_body_entered(body: Node3D) -> void:	
	if multiplayer.is_server():
		if body is Attack:
			prop_health-= 1
			if prop_health <= 0:
				spawn_debris()
				call_deferred("queue_free")
