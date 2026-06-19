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
@export var multiplayer_spawner_players: MultiplayerSpawner

func _ready() -> void:
	print("Main Ready")	
	multiplayer_spawner_players.spawn_function = spawn_player

func set_player_spawn_locations(p):
	p.has_spawned = true
	var first_room_center : Vector2 = dungeon_creator.room_list[0].rect.get_center()
	print("start point: for player ", p.name, " ", Vector3(first_room_center.x*dungeon_creator.tile_scale.x,10,first_room_center.y*dungeon_creator.tile_scale.y))
	p.position += Vector3(first_room_center.x*dungeon_creator.tile_scale.x,10,first_room_center.y*dungeon_creator.tile_scale.y) + Vector3(randf_range(-.5,.5),0,randf_range(-.5,.5))

func spawn_player(id : int):
	var new_player = load(Network.PLAYER_RES).instantiate()
	new_player.name = str(id)
	new_player.set_multiplayer_authority(id)
	players_root.add_child(new_player)
	if multiplayer:
		print("Host: ",multiplayer.get_unique_id()," player added to main, :", id)
	else:
		print("Host: ","localhost"," player added to main, :", id)
	return new_player

func _on_multiplayer_spawner_players_spawned(p: Player) -> void:
	print("Spawned Player, " , p)


	
