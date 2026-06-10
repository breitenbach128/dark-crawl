extends Resource
class_name RoomData

var room_id : int = -1 #ID of the room for reference
var position : Vector2i = Vector2i(0,0)
var room_size : Vector2i = Vector2i(4,4)
var exit_locations : Array[Vector2i] = []
