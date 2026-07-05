extends State
class_name StateEnemyAttack

@export var enemy : Enemy


@export var attack_rate_count : float = 0.0
@export var attack_rate_timer : float = 3.0
@export var aggro_range: float = 10.0
@export var turn_speed: float = 5.0

var atc: Attack_Component
var use_animtree: bool = true
#general purpose interrupts for states - Common actions
var is_dead : bool = false
var target

func _ready() -> void:
	if enemy:
		enemy.health_component.health_death.connect(func(): is_dead = true)

func attack_animation_loop_complete():	
	target = enemy.find_closest_player_target()	
	if target == null:
		Transitioned.emit(self, "StateEnemyWander")	
		return
	if atc && target:
		atc.attack_target(target)
		return

func Enter():
	#print("Enter State, StateEnemyAttack")
	enemy.velocity = Vector3(0,0,0) #Stop Moving
	#Setup Attack Component for easy reference
	atc = enemy.attack_component
	#Use animation tree for attack timing. If no Anim Tree, then use the set values
	if enemy.animation_tree:
		enemy.behavior = "Attack"
	else:
		use_animtree = false
	#Find any target
	target = enemy.find_closest_player_target()	
	
func Update(delta: float):
	#Is Dead?
	if is_dead:
		Transitioned.emit(self, "StateEnemyDeath")

	#Do manual timer if there is no animation
	if !use_animtree:
		if attack_rate_count < attack_rate_timer:
			attack_rate_count += delta
		else:
			#Look to do something else
			target = enemy.find_closest_player_target()
			#If there are no player targets, then transition to wander or idle	
			if target == null:
				Transitioned.emit(self, "StateEnemyWander")
			if atc && target:
				atc.attack_target(target)
				
			attack_rate_count = 0
			
	if target:
		#need to just rotate to the target 
		enemy.mesh.look_at(target.global_position, Vector3.UP)
		enemy.mesh.rotation.x = 0.0
		enemy.mesh.rotation.z = 0.0
		#var dir_2d_to_target = Vector2(enemy.global_position.x,enemy.global_position.z) - Vector2(target.global_position.x,target.global_position.z)
		#var angle_2d_to_target = dir_2d_to_target.angle()
		#print(angle_2d_to_target, " ", enemy.mesh.rotation.y)
		#enemy.mesh.rotation.y = angle_2d_to_target
		
func Physics_Update(_delta : float):
	pass
