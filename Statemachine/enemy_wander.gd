extends State
class_name StateEnemyWander

@export var enemy : Enemy
var move_speed : float = 6.0
var move_direction: Vector3
var wander_time : float
#general purpose interrupts for states - Common actions
var is_dead : bool = false



func _ready() -> void:
	if enemy:
		enemy.health_component.health_death.connect(func(): is_dead = true)

func randomize_wander():
	move_direction  = Vector3(randf_range(-1,1),0.0,randf_range(-1,1))
	wander_time = randf_range(3,6)

func Enter():
	randomize_wander()
	print("Enter State, StateEnemyWander")
	if enemy.animation_tree:
		var anim_sm :AnimationNodeStateMachinePlayback = enemy.animation_tree.get("parameters/playback")
		anim_sm.travel("Walk")
		
func Update(delta: float):
	#Is Dead?
	if is_dead:
		Transitioned.emit(self, "StateEnemyDeath")
	#Check for players to kill
	var target = enemy.find_closest_player_target()
	if target:
		Transitioned.emit(self, "StateEnemyAttack")
	
	#No players, so just wander	
	if wander_time > 0:
		wander_time -= delta
	else:
		randomize_wander()


func Physics_Update(_delta : float):
	if enemy:		
		enemy.velocity = move_direction * move_speed 

 
