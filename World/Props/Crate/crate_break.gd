extends Node3D

func _ready() -> void:
	print("Crate Debris")
	var tween = create_tween()	
	tween.set_parallel(true)
	var all_meshes: Array[Node] = find_children("*", "MeshInstance3D")
	for mesh : MeshInstance3D in all_meshes:
		var material = mesh.get_active_material(0)
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
		material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
		tween.tween_property(material, "albedo_color:a", 0.0, 10.0) # Fades to 0 alpha over 1.0 seconds
			
	tween.finished.connect(remove_debris)

func remove_debris():
	print("Removing Debris")
	queue_free()
