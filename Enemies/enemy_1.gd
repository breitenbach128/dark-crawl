extends CharacterBody3D

class_name Enemy


@export var enemy_name : String = "Enemy"

@export var health_component : Health_Component

var death_sound_index = 0


func _ready() -> void:
	if health_component:
		health_component.health_death.connect(death)

func death():
	SoundManager.play_monster_sound(death_sound_index)
	queue_free()
