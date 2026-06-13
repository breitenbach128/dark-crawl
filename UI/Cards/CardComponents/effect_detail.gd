extends TextureRect
class_name EffectDetail


@export var label: Label

var icon_dictionary : Dictionary = {
	"physical": Vector2(0,0),
	"fire": Vector2(64,0),
	"force": Vector2(128,0),
	"shock": Vector2(160,0),
	"cold": Vector2(224,0),
	"soul": Vector2(288,0)
}
@export_enum("physical", "fire", "force","shock", "cold", "soul",) var icon_type : String = "physical"

@export var text : String = ""
func _ready() -> void:	
	set_icon_type_by_name(icon_type)
	label.text = text
func set_icon_type_by_name(key_name : String):
	var atlas :AtlasTexture = texture
	atlas.region.position = icon_dictionary[key_name]
