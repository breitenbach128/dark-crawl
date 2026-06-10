extends Node

class_name DungeonGenerator

var astar_grid : AStarGrid2D = AStarGrid2D.new()

var map_size : Rect2i = Rect2i(0,0,10,10)
var map_tiles : Array = []
var tile_size: Vector2i = Vector2i(5,5) # 5m x 5m
var room_list : Array[RoomData] = []
var room_attempt_count : int = 3

func init_grid() -> void:
	astar_grid.region = map_size
	astar_grid.cell_size = tile_size
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER # Disable diagonals
	astar_grid.heuristic = AStarGrid2D.HEURISTIC_MANHATTAN     # Best for 4-way grids
	astar_grid.update() #Required after change

func set_cell(cell: CellData):
	astar_grid.set_point_solid(cell.position, cell.type != CellData.TILETYPE.EMPTY)

		
func _ready() -> void:
	#Setup the astar grid
	init_grid()	
	#Create map of empty tiles
	for j in range(0,map_size.size.y):
		for i in range(0,map_size.size.x):
			var cell = CellData.new()
			cell.type = CellData.TILETYPE.EMPTY
			cell.position = Vector2i(i,j)
			map_tiles[i][j] = cell

func create_rooms():
	#Create X rooms of various sizes. 
	for i in range(0,3):
		#Create a room of random size, no bigger than half the map
		var room = RoomData.new()
		room.room_size = Vector2i(randi_range(1,floor(map_size.size.x/2)),randi_range(1,floor(map_size.size.y/2)))
		var check_limit : int = 50 #Kill the loop after 50 attempts
		var position_found : bool = false
		while check_limit > 0 && !position_found:
			check_limit -= 1 #Safety Net
			room.position = Vector2i(randi_range(0,map_size.size.x),randi_range(0,map_size.size.y))
			is_room_position_valid(room)
	#carve them into the space
	
	#Pick exits on each room and connect to the closest room exit
	pass

func is_room_position_valid(room : RoomData):
	
	return false
