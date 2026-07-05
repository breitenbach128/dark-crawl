extends State
class_name StateEnemyWander

@export var enemy : Enemy
var move_speed : float = 6.0
var rotation_speed :float = 8.0
var rotation_target_y : float = 0.0
var move_direction: Vector3
var wander_time : float
var bounce_time : float = 3.0
var los_check_time : float = 3.0
var los_check_tick : float = 0.0
#general purpose interrupts for states - Common actions
var is_dead : bool = false



func _ready() -> void:
	if enemy:
		enemy.health_component.health_death.connect(func(): is_dead = true)

func randomize_wander():
	move_direction  = Vector3(randf_range(-1,1),0.0,randf_range(-1,1))	
	wander_time = randf_range(3,6)

func bounce_wander():
	var deg_change = randf_range(150,360) if randf() < 0.5 else randf_range(-360,-150)	
	var rot_angle = enemy.rotation.y + deg_to_rad(deg_change)
	move_direction  = Vector3(cos(rot_angle),0,sin(rot_angle))
	wander_time = randf_range(3,6)
	bounce_time = 1.0
	#print("Bounce Wander: ", deg_change, " " ,rot_angle)

func Enter():
	randomize_wander()
	#print("Enter State, StateEnemyWander")
	if enemy.animation_tree:
		enemy.behavior = "Walk"
		
func Update(delta: float):
	#Is Dead?
	if is_dead:
		Transitioned.emit(self, "StateEnemyDeath")
	#Check for players to kill
	los_check_tick-= delta
	if los_check_tick <= 0:
		var target = enemy.find_closest_player_target()
		#var target = null
		if target:
			enemy.attack_component.	current_target = target
			Transitioned.emit(self, "StateEnemyHunt")
		los_check_tick = los_check_time
		
	#No players, so just wander	
	if wander_time > 0:
		wander_time -= delta
	else:
		randomize_wander()


func Physics_Update(delta : float):
	if enemy:
		enemy.velocity = move_direction * move_speed 
		
		if bounce_time > 0:
			bounce_time-=delta
		else:
			if enemy.detect_front.has_overlapping_bodies():
				#Hit something with front detection
				bounce_wander()
