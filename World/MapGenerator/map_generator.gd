extends Node
class_name MapGenerator

@export var room_list : Array[RoomData] = []
@export var max_depth : int = 5
@export var rooms_holder : Node3D
#Get list of all rooms and pick random starting room.

#Foreach exit, find a room with a matching exit that can connect
#if found, mark exit as connected and move into the new room
	# Go into that room, and pick an unconnected exit and repeat until no exits remain
	#track depth and if depth reaches max, mark this room in a list.
#at the end, pick one of the max distance rooms and set it as the level exit
