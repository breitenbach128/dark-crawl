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
		client_send_gamesetup_info(id)
	#launch_game()# need a new function to wait until it has received all the data.
	#If I am the server, just launch and create. if I am not, then I need to wait until 
	#I have all the items I need to launch, such as monster positions, dungeon layout, etc.
	
	

func _on_peer_disconnected(id: int):
	print("Peer left the server: ", id)	
	
func launch_game():
	var main_scene : MainScene = load(MAIN_GAME_SCENE).instantiate()
	get_tree().change_scene_to_node(main_scene)

@rpc("authority", "call_remote", "reliable")
func client_recv_gamesetup_info(dungeon_data : Dictionary):
	print("Client Recevied Setup Info from host")
	print(dungeon_data)

func client_send_gamesetup_info(id : int):
	if Globals.current_main is not MainScene:
		print("Current Scene incorrect. Cant send dungeon data")
		return
	
	var dungeon_creator :DungeonGenerator = Globals.current_main.dungeon_creator
	var dungeon_data : Dictionary = {
		map_area = dungeon_creator.map_area,
		map_tiles = dungeon_creator.map_tiles,
		room_list = []
	}
	#Roomlist must be rebuilt to only include what is required
	for r : RoomData in dungeon_creator.room_list:
		var room_data : Dictionary = {
			room_id = r.room_id,
			rect = r.rect,
			room_connected = r.is_connected,
			coonected_rooms = r.connected_room_ids
		}
		dungeon_data.room_list.append(room_data)
	
	#Send info to clients
	rpc_id(id, "client_recv_gamesetup_info", dungeon_data)
		
		
		
