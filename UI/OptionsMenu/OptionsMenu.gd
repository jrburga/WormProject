tool
extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var skins_db = null
	var hat_db = null
	if not Engine.editor_hint:
		skins_db = get_node("/root/SkinsDB")
		hat_db = get_node("/root/HatDB")
	
	
	if skins_db and $ColorMenu is ListControl:
		$ColorMenu.set_items(skins_db.colors)
	if hat_db and $HatMenu is ListControl:
		$HatMenu.set_items(hat_db.hat_resources)
	
	$ColorMenu.connect("item_selected", self, "_on_ColorMenu_item_selected")
	$HatMenu.connect("item_selected", self, "_on_HatMenu_item_selected")
	
func _on_ColorMenu_item_selected(color : Color):
	var player_config = get_node("/root/PlayerConfig")
	player_config.worm_color = color
	
func _on_HatMenu_item_selected(hat_resource : HatResource):
	var player_config = get_node("/root/PlayerConfig")
	player_config.hat_id = hat_resource.id
