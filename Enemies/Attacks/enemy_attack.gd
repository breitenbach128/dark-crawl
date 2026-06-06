extends Node3D
class_name EnemyAttack

@export_category("Parameters")
@export var attack_name : String = "Attack"
@export var attack_damage : Dictionary = { #[min,max]
	"physical": [1,8],
	"fire": [0,0],
	"force": [0,0],
	"shock": [0,0],
	"cold": [0,0],
	"soul": [0,0]
}

enum ATTACK_TYPE {MELEE, RANGED}

@export var selection_chance : float = 1.0 #100% by default, but can be reduced
@export var movement_speed : float = 8.0
@export var attack_type : ATTACK_TYPE = ATTACK_TYPE.RANGED

var velocity = Vector3(0,0,0)

func _physics_process(delta: float) -> void:
	position += velocity * delta

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		#print(attack_name, " hit player")
		if body.health_component:
			body.health_component.take_damage(attack_damage)
		call_deferred("queue_free")


func _on_lifespan_timeout() -> void:
	call_deferred("queue_free")
