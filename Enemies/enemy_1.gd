extends CharacterBody3D

class_name Enemy


@export var enemy_name : String = "Enemy"

@export var health_component : Health_Component
@export var attack_component : Attack_Component
@export var state_machine : StateMachine
@export var animation_player : AnimationPlayer
@export var animation_tree : AnimationTree
@export var line_of_sight: RayCast3D


var gravity = 75.5

func _ready() -> void:
	if health_component:
		health_component.health_death.connect(death)

func death():
	$DeathSounds.play()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()
	
func check_line_of_sight(target):
	line_of_sight.target_position = target.global_position - line_of_sight.global_position
	line_of_sight.force_raycast_update()
	if line_of_sight.is_colliding():
		var collider = line_of_sight.get_collider()
		return  collider == target
	return false

func find_closest_player_target():
	var players = get_tree().get_nodes_in_group("Player")
	var target = null
	var min_distance = INF 
	for p in players:
		if is_instance_valid(p):
			if check_line_of_sight(p):
				var distance = global_position.distance_squared_to(p.global_position)
				if distance < min_distance:
					min_distance = distance
					target = p
	return target
