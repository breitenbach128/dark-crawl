extends Node3D
class_name HealthBar3D


@export var value : int = 0
@export var min : int = 0
@export var max : int = 100
@export var background_sprite : Sprite3D
@export var foreground_sprite : Sprite3D
@export var bar_sprite : Sprite3D
@export var bar_size : Rect2

func update_bar_value(value):
	var progress_percent : float = float(value)/max
	#print("Updating HP Bar value: ",value," ",max," percent: ", progress_percent, " bar_size:",bar_size.size.x)
	var bar_pixel_width : int = int(progress_percent * bar_size.size.x)
	bar_sprite.region_rect.size.x = bar_pixel_width
	bar_sprite.offset.x = ((bar_size.size.x - bar_pixel_width) / 2) * -1
	
