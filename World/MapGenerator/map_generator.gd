extends Node
class_name MapGenerator

@export var world_size : Vector2i = Vector2i(100,100)
@export var floor_template : Resource
@export var wall_template : Resource
@export var max_depth : int = 3
@export var rooms_holder : Node3D
@export var exit_marker_template: Resource

#5x5 tiles
var room_list : Array[RoomData] = []
var tile_size : Vector2i = Vector2i(5,5)
var current_tile_position = Vector2i(0,0)
var current_depth : int = 0
var current_room : RoomData = null
var prev_room : RoomData = null
#Get list of all rooms and pick random starting room.
#Always start at 0,0
func _ready() -> void:
	
	#Create all selectable rooms
	create_room_list()
	
	current_room = room_list.pick_random()
	if current_room:
		print("Starting Room Generation")
		generate_room(current_tile_position)

func create_room_list():
	#Every Exit combo possible
	var top_locations : Array[Vector2i]
	var bottom_locations : Array[Vector2i]
	var left_locations : Array[Vector2i]
	var right_locations : Array[Vector2i]
	for j in range(0,tile_size.y):
		for i in range(0,tile_size.x):
			if j == 0:
				top_locations.append(Vector2i(i,j-1))
			if j == tile_size.y-1:
				bottom_locations.append(Vector2i(i,j+1))
			if i == 0 :
				left_locations.append(Vector2i(i-1,j))
			if i == tile_size.x-1:
				right_locations.append(Vector2i(i+1,j))
				
	create_roomdata_exits(top_locations,bottom_locations+left_locations+right_locations)
	create_roomdata_exits(bottom_locations,top_locations+left_locations+right_locations)
	create_roomdata_exits(left_locations,top_locations+bottom_locations+right_locations)
	create_roomdata_exits(right_locations,top_locations+bottom_locations+left_locations)
			
	

func create_roomdata_exits(side_locations,othersides):
	for side in side_locations:
		for other in othersides:
			var new_roomdata = RoomData.new()
			new_roomdata.room_size = tile_size
			new_roomdata.exit_locations.append(side)#Exit 1
			new_roomdata.exit_locations.append(other)#Exit 2
			room_list.append(new_roomdata)

func generate_room(tile_pos : Vector2i):
	#Add the room to the scene
	var gen_room = floor_template.instantiate()
	gen_room.name = "Room"
	rooms_holder.add_child(gen_room)
	var gen_room_position_2d : Vector2i = tile_pos * tile_size
	var gen_room_position_3d : Vector3 = Vector3(gen_room_position_2d.x,0,gen_room_position_2d.y)
	print("New Room Position: ", gen_room_position_3d)
	gen_room.position = gen_room_position_3d
	#Add markers to help visualize for now
	for e in current_room.exit_locations:
		var em  = exit_marker_template.instantiate()
		gen_room.add_child(em)
		print("exit pos: ", e)
		em.position = Vector3(e.x-(current_room.room_size.x/2),0,e.y-(current_room.room_size.y/2))
		em.get_node("Label3D").text = str(e.x,",",e.y)
	#Now, make walls for non exits
	print("Build new wallset for ROOM")

	for j in range(-1,current_room.room_size.y+1):
		for i in range(-1,current_room.room_size.x+1):
			#Check if external perimeter
			if j == -1 || j == current_room.room_size.y || i == current_room.room_size.x || i == -1: 
				#wall 1x1 is East West
				if current_room.exit_locations.find(Vector2i(i,j)) == -1:
					if (!(i == -1 && j == -1) && 
					!(i == current_room.room_size.x && j == -1) && 
					!(i == -1 && j == current_room.room_size.y) && 
					!(i == current_room.room_size.x && j == current_room.room_size.y)):
						
						print("build wall at ", i, " ", j)
						var wall = wall_template.instantiate()
						var offsetX = (current_room.room_size.x/2)
						var offsetY = (current_room.room_size.y/2)
						wall.get_node("Label3D").text = str(i,",",j)
						gen_room.add_child(wall)
						if i == -1:
							wall.position = Vector3(i-offsetX+0.0,gen_room.position.y+0.5,j-offsetY)
						if i == current_room.room_size.x:
							wall.position = Vector3(i-offsetX-0.0,gen_room.position.y+0.5,j-offsetY)
						if j == -1:
							wall.position = Vector3(i-offsetX,gen_room.position.y+0.5,j-offsetY+0.0)
						if j == current_room.room_size.y:
							wall.position = Vector3(i-offsetX,gen_room.position.y+0.5,j-offsetY-0.0)

	#Foreach Exit
	for exit in current_room.exit_locations:
		
		#Find room in list that has compatible exits
		var good_rooms : Array[RoomData] = room_list.filter(filter_rooms_exits.bind(exit))
		if good_rooms.size() > 0:
			
			if exit.y == current_room.room_size.y:
				tile_pos += Vector2i(0,1)
			if exit.y == -1:
				tile_pos += Vector2i(0,-1)
			if exit.x == current_room.room_size.x:
				tile_pos += Vector2i(1,0)
			if exit.x == -1:
				tile_pos += Vector2i(-1,0)
			prev_room = current_room
			current_room = good_rooms.pick_random()
			print("Found Connectable room with new tile pos: ", tile_pos)
			current_depth+= 1
			if current_depth < max_depth:
				print("depth ", current_depth)			
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
	
