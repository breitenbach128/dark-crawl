extends Node3D

func _ready() -> void:
	var tween = create_tween()	
	tween.set_parallel(true)
	var all_meshes: Array[Node] = find_children("*", "MeshInstance3D")
	for mesh : MeshInstance3D in all_meshes:		
		var prev_material :StandardMaterial3D = mesh.get_active_material(0)
		mesh.set_surface_override_material(0, prev_material.duplicate())
		var dup_material :StandardMaterial3D = mesh.get_active_material(0)
		dup_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
		dup_material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
		dup_material.albedo_color.a = 1.0
		
		tween.tween_property(dup_material, "albedo_color:a", 0.0, 3.0) # Fades to 0 alpha over 1.0 seconds
			
	tween.finished.connect(remove_debris)

func remove_debris():
	queue_free()
