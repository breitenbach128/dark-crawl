extends State
class_name StateEnemyAttack

@export var enemy : Enemy


@export var attack_rate_count : float = 0.0
@export var attack_rate_timer : float = 3.0
@export var aggro_range: float = 10.0

func Enter():
	print("Enter State, StateEnemyAttack")

func Update(delta: float):
	if attack_rate_count < attack_rate_timer:
		attack_rate_count += delta
	else:
		#Look to do something else
		var players = get_tree().get_nodes_in_group("Player")
		if players.size() == 0:
			#can check aggro distance and LOS later
			Transitioned.emit(self, "StateEnemyWander")
		
		if enemy.attack_component:
			var atc : Attack_Component = enemy.attack_component
			atc.attack_target(players[0])
			
		attack_rate_count = 0

func Physics_Update(_delta : float):
	pass
