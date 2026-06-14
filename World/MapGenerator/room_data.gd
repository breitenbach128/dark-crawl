extends Resource
class_name RoomData

var room_id : int = -1 #ID of the room for reference
var rect : Rect2i = Rect2i(0,0,1,1)
var exit_locations : Array[Vector2i] = []
## Mark true if room has at least one path to another room
var is_connected: bool = false 
var connected_room_ids : Array[int] = []

## Gets all the world cells on the outside edge of the rect2 for this room
func get_room_perimeter_world_cells():
	var cells : Array[Vector2i]=[]
	for j in range(0,rect.size.y):
		for i in range(0,rect.size.x):
			if (i==0 || j==0 || i==rect.size.x-1 || j==rect.size.y-1):
				cells.append(Vector2i(i,j)+rect.position)
	return cells

## Returns a random cell from within the room
func get_random_world_cell_in_room():
	var cell_x = randi_range(rect.position.x,rect.position.x+rect.size.x-1)
	var cell_y = randi_range(rect.position.y,rect.position.y+rect.size.y-1)
	return Vector2i(cell_x,cell_y)
	
	
