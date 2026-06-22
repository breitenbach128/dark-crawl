extends Node2D
## Card Manager handles the deck, discard pile, count and signals for card actions
class_name CardManager

@export var card_deck : Array= []
@export var card_hand : Array = []
@export var hand_size : int = 5
@export var discard_pile : Array = []
@export var ui : HUD #Reference to HUD for actions
@export var player : Player
signal gain_card #Add a card to the deck
signal discard_card #Remove a card from your hand
signal remove_card #Remove a card from the game
signal draw_card #Add a card to the hand


func _ready() -> void:
	print("Card Manager Ready")
	#Create first hand of cards
	for i in range(0,hand_size*2):
		draw_starting_card(card_deck, ui.card_deck, false)
	if ui:
		ui.draw_card()#Initial Draw

func draw_starting_card(location, ui_location, card_visible):
	var rand_card = Globals.card_db.pick_random()
	var pick_card = load(rand_card.res).instantiate()
	location.append(pick_card)
	if ui:
		ui_location.add_child(pick_card,true)
		pick_card.player = player
		pick_card.ui = ui
		pick_card.card_data = rand_card
		pick_card.visible = card_visible
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
