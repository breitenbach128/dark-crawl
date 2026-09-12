extends RefCounted  # Inherit from RefCounted for simple data objects, or Node/Resource
class_name NetworkPlayerData

# Class properties (variables)
var id: int
var name: String
var ready : bool

func _init(p_id: int, p_name: String) -> void:
	id = p_id
	name = p_name
	ready = false
