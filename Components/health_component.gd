extends Node3D
class_name Health_Component


@export var health : int = 1
@export var health_max : int = 1
@export var restistance : Dictionary = {
	"physical": 0.0,
	"fire": 0.0,
	"force": 0.0,
	"shock": 0.0,
	"cold": 0.0,
	"soul": 0.0
}

@export var vi_bloodsplatter : Node3D


signal health_changed
signal health_death


func _ready() -> void:
	pass

func heal(amount: int):
	health=min(health+amount,health_max)
	health_changed.emit(health, health_max, amount)
	print("healed ", amount)	

func take_damage(attack_damage):

	var physical_damage = ceil((1-restistance.physical) * randi_range(attack_damage.physical[0],attack_damage.physical[1]))
	var fire_damage = ceil((1-restistance.fire) * randi_range(attack_damage.fire[0],attack_damage.fire[1]))
	var shock_damage = ceil((1-restistance.shock) * randi_range(attack_damage.shock[0],attack_damage.shock[1]))
	var force_damage = ceil((1-restistance.force) * randi_range(attack_damage.force[0],attack_damage.force[1]))
	var cold_damage = ceil((1-restistance.cold) * randi_range(attack_damage.cold[0],attack_damage.cold[1]))
	var soul_damage = ceil((1-restistance.soul) * randi_range(attack_damage.soul[0],attack_damage.soul[1]))
	
	var damage_number = physical_damage+fire_damage+shock_damage+force_damage+cold_damage+soul_damage
	#print("HC Taking damage ", attack_damage)
	health = health - damage_number
	var ui_effect_damage_number : Damage_Number = load("res://UIEffects/damage_number.tscn").instantiate()
	get_tree().current_scene.uieffects_root.add_child(ui_effect_damage_number)
	ui_effect_damage_number.global_position = global_position
	ui_effect_damage_number.text_label.text = str(damage_number)
	
	var bloodsplatter : GPUParticles3D = vi_bloodsplatter.get_node("GPUParticles3D")
	bloodsplatter.restart()
	
	health_changed.emit(health, health_max, -damage_number)
	
	if health <= 0:
		death()
		
func death():
	health_death.emit()
	
	if get_parent() is Player:
		print("GAME OVER")
		#Switch to dead state, removing you from being targeted by enemies but allowing you
		#be revived by other players.
		#If all players are dead, go to MISSION failed screen to exit or restart
