extends Area3D

@export var dungeon : DungeonGenerator

var buffer_space : float = 40.0

func _ready() -> void:
	#20% more space
	var map_size_x = (dungeon.map_area.size.x*dungeon.tile_size.x*dungeon.tile_scale.x)+buffer_space
	var map_size_y = (dungeon.map_area.size.y*dungeon.tile_size.x*dungeon.tile_scale.x)+buffer_space
	$CollisionShape3D.shape.size = Vector3(map_size_x,1,map_size_y)
	position = Vector3(map_size_x/2,-10,map_size_y/2) - Vector3(buffer_space/2,0,buffer_space/2) + Vector3(randf_range(-.5,.5),0,randf_range(-.5,.5))



func _on_body_entered(body: Node3D) -> void:
	#print("Killzone: ",body)
	if body is Player:
		body.position = get_node("/root/Main/Rooms").get_child(0).position
		
