extends State
class_name StateEnemyDeath

@export var enemy : Enemy
var death_time : float = 0.0

func death_animation_complete():
	enemy.queue_free()
	
func Enter():
	#print("Enter State Enemy Death")
	if enemy.animation_tree:
		enemy.behavior = "Death"

func Update(delta):
	death_time += delta
	if death_time > 1:
		enemy.queue_free()
