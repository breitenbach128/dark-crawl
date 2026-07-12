extends Node
class_name PropGenerator


func generate_game_props(isServer: bool):
	#Go through and remove all props
	#If server, create prop in same position and add child to main props to spawn MP
	
	if isServer:
		print("Generate game props on server: ", get_tree().get_nodes_in_group("Props").size())
		for prop : Prop in get_tree().get_nodes_in_group("Props"):
			var new_prop : Prop = load(prop.scene_file_path).instantiate()
			Globals.current_main.props_root.add_child(new_prop,true)
			new_prop.global_position = prop.global_position
			prop.queue_free()
	else:
		print("Generate game props on client: ", get_tree().get_nodes_in_group("Props").size())
		for prop : Prop  in get_tree().get_nodes_in_group("Props"):
			prop.queue_free()
