extends CharacterBody3D

class_name Enemy


@export var enemy_name : String = "Enemy"

@export var health_component : Health_Component
@export var attack_component : Attack_Component
@export var state_machine : StateMachine
@export var animation_player : AnimationPlayer
@export var animation_tree : AnimationTree
@export var line_of_sight: RayCast3D

@export var behavior : String = "Idle":
	set(new_value):
		behavior = new_value
		var anim_sm :AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
		anim_sm.travel(new_value)
		#print("New Behavior State: ", multiplayer.get_unique_id(), " ", new_value)

var gravity = 75.5
var coin_chance : float = 1.00 #75%

func _enter_tree() -> void:
	pass
	
func _ready() -> void:
	if multiplayer.is_server():
		if health_component:
			health_component.health_death.connect(death)

func death():
	if randf() < coin_chance:
		var coin : Coin = load("res://Pickups/coin.tscn").instantiate()
		get_tree().current_scene.pickups_root.add_child(coin,true)		
		coin.global_position = global_position
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
