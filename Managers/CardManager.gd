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

signal gain_card #Add a card to the deck
signal discard_card #Remove a card from your hand
signal remove_card #Remove a card from the game
signal draw_card #Add a card to the hand

#each player should have a card deck/hand/discard array. May require a new dictionary
#Use that to track the cards in each one. I can still create the cards, 
#but need a place to store them. maybe a control node offset on each player?

#The manager can handle moving the cards around and trigger the UI events.

#Order:
# Once all peers are connected, and the game starts.
# Host inits the card manager
# CM generates cards for all players.
# CM sends card info to all peers FROM the host.
# Draw intial card action is started from this message.
# When players discard a card, sends msg to server. 
# Server receives, and if hand empty, draws 5 cards, updates the local arrays
# Server sends the drawn cards to and local array ids to the client.
# CLient receives and triggers UI action for visual.

#Client presses "use card" and it sends to server, which replies back to call use_card func

func _ready() -> void:
	var card_scenes = Globals.get_scenes_in_folder("res://UI/Cards/")
	card_scenes.sort_custom(func(a, b): return a < b)
	
	for cs in range(0,card_scenes.size()):
		card_db.append({
			"id":cs,
			"res":card_scenes[cs]
		})
	#print("CardDB: ", card_db)

func get_carddb_index_by_id(id: int):
	var f = -1
	for c in range(0,card_db.size()-1):
		if card_db[c].id == id:
			f = card_db[c].id
	return f

func init_host_card_manager(p: Player) -> void:
	player = p
	ui = player.ui
	print("Card Manager Setup for: ", player.name, " on host")	
	
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
	
	#draw_new_hand(player_cards.size()-1)

## Utility to get player index in player_cards array
func get_player_index_by_pid(pid):
	var p_card_index = player_cards.find_custom(func(p): return p.pid == pid)
	return p_card_index

## Run this function when the clients card manager responds it is ready to receive data
@rpc("any_peer", "call_remote", "reliable")
func server_receive_client_ready_status():
	print("Client Card Manager Ready: Client:", multiplayer.get_remote_sender_id(), " server: ", multiplayer.get_unique_id())
	var p_card_index = get_player_index_by_pid(multiplayer.get_remote_sender_id())
	if p_card_index != -1:
		print("Server Card Deck: for client -> ", player_cards[p_card_index].deck)
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
	print("Client Rcv, Deck: ", data)
	
	for c in data.deck:		
		var card_data = card_db[get_carddb_index_by_id(c.id)]
		var new_card = load(card_data.res).instantiate()
		#print("Client, Local Player: ", Network.get_local_player_instance())
		Globals.local_player.ui.card_deck.add_child(new_card,true)
		new_card.player = Globals.local_player
		new_card.ui = Globals.local_player.ui
		new_card.card_data = card_data
		new_card.visible = false	
	
	#Client needs to send ready state to begin normal deck flow
	client_requests_card.rpc_id(1)

## Server Only. Client requests a card
@rpc("any_peer", "call_remote", "reliable")
func client_requests_card():
	print("Client :",multiplayer.get_remote_sender_id(), " requests card from Server: ", multiplayer.get_unique_id())
	var p_index=get_player_index_by_pid(multiplayer.get_remote_sender_id()) 
	# Check if space is available in hand
	draw_new_hand(p_index)

## Check if there is space to draw a card
func is_hand_space_available(player_index):	
	if player_cards[player_index].hand.size() < hand_size:
		return true
	return false

func add_card_to_deck(new_card: Card, player_index, card_data):
	player_cards[player_index].deck.append(new_card)
	if ui:		
		ui.card_deck.add_child(new_card,true)
		new_card.player = player
		new_card.ui = ui
		new_card.card_data = card_data
		new_card.visible = false
	else:		
		player.client_cards.add_child(new_card,true)

func draw_new_hand(player_index):
	while is_hand_space_available(player_index):
		draw_card_from_deck(player_index)
		#Pause between draws for effect
		await get_tree().create_timer(1.5).timeout
	print("Drew New Hand for ", player_cards[player_index].player.name)


## Client Only. Receive the action to draw a new card from the deck.
@rpc("authority", "call_remote", "reliable")
func client_rcv_draw_card(data : Dictionary):
	print("Client Rcv, server has drawn card: ", data)
	Globals.local_player.ui.draw_card()


func draw_card_from_deck(player_index):
	print("Local Server: Draw Card from Deck for ", player_cards[player_index].pid)
	var card: Card = player_cards[player_index].deck.pop_front()
	player_cards[player_index].hand.append(card)
	if player_cards[player_index].pid != 1:
		#RPC CALL TO CLIENT - DRAW CARD
		client_rcv_draw_card.rpc_id(player_cards[player_index].pid,{"cardname":card.name})
		pass
	if ui:
		pass

func discard_card_from_hand(player_index, card_index):
	var card: Card = player_cards[player_index].hand.pop_at(card_index)
	player_cards[player_index].discard.append(card)
	#Is hand empty?
	if player_cards[player_index].hand.size() == 0:
		draw_new_hand(player_index)
	if ui:
		pass

func remove_card_from_deck(player_index,card_index):
	player_cards[player_index].deck.remove_at(card_index)
	if ui:
		pass

func shuffle_discard_into_desk(player_index):
	player_cards[player_index].deck.append_array(player_cards[player_index].discard)
	player_cards[player_index].deck.shuffle()
	print("Local Server: Shuffled Discard into Deck for ", player_cards[player_index].pid)


## Run the tween for the drawing of the card
func ui_visual_draw_card():
	pass
