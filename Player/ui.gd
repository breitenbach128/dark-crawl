extends Control
class_name HUD

@export_category("Labels")
@export var debug_card_index : Label

@export_category("HUD")
@export var effects_area: HBoxContainer
@export var healing_particles : GPUParticles2D
@export var healing_particles_timer : Timer
@export var TopDownDisplay : TextureRect
@export var mp_id_label : Label
@export var deck_count_label: Label
@export var discard_count_label: Label

@export_category("Cards")
@export var card_deck : TextureRect
@export var card_hand : HBoxContainer
@export var discard_path: Path2D
@export var discard_deck: TextureRect
@export var player: Player
var selected_card : Card
var selected_card_index : int = 0
var max_hand_size : int = 5
var draw_tween_pending : int = 0
var is_drawing_hand : bool  = false

enum SCREEN_FLASH_TYPE {HURT, HEAL, AURA, ZONE}


func _ready() -> void:
	
	
	var cards = card_hand.get_children()
	if cards.size() > 0:
		select_card(selected_card_index)
	#Connect UI to Player Signals
	if player:
		player.health_component.health_changed.connect(update_ui_display_health)
		update_ui_display_health(player.health_component.health,player.health_component.health_max,0)
		draw_card()#Initial Draw


func update_ui_display_health(hp : float,hpmax : float,change):
	var hp_change_percent : float = snapped((hp/hpmax),0.01)
	#print("HP: ", hp, " HPMAX: ", hpmax)
	#print(hp_change_percent," ",(hp/hpmax))
	if change < 0:
		screen_flash(SCREEN_FLASH_TYPE.HURT, 1-hp_change_percent)
		pass
	$Health.text = "HP: " + str(hp)
	if change > 0:
		start_healing_particles()
	

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
	#ASSUMPTION - STARTING DECK EXISTS
	#print("DECK COUNT PRE SHUFFLE ", card_deck.get_child_count())
	if card_deck.get_child_count() <= 0:
		shuffle_discard_into_desk()
	if card_deck.get_child_count() <= 0:
		print("Error. No Cards in Deck")
		return
	#Only allow if hand is not max size
	if card_hand.get_child_count() < max_hand_size:		
		var drop_position = card_hand.global_position
		if drop_position.x == 0:
			drop_position.x = 164.0
		print("Global drop position, ", drop_position)
		draw_tween_pending = draw_tween_pending + 1
		var hand_count = card_hand.get_child_count()
		var min_card_size_x = 160	
		drop_position += Vector2((min_card_size_x+card_hand.get_theme_constant("separation"))*hand_count,0)
		print(drop_position)
		var top_card : Card = card_deck.get_child(0)
		top_card.visible = true
		top_card.reparent(self,true)
		
		#TWEEN
		var draw_card_tween = create_tween()			
		var vp_size = get_viewport_rect().size
		var center_position = (vp_size-top_card.custom_minimum_size)/2 + Vector2(-64,0)
		draw_card_tween.set_parallel(true)
		draw_card_tween.tween_property(top_card, "global_position", center_position, 0.75).set_trans(Tween.TRANS_SINE)
		draw_card_tween.tween_property(top_card, "scale", Vector2(1.3,1.3), 0.75).set_trans(Tween.TRANS_SINE)
		draw_card_tween.chain().tween_interval(1)
		draw_card_tween.set_parallel(true)
		draw_card_tween.tween_property(top_card, "global_position", drop_position, 0.5).set_trans(Tween.TRANS_SINE).set_delay(0.8)
		draw_card_tween.tween_property(top_card, "scale", Vector2(1,1), 0.5).set_trans(Tween.TRANS_SINE).set_delay(0.8)
		draw_card_tween.finished.connect(take_card.bind(top_card))

func take_card(top_card : Card):
	top_card.reparent(card_hand,true)
	draw_tween_pending = max(0,draw_tween_pending - 1) #Clamps to zero as a min
	top_card.drawn(card_hand.get_child_count() - 1,self,player)	
	update_card_control_icons()
	deck_count_label.text = str(card_deck.get_child_count())
	if card_hand.get_child_count() < max_hand_size:
		draw_card()

func discard_complete():
	print("Discard Complete")
	discard_count_label.text = str(discard_deck.get_child_count())
	#Hand is empty, so start drawing again
	if card_hand.get_child_count() == 0:
		print("Hand Empty")
		draw_card()
	
func discard_card(card : Card):
	card.is_discarded = true
	card.reparent(self, true) #Move back to UI parent
	card.discarded(discard_path, self) #Setup path to follow to trash
	update_card_control_icons()

func shuffle_discard_into_desk():
	print("SHUFFLE DISCARD INTO DECK ", discard_deck.get_child_count())
	for card : Card in discard_deck.get_children():
		card.reparent(card_deck, false)
		card.is_discarded = false
		card.energy = card.max_energy
		card.card_ready = true
		card.update_energy_display()
	print("DECK COUNT POST SHUFFLE ", card_deck.get_child_count())
	discard_count_label.text = str(discard_deck.get_child_count())
	
func update_card_control_icons():
	for cardindex in card_hand.get_child_count():
		card_hand.get_child(cardindex).update_control_texture(cardindex)
		

func _input(event):
	if event.is_action_pressed("select_next_card"):
		get_next_card()
	if event.is_action_pressed("select_prev_card"):
		get_prev_card()
		
func ui_update_effect_display_area():
	if player:
		#Clear First:
		for prev_ef_icon in effects_area.get_children():			
			prev_ef_icon.queue_free()

		for ef : Effect in player.get_children().filter(func(child): return child is Effect):
			if ef.effect_over == false:
				var eff_icon  = TextureRect.new()
				eff_icon.custom_minimum_size = Vector2(64,64)
				eff_icon.texture = ef.icon_texture
				effects_area.add_child(eff_icon)
			

func start_healing_particles():
	healing_particles.emitting = true
	healing_particles_timer.start()

func _on_healing_particles_timer_timeout() -> void:
	healing_particles.emitting = false
