extends State
class_name StateEnemyWander

@export var enemy : CharacterBody3D
var move_speed : float = 6.0
var move_direction: Vector3
var wander_time : float

func randomize_wander():
	move_direction  = Vector3(randf_range(-1,1),0.0,randf_range(-1,1))
	wander_time = randf_range(3,6)
	

func Enter():
	randomize_wander()
	print("Enter State, StateEnemyWander")

func Update(delta: float):
	#Check for players to kill
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		#can check aggro distance and LOS later
		Transitioned.emit(self, "StateEnemyAttack")

	#No players, so just wander	
	if wander_time > 0:
		wander_time -= delta
	else:
		randomize_wander()

func Physics_Update(_delta : float):
	if enemy:		
		enemy.velocity = move_direction * move_speed 
		
#Transitioned.emit(self, "otherstate")
