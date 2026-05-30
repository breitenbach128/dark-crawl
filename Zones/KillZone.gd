extends Node



func _ready() -> void:
	pass



func _on_body_entered(body: Node3D) -> void:
	print("body: ",body)
	if body is Player:
		body.position = get_node("/root/Main/Spawn").position
		
