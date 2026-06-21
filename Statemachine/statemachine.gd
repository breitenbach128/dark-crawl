extends Node
class_name StateMachine


@export var initial_state : State

var current_state : State
var states: Dictionary = {}

func _ready() -> void:
	print("Spawn Enemy on ", multiplayer.get_unique_id(), " " , multiplayer.has_multiplayer_peer())
	if !multiplayer.is_server():
		#disable non-server State machine
		print("MP authority for Enemy ", multiplayer.get_unique_id())
		process_mode = Node.PROCESS_MODE_DISABLED
		print("Enemy Process Node ,", process_mode)
	
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transitioned)
	
	if initial_state:
		initial_state.Enter()
		current_state = initial_state

func _process(delta: float) -> void:
	if current_state:
		current_state.Update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.Physics_Update(delta)

func  on_child_transitioned(state, new_state_name):
	if state != current_state:
		return
	var new_state = states.get(new_state_name.to_lower())

	if !new_state:
		return
	
	if current_state:
		current_state.Exit()
	
	new_state.Enter()
	current_state = new_state
	
