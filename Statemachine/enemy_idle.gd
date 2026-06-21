extends State
class_name StateEnemyIdle

@export var enemy : Enemy
@export var bored_level : float = 0.50

var idle_time : float
#general purpose interrupts for states - Common actions
var is_dead : bool = false

func randomize_idle():
	idle_time = randf_range(1,10)

func _ready() -> void:
	if enemy:
		enemy.health_component.health_death.connect(func(): is_dead = true)

func Enter():
	#print("Enter State, StateEnemyIdle")
	randomize_idle()
	if enemy.animation_tree:
		var anim_sm :AnimationNodeStateMachinePlayback = enemy.animation_tree.get("parameters/playback")
		anim_sm.travel("Idle")
		#Broadcast to clients to change their animations
		print("Entering Idle for SM on client : ", multiplayer.get_unique_id())
		#enemy.mp_anim_states.client_receive_anim_state.rpc("Idle")
		
func Update(delta: float):
	#Is Dead?
	if is_dead:
		Transitioned.emit(self, "StateEnemyDeath")
	if idle_time > 0:
		idle_time -= delta
	else:
		#Look to do something else
		if randf() < bored_level:
			Transitioned.emit(self, "StateEnemyWander")

func Physics_Update(_delta : float):
	pass
