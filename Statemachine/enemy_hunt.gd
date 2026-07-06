extends State
class_name StateEnemyHunt
## This state hunts a target, getting to within range to attack.


@export var enemy : Enemy
@export var forgetfullness: float = 0.0
var move_speed : float = 6.0
var rotation_speed :float = 8.0
var move_direction: Vector3
var target : Player
#general purpose interrupts for states - Common actions
var is_dead : bool = false

func _ready() -> void:
	if enemy:
		enemy.health_component.health_death.connect(func(): is_dead = true)

func Enter():
	if enemy.animation_tree:
		enemy.behavior = "Walk"

func Update(delta: float):
	#Is Dead?
	if is_dead:
		Transitioned.emit(self, "StateEnemyDeath")
	
	if enemy:
		if !enemy.attack_component.is_target_in_range():
			var target_2d_vector = enemy.attack_component.current_target.global_position
			target_2d_vector.y = 0 #Restrict it to a flat 2d plane
			move_direction = enemy.global_position.direction_to(target_2d_vector)
			return
		Transitioned.emit(self, "StateEnemyAttack")
				
func Physics_Update(delta : float):
	#This direction will always be towards player
	if enemy:
		enemy.velocity = move_direction * move_speed 
