extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(Array, Resource) var hat_resources = []
export(Array, Resource) var mask_resources = []

func _ready():
	load_hats()

func load_hats():
	var path = "res://Worm/Hats/Resources"
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			var hat_resource = load(path + "/" + file)
			if hat_resource:
				hat_resources.append(hat_resource)

	dir.list_dir_end()
	
	hat_resources.sort_custom(self, "_hat_sort")
	
func load_masks():
	var path = "res://Worm/Masks/Resources"
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			var mask_resource = load(path + "/" + file)
			if mask_resource:
				mask_resources.append(mask_resource)

	dir.list_dir_end()
	
	mask_resources.sort_custom(self, "_hat_sort")	

func get_hat_resource(hat_id) -> HatResource:
	for hat_res in hat_resources:
		if hat_res is HatResource:
			if hat_res.id == hat_id:
				return hat_res
	return null
	
func get_mask_resource(mask_id) -> HatResource:
	for mask_res in mask_resources:
		if mask_res is HatResource:
			if mask_res.id == mask_id:
				return mask_res
	return null

func _hat_sort(res_a : HatResource, res_b : HatResource):
	if res_a.id == '':
		return true
	elif res_b.id == '':
		return false
	else:
		return res_a.display_name < res_b.display_name
