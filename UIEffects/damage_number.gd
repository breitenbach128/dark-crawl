extends Node3D
class_name Damage_Number

@export var text_label : Label3D
@export var move_speed : float = 1.0
@export var move_direction : Vector3 = Vector3(0,2,0)

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	position = position + move_direction*delta*move_speed

func _on_timer_timeout() -> void:
	queue_free()
