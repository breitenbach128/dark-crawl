extends State
class_name StateEnemyIdle

@export var enemy : CharacterBody3D
@export var bored_level : float = 0.50

var idle_time : float
 

func randomize_idle():
	idle_time = randf_range(1,10)
	
func Enter():
	print("Enter State, StateEnemyIdle")
	randomize_idle()

func Update(delta: float):
	if idle_time > 0:
		idle_time -= delta
	else:
		#Look to do something else
		if randf() < bored_level:
			Transitioned.emit(self, "StateEnemyWander")

func Physics_Update(_delta : float):
	pass
