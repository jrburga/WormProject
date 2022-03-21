tool
extends Node
class_name AccessoryNode2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var current_hat : Node2D
var current_mask : Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var player_config = Autoload.get_player_config(self)
	player_config.connect("hat_id_changed", self, "_on_hat_id_changed")
	player_config.connect("mask_id_changed", self, "_on_mask_id_changed")
	_set_hat_by_id(player_config.hat_id)
	_set_mask_by_id(player_config.mask_id)
	
func _set_mask_by_id(mask_id):
	var accessories_db = Autoload.get_accessories_db(self)
	var mask_res = accessories_db.get_mask_resource(mask_id)
	
	if current_mask != null:
		remove_child(current_mask)
		current_mask.queue_free()
		current_mask = null
		
	if mask_res is HeadAccessoryRes:
		var mask_scene = mask_res.Scene
		if mask_scene:
			var mask = mask_scene.instance()
			add_child(mask)
			current_mask = mask
			
	elif mask_id != "":
		print("Invalid mask id!", mask_id)
	
func _set_hat_by_id(hat_id):
	var accessories_db = Autoload.get_accessories_db(self)
	var hat_res = accessories_db.get_hat_resource(hat_id)
	
	if current_hat != null:
		remove_child(current_hat)
		current_hat.queue_free()
		current_hat = null
	
	if hat_res is HeadAccessoryRes:
		var hat_scene = hat_res.Scene
		if hat_scene:
			var hat = hat_scene.instance()
			add_child(hat)
			current_hat = hat
#			current_hat.o
	elif hat_id != "":
		print("Invalid hat id!", hat_id)
		
			
func _on_hat_id_changed(new_hat_id):
	_set_hat_by_id(new_hat_id)
	
func _on_mask_id_changed(new_mask_id):
	_set_mask_by_id(new_mask_id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

