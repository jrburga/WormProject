extends Node
class_name Autoload

static func get_accessories_db(context : Node) -> AccessoriesDB:
	if Engine.editor_hint:
		return null
		
	if context:
		return context.get_node("/root/AccessoriesDB") as AccessoriesDB
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
