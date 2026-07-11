extends Node3D

class_name Prop

@export var prop_name : String = "prop"
@export var debris : Resource
@export var reward : Resource
@export var reward_chance : float = 0.00
@export var prop_health : int  = 1




func prop_destroyed():
	var new_debris = debris.instantiate()
	Globals.current_main.visuals_root.add_child(new_debris)
	new_debris.global_position = global_position


func _on_rigid_body_3d_body_entered(body: Node) -> void:
	print("Crate Hit by body: ", body)
	if body is Attack:
		prop_health-= 1
		if prop_health <= 0:
			prop_destroyed()
			queue_free()
