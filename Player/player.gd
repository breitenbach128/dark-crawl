extends CharacterBody3D
class_name Player

@export_category("CharacterBody")
@export var sync_velocity := Vector3.ZERO
@export var sprite : Sprite3D

@export_category("Mouse Control")
@export var mouse_sensitivity : float = 0.002

@export_category("Aimming")
@export var camera : Camera3D
@export var right_hand : Node3D
@export var center_aim : Node3D
@export var left_hand : Node3D
@export var gun_raycast : RayCast3D

@export_category("UI")
@export var ui : HUD 
@export var tracking_cam: Camera3D
@export var subviewport : SubViewport
@export var playernamelabel: Label3D
@export var client_cards : Control
@export var HealthBar : HealthBar3D

var health_bar_display_tick : float = 0.0
var health_bar_display_tick_max : float = 0.5 #Seconds

var jump_velocity : float = 25.5
var movement_speed : float = 8.0
var movement_direction : Vector3 =  Vector3(0,0,0)
var gravity = 75.5
var dash_speed : float = 18.0
#MP Sync Setters
@export_category("Setters")
@export var money: int = 0 :
	set(value):
		money = value
		money_changed.emit()
	
var has_spawned : bool = false

enum GUNS {BLASTER=0}
signal money_changed
#Components
@export_category("Components")
@export var health_component : Health_Component

#nodes
@export_category("Sprites")
@export var gun_sprite : AnimatedSprite3D
@export var card_manager: CardManager

#testing
@export_category("Testing")
@export var health : int = 1:
	set(value):
		health = value
		print("health changed")
		
func _enter_tree():
	#Set the owner's multiplayer ID
	var peer_id = str(name).to_int()
	set_multiplayer_authority(peer_id)
	print("Setting as MP authority: ",peer_id)
	if peer_id == multiplayer.get_unique_id():
		Globals.local_player = self
		#Local Player UI stuff
		camera.make_current()
		var viewport_texture: ViewportTexture = subviewport.get_texture()
		ui.TopDownDisplay.texture = viewport_texture		
		ui.mp_id_label.text = str("Multiplayer ID:",peer_id , " " , multiplayer.is_server())		
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if peer_id != 1:
			CardManager.server_receive_client_ready_status.rpc_id(1)
	else:
		#Remove on UX stuff for puppets
		print("Puppet: removing UI")
		#camera.free()
		ui.free()

	if multiplayer.is_server():
		print("Player UI? ", ui)
		CardManager.init_host_card_manager(self)

	playernamelabel.text = str(peer_id)
func _ready() -> void:
	if health_component:
		health_component.health_changed.connect(player_update_hp_bar)
	if ui:
		money_changed.connect(func(): ui.get_node("Coins").text = "Money:" + str(money))

func player_update_hp_bar(hp,hpmax,amount):
	HealthBar.max = hpmax
	HealthBar.update_bar_value(hp)

func player_show_hp_bar():
	if HealthBar.visible == false:
		HealthBar.visible = true
	health_bar_display_tick = health_bar_display_tick_max
		

func _process(delta: float) -> void:
	if HealthBar.visible == true:
		health_bar_display_tick-= delta
		if health_bar_display_tick <= 0:
			HealthBar.visible = false
		
	if is_multiplayer_authority():
		if tracking_cam:
			tracking_cam.position = tracking_cam.position.lerp(position+Vector3(0,50,0),5*delta)
		if gun_raycast.is_colliding(): 
			var collider = gun_raycast.get_collider()
			if collider is Player:
				collider.player_show_hp_bar()
				
	else:
		if Globals.local_player:
			var player_camera : Camera3D = Globals.local_player.camera
			# Get the camera's local forward vector in 3D
			var forward3d: Vector3 = -global_transform.basis.z
			# Convert to a 2D vector using the X and Z axes (top-down)
			var dir2d = Vector2(forward3d.x, forward3d.z).normalized()
			# Calculate the angle between the character's movement and the camera's position
			var pos_2d = Vector2(global_position.x,global_position.z)
			var pos_2d_camera = Vector2(player_camera.global_position.x,player_camera.global_position.z)
			var angle_to_camera = pos_2d.angle_to_point(pos_2d_camera)
			
			# Map the angle to one of the 4 directions (0 to 3)
			var angle_diff = dir2d.angle() - angle_to_camera
			var sector = wrapi(int(snappedf(angle_diff, PI/4) / (PI/4)), 0, 8)
			
			# Play the corresponding animation (e.g., Walk_Right)
			sprite.frame = sector

func _physics_process(delta: float) -> void:
	move(delta)
	
func _input(event):
	#if not DisplayServer.window_is_focused():
		#return
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
				if ui.is_drawing_hand == false: CardManager.run_card.rpc_id(1,0)
			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				if ui.is_drawing_hand == false: CardManager.run_card.rpc_id(1,1)
			if event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
				if ui.is_drawing_hand == false: CardManager.run_card.rpc_id(1,2)
		
		if event is InputEventKey:
			if Input.is_action_just_pressed("action_slot_four"):
				if ui.is_drawing_hand == false: CardManager.run_card.rpc_id(1,3)
			if Input.is_action_just_pressed("action_slot_five"):
				if ui.is_drawing_hand == false: CardManager.run_card.rpc_id(1,4)
			if Input.is_action_just_pressed("hurt_player_clients"):
				for client in Globals.current_main.players_root.get_children():
					if client is Player:
						if client.name.to_int() != -1:
							var attack_damage : Dictionary = { #[min,max]
								"physical": [1,4],
								"fire": [0,0],
								"force": [0,0],
								"shock": [0,0],
								"cold": [0,0],
								"soul": [0,0]
							}
							client.health_component.take_damage(attack_damage)

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


## Server Adds effect to player
func player_add_effect(new_effect : Effect):
	print("Effect Added to player: ", name, " on client: ", multiplayer.get_unique_id())
	add_child(new_effect)
	new_effect.set_target(self)
	new_effect.apply_effects(1)
	new_effect.effect_end.connect(player_remove_effect)
	if ui:
		ui.update_effect_display_area()
	client_player_add_effect.rpc(name.to_int(),new_effect.scene_file_path)
		
@rpc("any_peer","call_remote","reliable")
func client_player_add_effect(pid,effect_scene_path):
	for client in Globals.current_main.players_root.get_children():
		if client is Player:
			if client.name.to_int() == pid:
				print("Client Rcv: Player Add Effect: ", effect_scene_path)
				var new_effect: Effect = load(effect_scene_path).instantiate()
				client.add_child(new_effect)
				new_effect.set_target(self)
				new_effect.apply_effects(1)
				if client.ui:
					client.ui.update_effect_display_area()
					new_effect.effect_end.connect(client.player_remove_effect)

func player_remove_effect():
	if ui:
		ui.update_effect_display_area()


func _on_multiplayer_synchronizer_delta_synchronized() -> void:
	if is_multiplayer_authority():
			return
	print("client health", health_component.health)
