extends Node
class_name AutoloadUtl

static func get_hat_db(context : Node) -> HatDB:
	if Engine.editor_hint:
		return null
		
	if context:
		return context.get_node("/root/HatDB") as HatDB
	return null

static func get_skins_db(context : Node) -> SkinsDB:
	if Engine.editor_hint:
		return null
		
	if context:
		return context.get_node("/root/SkinsDB") as SkinsDB
	return null
	
static func get_player_config(context : Node) -> PlayerConfig:
	if Engine.editor_hint:
		return null
		
	if context:
		return context.get_node("/root/PlayerConfig") as PlayerConfig
	return null
