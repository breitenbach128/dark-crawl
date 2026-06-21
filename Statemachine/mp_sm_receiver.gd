extends Node
class_name MultiplayerAnimSMReceiver

#This class handles the animination State machine changes received from the server.
#It replaces the normal state machine if this enemy is created on a non-server client

@export var enemy : Enemy


func _ready() -> void:
	if get_parent() is Enemy:
		enemy = get_parent()

## Calls from the server, not on the local peer, using TCP
@rpc("authority", "call_remote", "reliable")
func client_receive_anim_state(anim_name: String):
	if enemy.animation_tree:
		print("Client Received animation travel: ", multiplayer.get_unique_id(), " ",anim_name)
		var anim_sm :AnimationNodeStateMachinePlayback = enemy.animation_tree.get("parameters/playback")
		anim_sm.travel(anim_name)
