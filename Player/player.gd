extends CharacterBody3D
class_name Player

@export_category("Mouse Control")
@export var mouse_sensitivity : float = 0.002

@export_category("Aimming")
@onready var camera : Camera3D = $Camera3D
@export var right_hand : Node3D
@export var left_hand : Node3D
@export var gun_raycast : RayCast3D

@export_category("UI")
@export var ui : UI 
@export var tracking_cam: Camera3D

var jump_velocity : float = 25.5
var movement_speed : float = 8.0
var movement_direction : Vector3 =  Vector3(0,0,0)
var gravity = 75.5
var dash_speed : float = 18.0
var money: int = 0

enum GUNS {BLASTER=0}

#Components
@export_category("Components")
@export var health_component : Health_Component

#nodes
@export_category("Sprites")
@export var gun_sprite : AnimatedSprite3D

func _ready() -> void:
	print("Player Ready ", gravity)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Globals.local_player = self
	
func _process(delta: float) -> void:
	if tracking_cam:
		tracking_cam.position = tracking_cam.position.lerp(position+Vector3(0,50,0),5*delta)

func _physics_process(delta: float) -> void:
	move(delta)
	
func _input(event):
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
			run_card(1)
	
	if event is InputEventKey:
		if Input.is_action_just_pressed("draw_card_force"):
			ui.draw_card()
		if Input.is_action_just_pressed("discard_card_force"):
			if ui.card_hand.get_child_count() > 0:
				ui.discard_card(ui.card_hand.get_children()[0])

func run_card(index):
	
	if ui.card_hand.get_child_count() > index:
		var card : Card = ui.card_hand.get_child(index)
		if card.card_ready:
			#print("Running Card: ", card.card_name)
			gun_sprite.play("shoot")
			card.use_card()

func move(delta):
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

	# Move the object and handle collisions
	move_and_slide()

func collect_coin(amount: int):
	money+=amount
	ui.get_node("Coins").text = "Money:" + str(money)
