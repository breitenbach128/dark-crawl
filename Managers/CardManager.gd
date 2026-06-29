extends Node
## Card Manager handles the deck, discard pile, count and signals for card actions

var card_deck : Array= []
var card_hand : Array = []
var hand_size : int = 5
var discard_pile : Array = []
var player_cards : Array[Dictionary] = []
var ui : HUD #Reference to HUD for actions
var player : Player
var card_db : Array[Dictionary] = []


func _ready() -> void:
	var card_scenes = Globals.get_scenes_in_folder("res://UI/Cards/")
	card_scenes.sort_custom(func(a, b): return a < b)
	
	for cs in range(0,card_scenes.size()):
		card_db.append({
			"id":cs,
			"res":card_scenes[cs]
		})

func get_carddb_index_by_id(id: int):
	var f = -1
	for c in range(0,card_db.size()-1):
		if card_db[c].id == id:
			f = c
	return f

func init_host_card_manager(p: Player) -> void:
	player = p
	ui = player.ui
	print("CM: Card Manager Setup for: ", player.name, " on host")	
	
	player_cards.append({
		"pid": player.name.to_int(),
		"player": player,
		"deck" : [],
		"hand" : [],
		"discard" : [],
		"client_ready" : false
	})
	for i in range(0,hand_size*2):
		build_starting_deck(player_cards.size()-1)	
		
	if player.name.to_int() == 1: #Server is always ready
		player_cards[player_cards.size()-1].client_ready = true


## Utility to get player index in player_cards array
func get_player_index_by_pid(pid):
	var p_card_index = player_cards.find_custom(func(p): return p.pid == pid)
	return p_card_index

## Run this function when the clients card manager responds it is ready to receive data
@rpc("any_peer", "call_remote", "reliable")
func server_receive_client_ready_status():
	#print("CM: Client Card Manager Ready: Client:", multiplayer.get_remote_sender_id(), " server: ", multiplayer.get_unique_id())
	var p_card_index = get_player_index_by_pid(multiplayer.get_remote_sender_id())
	if p_card_index != -1:
		#print("Server Card Deck: for client -> ", player_cards[p_card_index].deck)
		var card_deck_ids : Array = player_cards[p_card_index].deck.map(func(card): return {"id":card.card_data.id,"name":card.name})
		client_rcv_starting_deck.rpc_id(multiplayer.get_remote_sender_id(),{"deck":card_deck_ids})

## Server only. Building the server starting deck for each player that is in game.
func build_starting_deck(player_index):
	
	var rand_card = card_db.pick_random()
	var pick_card = load(rand_card.res).instantiate()
	add_card_to_deck(pick_card,player_index,rand_card)

## Client Only. Build starting deck from server information
@rpc("authority", "call_remote", "reliable")
func client_rcv_starting_deck(data : Dictionary):
	#print("CM: Client Rcv, Deck: ",multiplayer.get_unique_id()," ", data)
	for c in data.deck:		
		var card_data = card_db[get_carddb_index_by_id(c.id)]
		var new_card = load(card_data.res).instantiate()
		new_card.name = c.name
		#print("Client Spawn Card: " , new_card.name, " " ,card_data.res, " ",card_data.id, " ", c.id)
		Globals.local_player.ui.card_deck.add_child(new_card,true)
		new_card.player = Globals.local_player
		new_card.ui = Globals.local_player.ui
		new_card.card_data = card_data
		new_card.visible = false	
	
	#Client needs to send ready state to begin normal deck flow
	client_deck_is_ready.rpc_id(1)
	#client_requests_card.rpc_id(1)
	
## Server Only. Client is ready to receive new cards
@rpc("any_peer", "call_remote", "reliable")
func client_deck_is_ready():
	var player_index=get_player_index_by_pid(multiplayer.get_remote_sender_id()) 
	player_cards[player_index].client_ready = true
	var players_ready =  player_cards.filter(func(p): return p.client_ready==true)
	if players_ready.size() == Network.max_players:
		#Game is ready to start:
		#print("CM: All Players are ready to draw cards!")
		for p in range(0,players_ready.size()):
			draw_new_hand(p)
		
## Server Only. Client requests a card / restock of their hand
@rpc("any_peer", "call_remote", "reliable")
func client_requests_card():
	#print("CM: Client :",multiplayer.get_remote_sender_id(), " requests card from Server: ", multiplayer.get_unique_id())
	var p_index=get_player_index_by_pid(multiplayer.get_remote_sender_id()) 
	# Check if space is available in hand
	draw_new_hand(p_index)


## Check if there is space to draw a card
func is_hand_space_available(player_index):	
	if player_cards[player_index].hand.size() < hand_size:
		return true
	return false

func add_card_to_deck(new_card: Card, player_index, card_data):	
	new_card.player = player_cards[player_index].player
	new_card.card_data = card_data
	new_card.visible = false
	#print("adding new card to deck: ",new_card.name, " ", new_card.card_data)
	if ui:
		new_card.ui = ui
		ui.card_deck.add_child(new_card,true)
	else:		
		player.client_cards.add_child(new_card,true)
		
	player_cards[player_index].deck.append(new_card)

func draw_new_hand(player_index):
	while is_hand_space_available(player_index):
		if player_cards[player_index].deck.size() > 0:
			draw_card_from_deck(player_index)
		else:
			shuffle_discard_into_deck(player_index)	

		#Pause between draws for effect
		await get_tree().create_timer(0.7).timeout
		
	#print("CM: Drew New Hand for PID: ", player_cards[player_index].player.name)

func draw_card_from_deck(player_index):
	#print("CM: Local Server: Draw Card from Deck for pid: ", player_cards[player_index].pid)
	var card: Card = player_cards[player_index].deck.pop_front()
	card.card_hand_index = player_cards[player_index].hand.size()
	player_cards[player_index].hand.append(card)
	if player_cards[player_index].pid != 1:
		#RPC CALL TO CLIENT - DRAW CARD
		client_rcv_draw_card.rpc_id(player_cards[player_index].pid,{"cardname":card.name, "handindex": card.card_hand_index })
	else:
		Globals.local_player.ui.draw_card()

## Client Only. Receive the action to draw a new card from the deck.
@rpc("authority", "call_remote", "reliable")
func client_rcv_draw_card(data : Dictionary):
	#print("CM: Client Rcv, server has drawn card: ", data)
	Globals.local_player.ui.draw_card()

func discard_card_from_hand(pid, card_index):	
	var player_index = get_player_index_by_pid(pid)
	var card: Card = player_cards[player_index].hand.pop_at(card_index)
	#Rebuild the indexes on the player hand
	recalc_hand_indexes(player_index)
	player_cards[player_index].discard.append(card)	
	client_discard_card_from_hand.rpc_id(pid, card.name)
	#print("CM: Server Discard from hand for player: ",pid, " card_index: ", card_index, " ", card.name)

## Client Only. Local UI discard action.
@rpc("authority", "call_local", "reliable")
func client_discard_card_from_hand(card_node_name):
	#print("CM: Client Recv. Discard UI action on ",card_node_name, " local client ID: ", multiplayer.get_unique_id())
	var card : Card = Globals.local_player.ui.card_hand.get_node_or_null(NodePath(card_node_name))
	if card:
		Globals.local_player.ui.discard_card(card)
	else:
		print("CM: Error: No Card Found in client UI card_hand. Name: ", card_node_name)
	#Here is where I can report from the client the discard is done
	#Maybe by attaching to a signal?

## Server Only. Client completes their discard and lets the server know
@rpc("any_peer", "call_local", "reliable")
func client_discard_complete(client_hand_count,discards_in_action):
	if multiplayer.is_server():
		#Is hand empty?
		var player_index = get_player_index_by_pid(multiplayer.get_remote_sender_id())
		if player_cards[player_index].hand.size() == 0 && client_hand_count == 0 && discards_in_action == 0:
			#print("CM: Hand empty for client:",multiplayer.get_remote_sender_id()," . Draw new hand")
			draw_new_hand(player_index)

func remove_card_from_deck(player_index,card_index):
	player_cards[player_index].deck.remove_at(card_index)
	if ui:
		pass

func recalc_hand_indexes(player_index):
	for c in range(0,player_cards[player_index].hand.size()):
		player_cards[player_index].hand[c].card_hand_index = c

func shuffle_discard_into_deck(player_index):
	#Reset the cards
	for card : Card in player_cards[player_index].discard:
		card.reset_card()
	#Add back into deck
	player_cards[player_index].deck.append_array(player_cards[player_index].discard)
	player_cards[player_index].discard.clear()
	player_cards[player_index].deck.shuffle()
	#print("CM: Local Server: Shuffled Discard into Deck for ", player_cards[player_index].pid)
	#Send action to the client along with new card order
	var card_deck_info : Array = player_cards[player_index].deck.map(func(card): return {"id":card.card_data.id,"name":card.name})
	client_shuffle_discard_into_deck.rpc_id(player_cards[player_index].pid,card_deck_info)
	
@rpc("authority", "call_local", "reliable")
func client_shuffle_discard_into_deck(card_deck_info): #id and name properties	
	Globals.local_player.ui.shuffle_discard_into_deck(card_deck_info)

## This is called by any peer, including server. It runs the card action on the server
@rpc("any_peer", "call_local", "reliable")
func run_card(index):
	#print("CM: ID: ", multiplayer.get_remote_sender_id(), " runs card at hand index: ", index, " on ", multiplayer.get_unique_id())
	var p_index=get_player_index_by_pid(multiplayer.get_remote_sender_id())
	if player_cards[p_index].hand.size() > index && index >= 0:
		var card : Card = player_cards[p_index].hand[index]
		if card.card_ready:
			card.use_card()
			#If sender is not the server, then I need to let them know the server ran the card
			if multiplayer.get_remote_sender_id() != 1:
				client_run_card.rpc_id(multiplayer.get_remote_sender_id(),card.name)
	else:
		print("CM: Warning: Client called card index outside of hand size")
## Client receives message to start it visual card cooldown action and decrement energy
@rpc("authority", "call_remote", "reliable")	
func client_run_card(card_node_name):
	print("CM: Card run on client issued by server. Name: ",card_node_name)
	var card : Card = Globals.local_player.ui.card_hand.get_node_or_null(NodePath(card_node_name))
	if card:
		card.use_card()
	else:
		print("CM: Error: No Card Found in client UI card_hand. Name: ", card_node_name)

## Run the tween for the drawing of the card
func ui_visual_draw_card():
	pass
