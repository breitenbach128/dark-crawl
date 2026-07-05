extends Node3D
class_name Attack_Component

enum ATTACK_TYPE {MELEE, RANGED}

@export var enemy: Enemy
@export var attack_list : Array[AttackSelection]
@export var attack_type : ATTACK_TYPE

var current_target

func _ready() -> void:
	pass
	

func attack_target(target : CharacterBody3D):
	current_target = target
	if target:
		#print("Attacking from component")
		var attack_selection : AttackSelection = attack_list.pick_random()
		var new_enemy_attack : EnemyAttack = attack_selection.enemy_attack.instantiate()
		get_tree().current_scene.attacks_root.add_child(new_enemy_attack,true)
		new_enemy_attack.global_position = global_position
		var direction = global_position.direction_to(target.global_position)
		new_enemy_attack.velocity = direction * new_enemy_attack.movement_speed
		new_enemy_attack.look_at(target.global_position, Vector3.UP)
