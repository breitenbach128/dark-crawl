extends Node

const PORT = 9999
var peer = ENetMultiplayerPeer.new()
const MAIN_GAME_RES = "res://Screens/main.tscn"
const PLAYER_RES = "res://Player/player.tscn"
var main_scene : MainScene
var player_scene

#Game Setup Variables for Clients
var client_dungeon_data : Dictionary

func host_game():
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	print("Server started!")
	Globals.local_player_id = 1
	launch_game()
	main_scene.dungeon_creator.build_dungeon(true)
	main_scene.player_peers.append(1)
	
	if main_scene.max_players == 1:
		start_network_game()
	
func join_game(ip_address):
	peer.create_client(ip_address, PORT)
	multiplayer.multiplayer_peer = peer
	print("Connecting...")	
	launch_game()

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
	print("Host: ",multiplayer.get_unique_id()," Peer joined the server with ID: ", id)
	Globals.local_player_id = multiplayer.get_unique_id()		
	#send the clients the dungeon information from the host session main scene	
	#var p = main_scene.spawn_player(id)
	#print("Spawn position: ", p.position)
	if multiplayer.is_server():	
		#print("Host Action->Client")
		client_send_gamesetup_info(id)
		main_scene.player_peers.append(id)
		start_network_game()

			
func _on_peer_disconnected(id: int):
	print("Peer left the server: ", id)	

func start_network_game():
	if main_scene.player_peers.size() >= main_scene.max_players:
		for pid in main_scene.player_peers:
			var p = main_scene.spawn_player(pid)

		main_scene.start_game()

func launch_game():	
	main_scene = load(MAIN_GAME_RES).instantiate()	
	get_tree().change_scene_to_node(main_scene)
	Globals.current_main = main_scene

@rpc("authority", "call_remote", "reliable")
func client_recv_spawn_position(spawn_position):
	var client = main_scene.players_root.get_node_or_null(str(multiplayer.get_unique_id()))
	client.position = spawn_position

@rpc("authority", "call_remote", "reliable")
func client_recv_gamesetup_info(dungeon_data : Dictionary):
	#print("Client Recevied Setup Info from host: Client->", multiplayer.get_unique_id())
	#print("map_area: ", dungeon_data.map_area)
	client_dungeon_data = dungeon_data
	Globals.current_main.dungeon_creator.build_dungeon(false)
	
	
func client_send_gamesetup_info(id : int):
	if Globals.current_main is not MainScene:
		print("Current Scene incorrect. Cant send dungeon data")
		return
	
	var dungeon_creator :DungeonGenerator = Globals.current_main.dungeon_creator
	var map_tile_package = []
	#Gather all the tile data
	for y in dungeon_creator.map_area.size.y:
		for x in dungeon_creator.map_area.size.x:
			var mt = dungeon_creator.map_tiles[x][y]
			var mtres = mt.mesh_resource.resource_path if mt.mesh_resource != null else ""
			map_tile_package.append([x,y,mt.position.x,mt.position.y,mt.type,mtres])
	#Create General Dungeon Package to send
	var dungeon_data : Dictionary = {
		map_area = dungeon_creator.map_area,
		map_tiles = map_tile_package,
		room_list = []
	}
	#Roomlist must be rebuilt to only include what is required
	for r : RoomData in dungeon_creator.room_list:
		var room_data : Dictionary = {
			room_id = r.room_id,
			rect = r.rect,
			room_connected = r.is_connected,
			connected_rooms = r.connected_room_ids
		}
		dungeon_data.room_list.append(room_data)
	
	#Send info to clients
	rpc_id(id, "client_recv_gamesetup_info", dungeon_data)
		
		
		
