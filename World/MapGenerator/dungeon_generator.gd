extends Node

class_name DungeonGenerator


@export var tile_inst : Resource
@export var wall_inst : Resource
@export var root_room_node : Node3D
@export var player: Player

var astar_grid : AStarGrid2D = AStarGrid2D.new()
var map_area : Rect2i = Rect2i(0,0,20,20)
var map_tiles : Array = []
var tile_size: Vector2i = Vector2i(1,1) # 1m x 1m
var room_tile_size : Vector2i = Vector2i(5,5) #5m x 5m Room Size in tiles
var room_max_size : Vector2 = Vector2i(3,3) #This is multiplied by the tile size to get the real tile size of the room
var room_list : Array[RoomData] = []
var room_attempt_count : int = 10

func init_grid() -> void:
	astar_grid.region = map_area
	astar_grid.cell_size = tile_size
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER # Disable diagonals
	astar_grid.default_estimate_heuristic  = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.update() #Required after change

func set_cell(cell: CellData):
	astar_grid.set_point_solid(cell.position, cell.type != CellData.TILETYPE.EMPTY)

		
func _ready() -> void:
	#Setup the astar grid
	init_grid()	
	#Create map of empty tiles
	for j in range(0,map_area.size.y):
		var row_array = []
		for i in range(0,map_area.size.x):
			var cell = CellData.new()
			cell.type = CellData.TILETYPE.EMPTY
			cell.position = Vector2i(i,j)
			#print(i," ",j)
			row_array.append(cell)
		map_tiles.append(row_array)
	
	create_rooms()

func create_rooms():
	#Create X rooms of various sizes. 
	for rc in range(0,room_attempt_count):
		
		#Create a room of random size, no bigger than half the map
		var room = RoomData.new()
		var new_room_size = Vector2i(Vector2i(randi_range(1,room_max_size.x),randi_range(1,room_max_size.y)))
		room.rect = Rect2i(Vector2i(0,0),new_room_size*room_tile_size)
		#print("Creating Room ", rc, " size: ", room.rect)
		var check_limit : int = 50 #Kill the loop after 50 attempts
		var position_found : bool = false
		while check_limit > 0 && !position_found:
			check_limit -= 1 #Safety Net
			#try a position
			room.rect.position.x = randi_range(0,map_area.size.x)
			room.rect.position.y = randi_range(0,map_area.size.y)
			if is_room_position_valid(room):
				room_list.append(room)
				position_found = true
				print("Room position was valid: ",rc," ", room.rect)
				#carve them into the space
				for ry in range(0,room.rect.size.y):
					for rx in range(0,room.rect.size.x):
						var cell_x = rx+room.rect.position.x
						var cell_y = ry+room.rect.position.y
						map_tiles[cell_x][cell_y].type = CellData.TILETYPE.TILE
						set_cell(map_tiles[cell_x][cell_y])
						#Create instance tile every [room tilesize] tiles
						if Vector2i(rx,ry) % 5 == Vector2i(0,0):
							print("Room Tile Create at ,", str(Vector2i(rx,ry)))
							var tile = tile_inst.instantiate()
							root_room_node.add_child(tile)
							#Room is 2.5 offset to center, but wall is .5, so that reduces it to 2
							tile.position = Vector3(cell_x*tile_size.x+2,0,cell_y*tile_size.y+2)
							tile.get_node("Label3D").text = str(tile.position)
	for j in range(0,map_area.size.y):
		var strrow = ""
		for i in range(0,map_area.size.x):
			strrow+= str(map_tiles[i][j].type," , ")
		print("ROW:", strrow)
	#Pick exits on each room and connect to the closest room exit	
	
	#Make walls. ANY TILE TOUCHING A WALL (Diagonal included) make a wall
	create_walls()
	#Move player to first room
	var first_room_center : Vector2 = room_list[0].rect.get_center()
	print("start point: ", Vector3(first_room_center.x*tile_size.x,10,first_room_center.y*tile_size.y))
	player.position += Vector3(first_room_center.x*tile_size.x,10,first_room_center.y*tile_size.y)

func create_walls():
	for j in range(0,map_area.size.y):
		for i in range(0,map_area.size.x):
			if map_tiles[i][j].type == CellData.TILETYPE.EMPTY:
				#Check all 8 positions
				var directions = [Vector2(-1,0),Vector2(-1,-1),Vector2(0,-1),Vector2(1,-1),Vector2(1,0),Vector2(1,1),Vector2(0,1),Vector2(-1,1)]
				var make_wall : bool = false
				for dir : Vector2 in directions:
					var dir_point : Vector2 = dir+Vector2(i,j)
					if map_area.has_point(dir_point):
						if map_tiles[dir_point.x][dir_point.y].type == CellData.TILETYPE.TILE:
							make_wall = true
				if make_wall:
					var new_wall : Wall = wall_inst.instantiate()
					root_room_node.add_child(new_wall)
					new_wall.position = Vector3(i*tile_size.x,1,j*tile_size.y)
					new_wall.get_node("Label3D").text = str(new_wall.position)
				
func is_room_position_valid(room : RoomData):
	if(room.rect.position.x > 0 && 
	room.rect.position.y > 0 && 
	room.rect.position.x+room.rect.size.x < map_area.size.x &&
	room.rect.position.y+room.rect.size.y < map_area.size.y):
		#Within Bounds of map
		for r in room_list:
			#Ensure it does not intersect another room. It can touch
			if room.rect.intersects(r.rect):
				return false
		return true
	return false
