extends Node3D
class_name Effect

#Applies an effect to the target
@export var effect_name : String = "Effect"
@export var icon_texture : Resource
@export var duration_count : int = 0 #How many ticks before this expires?
@export var duration_tick_time : int = 0 #How long is each tick?
@export var reapply_on_tick : bool = false #Does this effect happen on each tick?
@export var health_change : int = 0
@export var move_speed : int = 0
@export var restistance : Dictionary = {
	"physical": 0.0,
	"fire": 0.0,
	"force": 0.0,
	"shock": 0.0,
	"cold": 0.0,
	"soul": 0.0
}
@export var attack_damage_direct : Dictionary = { #[min,max]
	"physical": [0,0],
	"fire": [0,0],
	"force": [0,0],
	"shock": [0,0],
	"cold": [0,0],
	"soul": [0,0]
}
@export var attack_damage_percent : Dictionary = { #[min,max]
	"physical": 0.0,
	"fire": 0.0,
	"force": 0.0,
	"shock": 0.0,
	"cold": 0.0,
	"soul": 0.0
}
@export var area_effect : float = 0.0 #in meters. Does this create an area affect
@export var mutli_projectile : int = 0 #Adds more projectiles and an angle from origin
@export var spread_projectiles : int = 0 #Adds more projectiles to the left and right, but in parallel
@export var card_cooldown : float = 0.0 #Modifies the global card cooldown rate (Rate of fire)
