extends Label

@export var multiplayer_controller: Node # Reference to your multiplayer manager

func _process(_delta: float) -> void:
	var multiplayer_peer = multiplayer.multiplayer_peer	
	# Ensure the peer is using ENet before checking statistics
	if multiplayer_peer is ENetMultiplayerPeer:
		if not multiplayer.is_server():
			var server_peer = multiplayer_peer.get_peer(1) #Get Server
			if server_peer:
				var latency = server_peer.get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME) / 2
				text = "Latency: %d ms" % latency
			else:
				text = "Latency: N/A"
