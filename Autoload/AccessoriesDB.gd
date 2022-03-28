extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var hat_resources = []
var mask_resources = []
var glasses_resources = []

func _ready():
	var start = OS.get_ticks_msec()
	load_hats()
	load_masks()
	load_glasses()

	
func load_hats():
	var path = "res://Accessories/Hats/Resources"
	Util.load_resources_in_directory(path, hat_resources)
	hat_resources.sort_custom(self, "_resource_sort")
	
func load_masks():
	var path = "res://Accessories/Masks/Resources"
	Util.load_resources_in_directory(path, mask_resources)
	mask_resources.sort_custom(self, "_resource_sort")
	
func load_glasses():
	var path = "res://Accessories/Glasses/Resources"
	Util.load_resources_in_directory(path, glasses_resources)
	glasses_resources.sort_custom(self, "_resource_sort")

func get_resource(id : String, type : int):
	match type:
		Accessory.Type.Glasses:
			return _find_resource_by_id(id, glasses_resources)
		Accessory.Type.Hat:
			return _find_resource_by_id(id, hat_resources)
		Accessory.Type.Mask:
			return _find_resource_by_id(id, mask_resources)

func get_hat_resource(hat_id) -> AccessoryResource:
	return _find_resource_by_id(hat_id, hat_resources)
	
func get_mask_resource(mask_id) -> AccessoryResource:
	return _find_resource_by_id(mask_id, mask_resources)
	
func get_glasses_resource(glasses_id) -> AccessoryResource:
	return _find_resource_by_id(glasses_id, glasses_resources)

func _resource_sort(res_a : AccessoryResource, res_b : AccessoryResource):
	if res_a.id == '':
		return true
	elif res_b.id == '':
		return false
	else:
		return res_a.display_name < res_b.display_name

func _find_resource_by_id(id, resources) -> AccessoryResource:
	for res in resources:
		if res is AccessoryResource:
			if res.id == id:
				return res
	return null
