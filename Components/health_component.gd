extends Node3D
class_name Health_Component


@export var health : int = 1
@export var health_max : int = 1
@export var physical_resistance : float = 0.0
@export var fire_resistance : float = 0.0
@export var force_resistance : float = 0.0
@export var shock_resistance : float = 0.0
@export var cold_resistance : float = 0.0
@export var soul_resistance : float = 0.0

@export var vi_bloodsplatter : Node3D


signal health_changed
signal health_death

func _ready() -> void:
	pass


func take_damage(damage_number):	
	print("HC Taking damage")
	health = health - damage_number
	var ui_effect_damage_number : Damage_Number = load("res://UIEffects/damage_number.tscn").instantiate()
	get_tree().current_scene.uieffects_root.add_child(ui_effect_damage_number)
	ui_effect_damage_number.global_position = global_position
	ui_effect_damage_number.text_label.text = str(damage_number)
	
	var bloodsplatter : GPUParticles3D = vi_bloodsplatter.get_node("GPUParticles3D")
	bloodsplatter.restart()
	
	if health <= 0:
		death()
		
func death():
	health_death.emit()
	queue_free()
