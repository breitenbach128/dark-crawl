extends Control
class_name UI

@export_category("Labels")
@export var debug_card_index : Label

@export_category("Cards")
@export var card_deck : TextureRect
@export var card_hand : HBoxContainer
@export var discard_path: Path2D
@export var player: Player
var selected_card : Card
var selected_card_index : int = 0
var max_hand_size : int = 5
var draw_tween_pending : int = 0

enum SCREEN_FLASH_TYPE {HURT, HEAL, AURA, ZONE}


func _ready() -> void:
	
	
	var cards = card_hand.get_children()
	if cards.size() > 0:
		select_card(selected_card_index)
	#Connect UI to Player Signals
	if player:
		player.health_component.health_changed.connect(update_ui_display_health)
		update_ui_display_health(player.health_component.health,player.health_component.health_max,0)

func update_ui_display_health(hp : float,hpmax : float,change):
	var hp_change_percent : float = snapped((hp/hpmax),0.01)
	#print("HP: ", hp, " HPMAX: ", hpmax)
	#print(hp_change_percent," ",(hp/hpmax))
	if change < 0:
		screen_flash(SCREEN_FLASH_TYPE.HURT, 1-hp_change_percent)
		pass
	$Health.text = "HP: " + str(hp)

func screen_flash(type : SCREEN_FLASH_TYPE, intensity : float):
	match type:
		SCREEN_FLASH_TYPE.HURT:
			var hurt_rect : ColorRect = ColorRect.new()
			hurt_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
			self.add_child(hurt_rect)
			hurt_rect.color = Color(1,0,0,intensity)
			var tween = create_tween()
			tween.tween_property(hurt_rect,"color",Color(1,0,0,0),0.2)
			tween.tween_callback(func(): hurt_rect.queue_free())


func get_next_card():
	var cards = card_hand.get_children()
	if cards.size() > 0:
		var next_index = selected_card_index + 1
		if next_index >= card_hand.get_child_count():
			next_index = 0
		select_card(next_index)
		
func get_prev_card():
	var cards = card_hand.get_children()
	if cards.size() > 0:
		var next_index = selected_card_index - 1
		if next_index < 0:
			next_index = card_hand.get_child_count()-1
		select_card(next_index)
		
func select_card(index):
		for c : Card in card_hand.get_children():
			c.deselected()
		selected_card_index = index
		selected_card = card_hand.get_child(selected_card_index)
		selected_card.selected()
		debug_card_index.text = str(selected_card_index)

func draw_card():
	#Only allow if hand is not max size
	if card_hand.get_child_count() < max_hand_size:
		#print("Card Deck Position, ", card_deck.global_position)
		var drop_position = card_hand.global_position
		if card_deck.get_child_count() > 0:
			draw_tween_pending = draw_tween_pending + 1
			if card_hand.get_child_count() > 0:
				var last_card : Card = card_hand.get_child(card_hand.get_child_count()-1)
				#print("last Card position ",last_card.global_position, " ", last_card.name)
				drop_position = last_card.global_position + Vector2(card_hand.get_theme_constant("separation")*draw_tween_pending,0) + Vector2(last_card.custom_minimum_size.x*draw_tween_pending,0)
			
				
			var top_card : Card = card_deck.get_child(0)
			top_card.visible = true
			top_card.reparent(self,true)
			
			#print("drop position: ", drop_position)
			var draw_card_tween = create_tween()			
			draw_card_tween.finished.connect(take_card.bind(top_card))
			var vp_size = get_viewport_rect().size
			var center_position = (vp_size-top_card.custom_minimum_size)/2 + Vector2(-64,0)
			# Tween the global position over 0.5 seconds, pause of 0.5 and then transition to hand position
			#print("center position ", center_position, " ", vp_size,  " " , top_card.size)
			draw_card_tween.set_parallel(true)
			draw_card_tween.tween_property(top_card, "global_position", center_position, 0.75).set_trans(Tween.TRANS_SINE)
			draw_card_tween.tween_property(top_card, "scale", Vector2(2,2), 0.75).set_trans(Tween.TRANS_SINE)
			draw_card_tween.chain().tween_interval(1)
			draw_card_tween.set_parallel(true)
			draw_card_tween.tween_property(top_card, "global_position", drop_position, 0.5).set_trans(Tween.TRANS_SINE).set_delay(1.5)
			draw_card_tween.tween_property(top_card, "scale", Vector2(1,1), 0.5).set_trans(Tween.TRANS_SINE).set_delay(1.5)


func take_card(top_card : Card):
	top_card.reparent(card_hand,true)
	draw_tween_pending = max(0,draw_tween_pending - 1) #Clamps to zero as a min
	top_card.drawn(card_hand.get_child_count() - 1,self,player)

func discard_card(card : Card):
	card.is_discarded = true
	card.reparent(self, true) #Move back to UI parent
	card.discarded(discard_path, self) #Setup path to follow to trash

func _input(event):
	if event.is_action_pressed("select_next_card"):
		get_next_card()
	if event.is_action_pressed("select_prev_card"):
		get_prev_card()
