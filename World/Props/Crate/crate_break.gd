extends Node3D

func _ready() -> void:
	print("Crate Debris")
	var tween = create_tween()
	#tween.tween_property(self, "modulate:a", 0.0, 3.0)
	#Cant do alpha like this in 3d. Need to do albedo and transparency
	tween.tween_interval(2.5) # Pauses the sequence for 0.5 seconds
	tween.finished.connect(remove_debris)

func remove_debris():
	print("Removing Debris")
	queue_free()
