extends RigidBody3D
class_name Attack

var attack_damage

func attack(damage):
	attack_damage = damage
	#For multiplayer, I'll eventually need player ID to ensure they get the score
	$Anim.play("attack")

func _on_body_entered(body: Node) -> void:
	if body is Enemy:
		#print("Hit Enemy ", attack_damage)
		if body.health_component:
			body.health_component.take_damage(attack_damage)

	#Play impact animation	
	call_deferred("queue_free")
	
	

func _on_anim_animation_finished() -> void:
	print("Anim finished ", name)
	queue_free()


func _on_lifespan_timeout() -> void:
	print("Attack Timeout ", name)
	queue_free()
