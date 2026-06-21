extends Node


var local_player : Player
var local_player_id : int 
var current_main : Node3D

var card_db : Array[Dictionary] = []


func _ready() -> void:
	var card_scenes = get_scenes_in_folder("res://UI/Cards/")
	card_scenes.sort_custom(func(a, b): return a < b)
	
	for cs in range(0,card_scenes.size()):
		card_db.append({
			"id":cs,
			"res":card_scenes[cs]
		})
	print(card_db)
	
	
func get_scenes_in_folder(folder_path: String) -> Array[String]:
	var scene_paths: Array[String] = []
	
	# Verify that the folder exists and can be opened
	if DirAccess.dir_exists_absolute(folder_path):
		var files = DirAccess.get_files_at(folder_path)
		
		for file in files:
			# Filter by standard Godot text scene extension
			if file.ends_with(".tscn"):
				var full_path = folder_path.path_join(file)
				scene_paths.append(full_path)
	else:
		printerr("Directory does not exist: ", folder_path)
		
	return scene_paths


	
