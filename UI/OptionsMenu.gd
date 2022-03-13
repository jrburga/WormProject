tool
extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorMenu.connect("select_color", self, "_on_select_color")
	$HatMenu.connect("select_hat", self, "_on_select_hat")
	
func _on_select_color(color : Color):
	var player_config = get_node("/root/PlayerConfig")
	player_config.worm_color = color
	
func _on_select_hat(hat_id : String):
	var player_config = get_node("/root/PlayerConfig")
	player_config.hat_id = hat_id
