extends Node
class_name MapGenerator

@export var world_size : Vector2i = Vector2i(10,10)
@export var room_list : Array[RoomData] = []
@export var max_depth : int = 5
@export var rooms_holder : Node3D

#5x5 tiles
var tile_size : Vector2i = Vector2i(15,15)
#BUG: SCALING ISSUE. THE ACTUAL MESH IS 3x this size, so 5 was correct if I did not scale.
#However, I did and now the meshes have are at 15 for the 5x5 rooms
var current_tile_position = Vector2i(0,0)
var current_depth : int = 0
var current_room : RoomData = null
var prev_room : RoomData = null
#Get list of all rooms and pick random starting room.

#Foreach exit, find a room with a matching exit that can connect
#if found, mark exit as connected and move into the new room
	# Go into that room, and pick an unconnected exit and repeat until no exits remain
	#track depth and if depth reaches max, mark this room in a list.
#at the end, pick one of the max distance rooms and set it as the level exit

#Always start at 0,0
func _ready() -> void:
	current_room = room_list.pick_random()
	print("Starting Room Generation")
	generate_room(current_tile_position)

func generate_room(tile_pos : Vector2i):
	#Add the room to the scene
	var gen_room = current_room.room_scene.instantiate()
	rooms_holder.add_child(gen_room)
	var gen_room_position_2d : Vector2i = tile_pos * tile_size
	var gen_room_position_3d : Vector3 = Vector3(gen_room_position_2d.x,0,gen_room_position_2d.y)
	print("New Room Position: ", gen_room_position_3d)
	gen_room.position = gen_room_position_3d
	
	current_depth+= 1
	if current_depth == max_depth:
		return
	#Foreach Exit
	for exit in current_room.exit_locations:
		print("Checking Exit in current room, ",current_room.room_scene, "depth", current_depth)
		#Find room in list that has compatible exits
		var good_room : Array[RoomData] = room_list.filter(filter_rooms_exits.bind(exit))
		if good_room.size() > 0:
			
			if exit.y == current_room.room_size.y:
				tile_pos += Vector2i(0,1)
			if exit.y == -1:
				tile_pos += Vector2i(0,-1)
			if exit.x == current_room.room_size.x:
				tile_pos += Vector2i(1,0)
			if exit.x == -1:
				tile_pos += Vector2i(-1,0)
			prev_room = current_room
			current_room = good_room[0]
			print("Found Connectable room ",good_room[0].room_scene, " new tile pos: ", tile_pos)
			generate_room(tile_pos)


func filter_rooms_exits(targ_room : RoomData,curr_exit :Vector2i):
	for targ_exit_location : Vector2i in targ_room.exit_locations:
		if curr_exit.x == -1: #left side, match row
			if targ_exit_location.x == targ_room.room_size.x && targ_exit_location.y == curr_exit.y:
				if targ_room != prev_room:
					return true
		if curr_exit.x == current_room.room_size.x: #right side, match row
			if targ_exit_location.x == -1 && targ_exit_location.y == curr_exit.y:
				if targ_room != prev_room:
					return true
		if curr_exit.y == -1: #Top Side (-z), match column
			if targ_exit_location.y == current_room.room_size.y && targ_exit_location.x == curr_exit.x:
				if targ_room != prev_room:
					return true
		if curr_exit.y == current_room.room_size.y: #Bottom Side (z), match column
			if targ_exit_location.y == -1 && targ_exit_location.x == curr_exit.x:
				if targ_room != prev_room:
					return true
	
