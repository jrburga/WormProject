tool
extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var color_menu = $TabContainer/Colors/ColorMenu
	var hat_menu = $TabContainer/Hats/HatMenu
	var mask_menu = $TabContainer/Masks/MaskMenu
	var skins_db = null
	var hat_db = null
	if not Engine.editor_hint:
		skins_db = get_node("/root/SkinsDB") as SkinsDB
		hat_db = get_node("/root/HatDB") as HatDB
	
	
	if skins_db and color_menu is ListControl:
		color_menu.set_items(skins_db.colors)
	if hat_db and hat_menu is ListControl:
		hat_menu.set_items(hat_db.hat_resources)
	if hat_db and mask_menu is ListControl:
		mask_menu.set_items(hat_db.mask_resources)
	
	color_menu.connect("item_selected", self, "_on_ColorMenu_item_selected")
	hat_menu.connect("item_selected", self, "_on_HatMenu_item_selected")
	mask_menu.connect("item_selected", self, "_on_MaskMenu_item_selected")
	
func _on_ColorMenu_item_selected(color : Color):
	var player_config = get_node("/root/PlayerConfig")
	player_config.worm_color = color
	
func _on_HatMenu_item_selected(hat_resource : HatResource):
	var player_config = get_node("/root/PlayerConfig")
	player_config.hat_id = hat_resource.id
	
func _on_MaskMenu_item_selected(mask_resource : HatResource):
	var player_config = get_node("/root/PlayerConfig")
	player_config.mask_id = mask_resource.id
