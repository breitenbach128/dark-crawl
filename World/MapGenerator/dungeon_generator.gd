extends Node

class_name DungeonGenerator


@export var tile_inst : Resource
@export var tile_1x1_inst : Array[Resource]
@export var wall_inst : Resource
@export var root_room_node : Node3D
@export var player: Player
@export var monster_spawner : MonsterGenerator

var debug_status = false
var astar_grid : AStarGrid2D = AStarGrid2D.new()
var map_area : Rect2i = Rect2i(0,0,20,20)
var map_tiles : Array = []
var tile_scale : Vector2i = Vector2i(2,2) #Give the player more space
var tile_size: Vector2i = Vector2i(1,1) # 1m x 1m
var room_tile_size : Vector2i = Vector2i(5,5) #5m x 5m Room Size in tiles
var room_max_size : Vector2 = Vector2i(1,1) #This is multiplied by the tile size to get the real tile size of the room
var room_list : Array[RoomData] = []
var room_attempt_count : int = 100

signal dungeon_created

func init_grid() -> void:
	astar_grid.region = map_area
	astar_grid.cell_size = tile_size
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER # Disable diagonals
	astar_grid.default_estimate_heuristic  = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.update() #Required after change

func set_cell(p: Vector2i, t):
	#print("set cell:" ,p)
	astar_grid.set_point_solid(p, t != CellData.TILETYPE.EMPTY)

		
func _ready() -> void:
	#Setup the astar grid
	init_grid()	
	#Create map of empty tiles
	for i in range(0,map_area.size.x):
		var row_array :Array = []
		for j in range(0,map_area.size.y):
			var cell = CellData.new()
			cell.type = CellData.TILETYPE.EMPTY
			cell.position = Vector2i(i,j)
			row_array.append(cell)
		map_tiles.append(row_array)
	create_rooms()

func create_rooms():
	#Create X rooms of various sizes. 
	var new_room_id = 0
	for rc in range(0,room_attempt_count):
		
		#Create a room of random size, no bigger than half the map
		var room = RoomData.new()
		var new_room_size = Vector2i(randi_range(1,room_max_size.x),randi_range(1,room_max_size.y))
		room.rect = Rect2i(Vector2i(0,0),new_room_size*room_tile_size)
		#print("Creating Room ", rc, " size: ", room.rect)
		var check_limit : int = 150 #Kill the loop after 50 attempts
		var position_found : bool = false
		while check_limit > 0 && !position_found:
			check_limit -= 1 #Safety Net
			#try a position
			room.rect.position.x = randi_range(0,map_area.size.x)
			room.rect.position.y = randi_range(0,map_area.size.y)
			if is_room_position_valid(room):
				room.room_id = new_room_id
				new_room_id+=1
				room_list.append(room)
				position_found = true
				print("Room position was valid: ",rc," ", room.rect)
				#carve them into the space
				for rx in range(0,room.rect.size.x):
					for ry in range(0,room.rect.size.y):
						var cell_x = rx+room.rect.position.x
						var cell_y = ry+room.rect.position.y
						map_tiles[cell_x][cell_y].type = CellData.TILETYPE.TILE
						set_cell(Vector2i(cell_x,cell_y),CellData.TILETYPE.TILE)
						#Create instance tile every [room tilesize] tiles
						if Vector2i(rx,ry) % 5 == Vector2i(0,0):
							print("Room Tile Create at ,", str(Vector2i(rx,ry)))
							var tile : MeshInstance3D= tile_inst.instantiate()
							var mesh_offset = tile.mesh.size/2
							root_room_node.add_child(tile)
							#Room is 2.5 offset to center, but wall is .5, so that reduces it to 2
							tile.position = Vector3(cell_x*tile_scale.x,0,cell_y*tile_scale.y)  + mesh_offset
							tile.get_node("Label3D").text = str(tile.position)

	#Pick exits on each room and connect to the closest room exit	
	create_exits()
	#Make walls. ANY TILE TOUCHING A WALL (Diagonal included) make a wall
	create_walls()
	#Create wall along edge of map
	
	#DEBUG ASTAR MAP
	var astardebug = astar_grid.get_point_data_in_region(map_area)

	#DEBUG MAP #actually, use the astar debug ID vector value to compare

	if debug_status:
		for j in range(0,map_area.size.y):
			var strrow = ""
			for i in range(0,map_area.size.x):
				var astarstatus = astardebug.filter(func(a): return a.id == Vector2i(i,j))
				var s = "f"
				if astarstatus[0].solid:
					s = "t"
				strrow+= str(map_tiles[i][j].type,"-",s,"-",i,"x",j,",")
			print("R:", strrow)
	#Move player to first room
	var first_room_center : Vector2 = room_list[0].rect.get_center()
	print("start point: ", Vector3(first_room_center.x*tile_scale.x,10,first_room_center.y*tile_scale.y))
	player.position += Vector3(first_room_center.x*tile_scale.x,10,first_room_center.y*tile_scale.y)
	
	monster_spawner.spawn_monsters()
	
func create_exits():
	var pcount=0
	for r in room_list:
		var edge_positions :Dictionary= {
			"top":{"delta":Vector2i(0,-1),"points":[]},
			"bottom":{"delta":Vector2i(0,1),"points":[]},
			"left":{"delta":Vector2i(-1,0),"points":[]},
			"right":{"delta":Vector2i(0,1),"points":[]}
			}
		#Get edge positions
		for ey in range(0,r.rect.size.y):
			for ex in range(0,r.rect.size.x):
				#Skip corners
				if (
					!(ey==0 && ex == 0) || 
					!(ey==r.rect.size.y-1 && ex == r.rect.size.x-1) ||
					!(ey==r.rect.size.y-1 && ex == 0) ||
					!(ey==0 && ex == r.rect.size.x-1)
				):
					if ex == 0: 
						edge_positions.left.points.append(Vector2i(ex,ey))
					if ey == 0:
						edge_positions.top.points.append(Vector2i(ex,ey)) 
					if ex == r.rect.size.x-1:
						edge_positions.right.points.append(Vector2i(ex,ey)) 
					if ey == r.rect.size.y-1:
						edge_positions.bottom.points.append(Vector2i(ex,ey))

		#Pick 1 exit positions
		var edge_directions = ["top","bottom","left","right"]
		for pick in range(0,randi_range(1,4)):
			var edge_dir = edge_directions.pick_random()
			
			var edge_tile = r.rect.position + edge_positions[edge_dir].points.pick_random() + edge_positions[edge_dir].delta
			
			#Find closest room tile to exit position
			var target_tile = find_closest_room_tile_by_tile(edge_tile,r)
			#print("exit tile and target tile ", edge_tile, " ", target_tile)
			#match side to side, so right side goes to left side, etc.
			#pick random from both sides.
			if target_tile:
				#Get a path between the two
				var path= astar_grid.get_point_path(edge_tile,target_tile,true)	
				#print("Path : ",path)		
				#Create tiles on that path
				pcount+=1
				for p in path:
					map_tiles[p.x][p.y].type = CellData.TILETYPE.HALLWAY
					create_tile_mesh(tile_1x1_inst.pick_random(),Vector2i(p.x,p.y),str(pcount),false)
					
func create_tile_mesh(res, p, text, overlap:bool):
	var tile : MeshInstance3D= res.instantiate()
	var mesh_offset = tile.mesh.size/2
	if overlap == false:
		#Check if mesh will have a mesh at the same position
		for c in root_room_node.get_children():
			if c.position == Vector3(p.x*tile_scale.x,0,p.y*tile_scale.y)  + mesh_offset:
				tile.queue_free()
				return 
	root_room_node.add_child(tile)
	#Room is 2.5 offset to center, but wall is .5, so that reduces it to 2
	tile.position = Vector3(p.x*tile_scale.x,0,p.y*tile_scale.y)  + mesh_offset
	tile.get_node("Label3D").text = str(text)
	
func find_closest_room_tile_by_tile(src_tile : Vector2i, src_room: RoomData):
	#Search from a tile for the room with the closest tile
	var dis = INF
	var close_tile
	for r in room_list.filter(func(r): return r.room_id != src_room.room_id):
		for ey in range(0,r.rect.size.y):
			for ex in range(0,r.rect.size.x):
				var rm_tile = Vector2(r.rect.position.x+ex,r.rect.position.y+ey)
				var new_dis = src_tile.distance_to(rm_tile)
				if new_dis < dis:
					dis = new_dis
					close_tile = rm_tile
	return close_tile

func create_walls():
	for j in range(0,map_area.size.y):
		for i in range(0,map_area.size.x):
			var make_wall : bool = false
			#Is it an empty tile touching a solid tile?
			if map_tiles[i][j].type == CellData.TILETYPE.EMPTY:
				#Check all 8 positions
				var directions = [Vector2(-1,0),Vector2(-1,-1),Vector2(0,-1),Vector2(1,-1),Vector2(1,0),Vector2(1,1),Vector2(0,1),Vector2(-1,1)]				
				for dir : Vector2 in directions:
					var dir_point : Vector2 = dir+Vector2(i,j)
					if map_area.has_point(dir_point):
						if map_tiles[dir_point.x][dir_point.y].type == CellData.TILETYPE.TILE || map_tiles[dir_point.x][dir_point.y].type == CellData.TILETYPE.HALLWAY:
							make_wall = true
			#Is it an edge location?
			if (i==0 || j==0 || i==map_area.size.x-1 || j==map_area.size.y-1):
				make_wall = true

			if make_wall == true:
				map_tiles[i][j].type = CellData.TILETYPE.WALL
				set_cell(Vector2i(i,j),CellData.TILETYPE.WALL)
				var new_wall : Wall = wall_inst.instantiate()
				var mesh_offset = new_wall.mesh.size/2
				root_room_node.add_child(new_wall)
				new_wall.position = Vector3(i*tile_scale.x,1,j*tile_scale.y) + mesh_offset
				#new_wall.get_node("Label3D").text = str(new_wall.position)
				new_wall.get_node("Label3D").text = str(i,"x",j)
				
func is_room_position_valid(room : RoomData):
	if(room.rect.position.x > 0 && 
	room.rect.position.y > 0 && 
	room.rect.position.x+room.rect.size.x < map_area.size.x &&
	room.rect.position.y+room.rect.size.y < map_area.size.y):
		#Within Bounds of map
		for r in room_list:
			#Ensure it does not intersect another room. It can touch
			if room.rect.grow(2).intersects(r.rect.grow(2)):
				return false
		return true
	return false
