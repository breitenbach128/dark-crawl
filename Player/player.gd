extends CharacterBody3D
class_name Player

@export_category("CharacterBody")
@export var sync_velocity := Vector3.ZERO

@export_category("Mouse Control")
@export var mouse_sensitivity : float = 0.002

@export_category("Aimming")
@export var camera : Camera3D
@export var right_hand : Node3D
@export var left_hand : Node3D
@export var gun_raycast : RayCast3D

@export_category("UI")
@export var ui : HUD 
@export var tracking_cam: Camera3D
@export var subviewport : SubViewport
@export var playernamelabel: Label3D

var jump_velocity : float = 25.5
var movement_speed : float = 8.0
var movement_direction : Vector3 =  Vector3(0,0,0)
var gravity = 75.5
var dash_speed : float = 18.0
var money: int = 0
var has_spawned : bool = false

enum GUNS {BLASTER=0}

#Components
@export_category("Components")
@export var health_component : Health_Component

#nodes
@export_category("Sprites")
@export var gun_sprite : AnimatedSprite3D

func _enter_tree():
	# 2. Set the owner's multiplayer ID
	var peer_id = str(name).to_int()
	set_multiplayer_authority(peer_id)
	print("Setting as MP authority: ",peer_id)
	if peer_id == multiplayer.get_unique_id():
		#If this is the active player instance for MP
		camera.make_current()
		var viewport_texture: ViewportTexture = subviewport.get_texture()
		ui.TopDownDisplay.texture = viewport_texture
	else:
		#Remove on UX stuff for puppets
		camera.queue_free()
		ui.queue_free()
		
	ui.mp_id_label.text = str("Multiplayer ID:",peer_id , " " , multiplayer.is_server())
	playernamelabel.text = str(peer_id)
func _ready() -> void:
	if is_multiplayer_authority():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		Globals.local_player = self
		
	
func _process(delta: float) -> void:
	if is_multiplayer_authority():
		if tracking_cam:
			tracking_cam.position = tracking_cam.position.lerp(position+Vector3(0,50,0),5*delta)

func _physics_process(delta: float) -> void:
	move(delta)
	
func _input(event):
	if is_multiplayer_authority():
		#MOUSE LOOK CODE	
		if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			# Rotate the player horizontally (Y axis)
			rotate_y(-event.relative.x * mouse_sensitivity)

			# Tilt the camera vertically (X axis)
			camera.rotate_x(-event.relative.y * mouse_sensitivity)

			# Clamp the vertical look angle so the player can't do a 360 flip
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		#escape key press
		if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
			print("Escape was pressed!")
			if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				run_card(0)
			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				run_card(1)
			if event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
				run_card(2)
		
		if event is InputEventKey:
			if Input.is_action_just_pressed("action_slot_four"):
				run_card(3)
			if Input.is_action_just_pressed("action_slot_five"):
				run_card(4)
			if Input.is_action_just_pressed("draw_card_force"):
				ui.draw_card()
			if Input.is_action_just_pressed("discard_card_force"):
				if ui.card_hand.get_child_count() > 0:
					ui.discard_card(ui.card_hand.get_children()[0])
					

#@rpc("any_peer", "call_remote", "reliable")
func run_card(index):	
	if ui.card_hand.get_child_count() > index:
		var card : Card = ui.card_hand.get_child(index)
		if card.card_ready:
			#print("Running Card: ", card.card_name)
			gun_sprite.play("shoot")
			card.use_card()

func move(delta):
	if is_multiplayer_authority():
		var input_dir: Vector2 = Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_backwards")
		var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		var speed = movement_speed
		
		if Input.is_action_pressed("dash"):
			speed = dash_speed
		if not is_on_floor():
			velocity.y -= gravity * delta
			
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_velocity
			
		# Apply velocity
		if direction != Vector3.ZERO:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
		
		#Load to sync_velocity for replication	
		sync_velocity = velocity
	else:
		#Network Player, so sync position and velocity
		velocity = sync_velocity
		
	# Move the object and handle collisions
	move_and_slide()

func collect_coin(amount: int):
	if is_multiplayer_authority():
		money+=amount
		ui.get_node("Coins").text = "Money:" + str(money)

func player_add_effect(new_effect : Effect):
		add_child(new_effect)
		new_effect.set_target(self)
		new_effect.apply_effects(1)
		new_effect.effect_end.connect(player_remove_effect)
		ui.ui_update_effect_display_area()

func player_remove_effect():
	ui.ui_update_effect_display_area()
