extends Node

const PORT = 9999
var peer = ENetMultiplayerPeer.new()

func host_game():
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	print("Server started!")

func join_game(ip_address):
	peer.create_client(ip_address, PORT)
	multiplayer.multiplayer_peer = peer
	print("Connecting...")
