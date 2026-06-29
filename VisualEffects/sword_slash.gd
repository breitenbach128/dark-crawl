extends Node3D


func _on_animated_sprite_3d_animation_finished() -> void:
	queue_free()
