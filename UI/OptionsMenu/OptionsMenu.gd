tool
extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(NodePath) var ColorMenu = null
export(NodePath) var HatMenu = null
export(NodePath) var MaskMenu = null


# Called when the node enters the scene tree for the first time.
func _ready():
	var color_menu = get_node(ColorMenu)
	var hat_menu = get_node(HatMenu)
	var mask_menu = get_node(MaskMenu)
	var skins_db = AutoloadUtl.get_skins_db(self)
	var hat_db = AutoloadUtl.get_hat_db(self)
	
	
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
	var player_config = AutoloadUtl.get_player_config(self)
	player_config.worm_color = color
	
func _on_HatMenu_item_selected(hat_resource : HatResource):
	var player_config = AutoloadUtl.get_player_config(self)
	player_config.hat_id = hat_resource.id
	
func _on_MaskMenu_item_selected(mask_resource : HatResource):
	var player_config = AutoloadUtl.get_player_config(self)
	player_config.mask_id = mask_resource.id
