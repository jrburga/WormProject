tool
extends Control
class_name ColorItem

export(Color) var color = Color.white setget _set_color, _get_color

func _set_color(value):
	color = value
	$ColorRect.color = value

func _get_color():
	return $ColorRect.color
	
func _ready():
	return color
	
	
