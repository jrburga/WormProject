tool
extends Control
class_name HatItem

export(String) var hat_id setget _set_hat_id, _get_hat_id

func _set_hat_id(value):
	hat_id = value

func _get_hat_id():
	return hat_id
	
func _on_item_set(item):
	if item is HeadAccessoryRes:
		hat_id = item.id
		$Label.text = item.display_name
