extends Node

const PORT = 9999
var peer = ENetMultiplayerPeer.new()
const MAIN_GAME_SCENE = "res://Screens/main.tscn"
const PLAYER_SCENE = "res://Player/player.tscn"

func host_game():
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	print("Server started!")
	Globals.local_player_id = 1
	launch_game()
	
func join_game(ip_address):
	peer.create_client(ip_address, PORT)
	multiplayer.multiplayer_peer = peer
	print("Connecting...")

func _ready():
	# Connect client-specific signals
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	
	# Connect server-specific signals (on the host)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_connected_to_server():
	print("Successfully connected to the server!")
	# Spawn your local player here or send an RPC to the server

func _on_connection_failed():
	print("Connection failed.")

func _on_peer_connected(id: int):
	print("Peer joined the server with ID: ", id)
	Globals.local_player_id = id
	if multiplayer.is_server():
		#send the clients the dungone information from the host session main scene
		pass
	launch_game()# need a new function to wait until it has received all the data.
	#If I am the server, just launch and create. if I am not, then I need to wait until 
	#I have all the items I need to launch, such as monster positions, dungeon layout, etc.
	
	

func _on_peer_disconnected(id: int):
	print("Peer left the server: ", id)	
	
func launch_game():
	var main_scene : MainScene = load(MAIN_GAME_SCENE).instantiate()
	get_tree().change_scene_to_node(main_scene)
