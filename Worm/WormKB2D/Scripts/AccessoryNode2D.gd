tool
extends Node
class_name AccessoryNode2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(Accessory.Type) var accessory_type = Accessory.Type.Glasses

var current_accessory : Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	if not Engine.editor_hint:
		var player_config = Autoload.get_player_config(self)
		
		player_config.connect(
			player_config.get_id_changed_signal(accessory_type), 
			self, "_on_accessory_id_changed")
			
		_set_accessory_by_id(player_config.get_accessory_id(accessory_type))
		
func _set_accessory_by_id(id):
	var accessories_db = Autoload.get_accessories_db(self)
	var accessory_res = accessories_db.get_resource(id, accessory_type)
	
	if current_accessory != null:
		remove_child(current_accessory)
		current_accessory.queue_free()
		current_accessory = null
		
	if accessory_res is AccessoryResource:
		if accessory_res.Scene:
			var scene = accessory_res.Scene.instance()
			add_child(scene)
			current_accessory = scene
			
	elif id != "":
		print("Invalid accessory id! ", Accessory.type_to_string(accessory_type), id)
		

func _on_accessory_id_changed(new_accessory_id):
	_set_accessory_by_id(new_accessory_id)


