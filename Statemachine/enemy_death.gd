extends State
class_name StateEnemyDeath

@export var enemy : Enemy


func death_animation_complete():
	enemy.queue_free()
	
func Enter():
	#print("Enter State Enemy Death")
	if enemy.animation_tree:
		enemy.behavior = "Death"
