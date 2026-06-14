extends Node3D


@export var structure_root : Node3D
@export var sound_root : Node3D
@export var bullets_root : Node3D
@export var enemies_root : Node3D
@export var uieffects_root : Node3D
@export var pickups_root : Node3D

func _ready() -> void:
	Globals.current_main = self
