extends RigidBody3D
class_name Bullet

@export var bullet_damage : int = 1


func _on_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node) -> void:
	if body is Enemy:
		print("Hit Enemy")
		if body.health_component:
			body.health_component.take_damage(bullet_damage)
			call_deferred("queue_free")
