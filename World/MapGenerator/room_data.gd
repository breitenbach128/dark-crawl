extends Resource
class_name RoomData

#Assumptions
#Rooms start at 0,0 (top down) and grow positive

@export var room_size : Vector2i = Vector2i(4,4)
#Exit locations are marked to show where they leave.
#0,-1 leaves to the north from the 0,0 position
@export var exit_locations : Array[Vector2i] = [Vector2i(0,-1)]
@export var room_scene : Resource
