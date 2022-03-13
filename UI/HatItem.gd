tool
extends Control
class_name HatItem

export(String) var hat_id

func _set_hat_id(value):
	hat_id = value

func _get_color():
	return hat_id
	
	
