extends State
class_name StateEnemyAttack

@export var enemy : Enemy


@export var attack_rate_count : float = 0.0
@export var attack_rate_timer : float = 3.0
@export var aggro_range: float = 10.0

var atc: Attack_Component
var use_animtree: bool = true
#general purpose interrupts for states - Common actions
var is_dead : bool = false

func _ready() -> void:
	if enemy:
		enemy.health_component.health_death.connect(func(): is_dead = true)

func attack_animation_loop_complete():
	var target = enemy.find_closest_player_target()
	if target == null:
		Transitioned.emit(self, "StateEnemyWander")	
	if atc && target:
		atc.attack_target(target)

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
			var target = enemy.find_closest_player_target()
			#If there are no player targets, then transition to wander or idle	
			if target == null:
				Transitioned.emit(self, "StateEnemyWander")
			if atc && target:
				atc.attack_target(target)
				
			attack_rate_count = 0


func Physics_Update(_delta : float):
	pass
