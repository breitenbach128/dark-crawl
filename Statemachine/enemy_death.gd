extends State
class_name StateEnemyDeath

@export var enemy : Enemy


func death_animation_complete():
	enemy.queue_free()
	
func Enter():
	#print("Enter State Enemy Death")
	if enemy.animation_tree:
		var anim_sm :AnimationNodeStateMachinePlayback = enemy.animation_tree.get("parameters/playback")
		anim_sm.travel("Death")
