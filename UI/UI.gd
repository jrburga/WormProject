extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_OptionsButton_pressed():
	var pos = $OptionsPopup.rect_position
	var size = $OptionsPopup.rect_size 
	$OptionsPopup.popup(Rect2(pos.x, pos.y, size.x, size.y))
