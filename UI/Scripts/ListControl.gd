tool
extends Control
class_name ListControl

export(PackedScene) var ItemUI : PackedScene setget _set_item_ui, _get_item_ui
export(int) var num_preview_items = 0 setget _set_num_preview_items, _get_num_preview_items

var item_ui_map : Dictionary

signal item_selected(item)

func _set_num_preview_items(value):
	num_preview_items = value
	
func _get_num_preview_items():
	return num_preview_items

func _ready():
	
	if Engine.editor_hint:
		for preview_idx in num_preview_items:
			add_item(preview_idx)

func set_items(items : Array):
	for item in items:
		add_item(item)
		
func add_item(item):
	
	if item == null:
		print("null item", item)
		return
		
	# until we do pooling
	var new_item_ui = ItemUI.instance()
	if new_item_ui.has_method("_on_item_set"):
		
		item_ui_map[item] = new_item_ui
		new_item_ui._on_item_set(item)
		add_child(new_item_ui)
		
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
		remove_child(item_ui)
		
		# until we do pooling
		item_ui.queue_free()

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
