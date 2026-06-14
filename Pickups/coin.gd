extends Node3D
class_name Coin


var rise_speed : float = 0.35
var rise_time : float = 2.0

func _process(delta: float) -> void:	
	if rise_time > 0:
		position += Vector3(0,1,0) * (rise_speed * delta)
		rise_time-=delta

func _on_area_3d_body_entered(body: Node3D) -> void:	
	if body is Player:
		body.collect_coin(1)
		$PickupSound.play()


func _on_pickup_sound_finished() -> void:	
	queue_free()
