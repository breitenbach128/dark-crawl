extends Node
## Card Manager handles the deck, discard pile, count and signals for card actions

var card_deck : Array= []
var card_hand : Array = []
var hand_size : int = 5
var discard_pile : Array = []
var ui : HUD #Reference to HUD for actions
var player : Player
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

func init_card_manager(p: Player) -> void:
	player = p
	ui = player.ui
	print("Card Manager Setup")
	#Create first hand of cards
	#if multiplayer.is_server():
		#create_starting_deck()
		#
	#if multiplayer.get_unique_id() != 1:
		#if player.name.to_int() == multiplayer.get_unique_id():
			#server_receive_client_ready_status.rpc_id(1)
		
func create_starting_deck():
	print("Player: ", player.name, " starting deck created on server")
	for i in range(0,hand_size*2):
		draw_starting_card()	
	if ui:
		ui.draw_card()#Initial Draw
		
@rpc("any_peer", "call_local", "reliable")
func server_receive_client_ready_status():
	print("Client Card Manager Ready: ", multiplayer.get_remote_sender_id(), " for player:" ,player.name.to_int(), " server: ", multiplayer.get_unique_id())
	#var card_ids = card_deck.map(func(obj): return obj.card_data)	
	print("Card Deck:", card_deck)
	#client_receive_starting_deck_info.rpc_id(multiplayer.get_remote_sender_id(),card_ids)
	
@rpc("authority", "call_remote", "reliable")
func client_receive_starting_deck_info( deck_ids: Array):
	print(player.name.to_int(), " - Received Starting Deck info-> ", deck_ids)

func draw_starting_card():
	var rand_card = Globals.card_db.pick_random()
	var pick_card = load(rand_card.res).instantiate()
	card_deck.append(pick_card)
	if ui:
		ui.card_deck.add_child(pick_card,true)
		pick_card.player = player
		pick_card.ui = ui
		pick_card.card_data = rand_card
		pick_card.visible = false
	else:
		add_child(pick_card,true)

func is_hand_space_available():
	if card_hand.size() < hand_size:
		return true
	return false

func add_card_to_deck(card: Card):
	card_deck.append(card)
	add_child(card,true)
	if ui:
		pass

func draw_card_from_deck():
	var card: Card = card_deck.pop_front()
	card_hand.append(card)
	if ui:
		pass

func discard_card_from_hand(index):
	var card: Card = card_hand.pop_at(index)
	discard_pile.append(card)
	if ui:
		pass

func remove_card_from_game(card_array : Array, index):
	card_array.remove_at(index)
	if ui:
		pass

func remove_card_from_deck(index):
	card_deck.remove_at(index)
	if ui:
		pass

## Run the tween for the drawing of the card
func ui_visual_draw_card():
	pass
