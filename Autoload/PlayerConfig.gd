extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var hat_id : String setget _set_hat_id, _get_hat_id
var mask_id : String setget _set_mask_id, _get_mask_id
var glasses_id : String setget _set_glasses_id, _get_glasses_id
var worm_color : Color setget _set_worm_color, _get_worm_color

signal worm_color_changed(new_color)
signal hat_id_changed(new_hat_id)
signal mask_id_changed(new_mask_id)
signal glasses_id_changed(new_glasses_id)

func get_id_changed_signal(type : int) -> String:
	match type:
		Accessory.Type.Glasses: 
			return "glasses_id_changed"
		Accessory.Type.Hat:
			return "hat_id_changed"
		Accessory.Type.Mask:
			return "mask_id_changed"
	return ""

func get_accessory_id(type : int) -> String:
	match type:
		Accessory.Type.Glasses:
			return _get_glasses_id()
		Accessory.Type.Hat:
			return _get_hat_id()
		Accessory.Type.Mask:
			return _get_mask_id()
	return ""
			
func set_accessory_id(id : String, type : int):
	match type:
		Accessory.Type.Glasses:
			return _set_glasses_id(id)
		Accessory.Type.Hat:
			return _set_hat_id(id)
		Accessory.Type.Mask:
			return _set_mask_id(id)

func _set_glasses_id(value):
	glasses_id = value
	emit_signal("glasses_id_changed", glasses_id)
	
func _get_glasses_id():
	return glasses_id

func _set_mask_id(value):
	mask_id = value
	emit_signal("mask_id_changed", mask_id)
	
func _get_mask_id():
	return mask_id

func _set_hat_id(value):
	hat_id = value
	emit_signal("hat_id_changed", hat_id)
	
func _get_hat_id():
	return hat_id

func _set_worm_color(value):
	worm_color = value
	emit_signal("worm_color_changed", worm_color)
	
func _get_worm_color():
	return worm_color

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
