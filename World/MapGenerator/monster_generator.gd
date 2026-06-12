extends Node
class_name MonsterGenerator

@export var dungeon : DungeonGenerator
@export var monster_spawns : Array[Resource]
@export var total_spawns : int = 4
@export var monster_holder : Node3D

func _ready() -> void:
	pass

func spawn_monsters():
	print("Spawning monsters")
	for spawn in range(0,total_spawns):
		var new_monster = monster_spawns.pick_random().instantiate()
		monster_holder.add_child(new_monster)
		var spawn_location_room : RoomData = dungeon.room_list.pick_random()
		var spawn_cell = spawn_location_room.get_random_world_cell_in_room()
		var spawn_location = spawn_cell * dungeon.tile_scale
		print("Room:", spawn_location_room.room_id," ", spawn_cell)
		new_monster.position = Vector3(spawn_location.x,2,spawn_location.y)
	
