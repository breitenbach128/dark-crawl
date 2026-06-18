extends Node3D
class_name MainScene

@export var structure_root : Node3D
@export var sound_root : Node3D
@export var attacks_root : Node3D
@export var enemies_root : Node3D
@export var uieffects_root : Node3D
@export var pickups_root : Node3D
@export var players_root : Node3D
@export var dungeon_creator: DungeonGenerator

func _ready() -> void:
	Globals.current_main = self
	if Globals.local_player_id != null:
		var player = load(Network.PLAYER_SCENE).instantiate()
		player.name = str(Globals.local_player_id)
		players_root.add_child(player)
		print("player added to main, :", Globals.local_player_id)
		set_player_spawn_locations(player)
		
func set_player_spawn_locations(p):	
		var first_room_center : Vector2 = dungeon_creator.room_list[0].rect.get_center()
		print("start point: ", Vector3(first_room_center.x*dungeon_creator.tile_scale.x,10,first_room_center.y*dungeon_creator.tile_scale.y))
		p.position += Vector3(first_room_center.x*dungeon_creator.tile_scale.x,10,first_room_center.y*dungeon_creator.tile_scale.y) + Vector3(randf_range(-.5,.5),0,randf_range(-.5,.5))
	

	
