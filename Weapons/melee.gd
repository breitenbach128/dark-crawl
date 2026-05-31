extends Attack
class_name Melee

@export var melee_damage : int = 1


func _on_timer_timeout() -> void:
	queue_free()

func attack():
	$Anim.play("attack")

func _on_body_entered(body: Node) -> void:
	if body is Enemy:
		print("Hit Enemy")
		if body.health_component:
			body.health_component.take_damage(melee_damage)
			call_deferred("queue_free")


func _on_anim_animation_finished() -> void:
	$Timer.start()
