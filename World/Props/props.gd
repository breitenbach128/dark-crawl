extends Node3D

class_name Prop

@export var prop_name : String = "prop"
@export var debris : Resource
@export var reward : Resource
@export var reward_chance : float = 0.00
@export var prop_health : int  = 1


func _enter_tree() -> void:
	#Only enable the sync if the game has started and this is added
	if Globals.start_game:
		$MultiplayerSynchronizer.public_visibility = true

func prop_destroyed():
	var new_debris = debris.instantiate()
	Globals.current_main.visuals_root.add_child(new_debris)
	new_debris.global_position = global_position


func _on_rigid_body_3d_body_entered(body: Node) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:	
	if body is Attack:
		prop_health-= 1
		if prop_health <= 0:
			prop_destroyed()
			if multiplayer.is_server():
				queue_free()
