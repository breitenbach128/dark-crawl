extends RigidBody3D
class_name Attack

@export var damage : int = 1

func _on_timer_timeout() -> void:
	queue_free()

func attack(attack_damage):
	#For multiplayer, I'll eventually need player ID to ensure they get the score
	$Anim.play("attack")

func _on_body_entered(body: Node) -> void:
	if body is Enemy:
		print("Hit Enemy")
		if body.health_component:
			body.health_component.take_damage(damage)
			call_deferred("queue_free")
