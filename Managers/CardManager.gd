extends Node2D
## Card Manager handles the deck, discard pile, count and signals for card actions
class_name CardManager

@export var card_deck : Array= []
@export var card_hand : Array = []
@export var hand_size : int = 5
@export var discard_pile : Array = []
@export var ui : HUD #Reference to HUD for actions

signal gain_card #Add a card to the deck
signal discard_card #Remove a card from your hand
signal remove_card #Remove a card from the game
signal draw_card #Add a card to the hand

func is_hand_space_available():
	if card_hand.size() < hand_size:
		return true
	return false

func add_card_to_deck():
	pass

func draw_card_from_deck():
	pass

func discard_card_from_hand():
	pass

func remove_card_from_game():
	pass

func remove_card_from_deck():
	pass
