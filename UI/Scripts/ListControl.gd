tool
extends Control
class_name ListControl

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(PackedScene) var ItemUI : PackedScene setget _set_item_ui, _get_item_ui

var item_ui_map : Dictionary

signal item_selected(item)

func _ready():
	pass # Replace with function body.

func add_item(item : Object):
	if item == null:
		return
		
	var new_item_ui = ItemUI.instance()
	if new_item_ui.has_method("_on_item_set"):
		
		item_ui_map[item] = new_item_ui
		new_item_ui._on_item_set(item)
		
		new_item_ui.connect("pressed", self, "_on_item_pressed", [item])
		
func _on_item_pressed(item):
	emit_signal("item_selected", item)
	
func remove_item(item : Object):
	if item == null:
		return
	
	if item in item_ui_map:
		var item_ui = item_ui_map[item]
		item_ui.queue_free()
		item_ui_map.erase(item)

func _get_configuration_warning():
	if ItemUI == null:
		return "need to assign an ItemUI scene"
	else:
		var item_ui_instance = ItemUI.instance()
		if !item_ui_instance.has_method("_on_item_set"):
			return "item ui needs to implement '_on_item_set(item)'"
	return ""
	
func _set_item_ui(value):
	ItemUI = value
	if is_inside_tree():
		get_tree().emit_signal("node_configuration_warning_changed", self)
	
func _get_item_ui():
	return ItemUI
