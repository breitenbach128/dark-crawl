extends Node3D
class_name Effect

#Applies an effect to the target
@export var effect_name : String = "Effect"
@export var icon_texture : Resource
@export var duration_count : int = 0 #How many ticks before this expires?
var duration_ticks : int  = 0
@export var duration_tick_time : int = 0 #How long is each tick?
@export var duration_timer : Timer
@export var reapply_on_tick : bool = false #Does this effect happen on each tick?
@export var heal : Array[int] = [0,0]
@export var move_speed : int = 0
@export var take_damage : Dictionary = { #[min,max]
	"physical": [0,0],
	"fire": [0,0],
	"force": [0,0],
	"shock": [0,0],
	"cold": [0,0],
	"soul": [0,0]
}
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
@export var blast_projectiles : int = 0 #Create these projectiles evenly spread shooting outward from impact
@export var mutli_projectile : int = 0 #Adds more projectiles and an angle from origin
@export var spread_projectiles : int = 0 #Adds more projectiles to the left and right, but in parallel
@export var chain_projectiles : int = 0 #Makes projectiles that hops X times
@export var card_cooldown : float = 0.0 #Modifies the global card cooldown rate (Rate of fire)
var target
var effect_over : bool = false

#Signals
signal effect_end
signal effect_begin

## For active effects, this runs the action
func activate_effect():
	if duration_count > 0 && duration_ticks == 0:
		duration_timer.wait_time = duration_tick_time
		duration_timer.start()
	
	if blast_projectiles > 0:
		if get_parent() is Attack:
			var parent_attack : Attack = get_parent()
			#Get attack angle, then divide the 360 by the number of projectiles
			#Using the angle as the starting point, add that amount of deg and then file off an 
			#equal velocity projectile in another direction			
			var rot_step : float = (2*PI) / blast_projectiles
			for ds in range(0,blast_projectiles):
				var dir: Vector3 = Vector3(cos(ds*rot_step), 0.0, sin(ds*rot_step))
				var final_velocity: Vector3 = dir*parent_attack.projectile_speed
				var new_attack : Attack = load(parent_attack.scene_file_path).instantiate()
				get_tree().current_scene.get_node("Attacks").add_child(new_attack,true)
				new_attack.attack(parent_attack.attack_damage)
				new_attack.position = parent_attack.position + (dir)
				new_attack.linear_velocity = final_velocity
				new_attack.look_at(parent_attack.position + final_velocity, Vector3.UP)

func set_target(t):
	target = t
## For passive effects, such as modifications to health, this changes the base state
func apply_effects(mod : int):
	effect_begin.emit()
	#print("Applying Effect, ", effect_name, " " , mod, " duration_count ", duration_count)
	if duration_count > 0 && duration_ticks == 0:
		duration_timer.wait_time = duration_tick_time
		duration_timer.start()
	if target.has_node("HealthComponent"):
		var hcomp : Health_Component = target.get_node("HealthComponent")
		#Apply Restistances
		for dtype in restistance:
			hcomp.restistance[dtype] += (mod*restistance[dtype])
		#Apply Heal
		if mod > 0:
			if heal[1] > 0: #max on range is greather than zero
				hcomp.heal(randi_range(heal[0],heal[1]))
		
## For passive effects, such as modifications to health, this removes the mod value
func remove_effects():
	apply_effects(-1)
	effect_over = true
	effect_end.emit()
	queue_free()



func _on_duration_timeout() -> void:
	#print("Timeout: ", duration_ticks, " ", duration_count)
	if duration_ticks < duration_count:
		duration_ticks+=1
		duration_timer.start()
	else:
		remove_effects()
		
