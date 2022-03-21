extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var hat_resources = []
var mask_resources = []
var glasses_resources = []

func _ready():
	load_hats()
	load_masks()
	load_glasses()
	
func load_hats():
	var path = "res://Worm/Hats/Resources"
	Util.load_resources_in_directory(path, hat_resources)
	hat_resources.sort_custom(self, "_resource_sort")
	
func load_masks():
	var path = "res://Worm/Masks/Resources"
	Util.load_resources_in_directory(path, mask_resources)
	mask_resources.sort_custom(self, "_resource_sort")
	
func load_glasses():
	var path = "res://Worm/Glasses/Resources"
	Util.load_resources_in_directory(path, glasses_resources)
	glasses_resources.sort_custom(self, "_resource_sort")

func get_hat_resource(hat_id) -> HeadAccessoryRes:
	return _find_resource_by_id(hat_id, hat_resources)
	
		
func get_mask_resource(mask_id) -> HeadAccessoryRes:
	return _find_resource_by_id(mask_id, mask_resources)
	
func get_glasses_resource(glasses_id) -> HeadAccessoryRes:
	return _find_resource_by_id(glasses_id, glasses_resources)

func _resource_sort(res_a : HeadAccessoryRes, res_b : HeadAccessoryRes):
	if res_a.id == '':
		return true
	elif res_b.id == '':
		return false
	else:
		return res_a.display_name < res_b.display_name

func _find_resource_by_id(id, resources) -> HeadAccessoryRes:
	for res in resources:
		if res is HeadAccessoryRes:
			if res.id == id:
				return res
	return null
