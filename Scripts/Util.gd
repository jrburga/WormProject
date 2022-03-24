extends Object
class_name Util

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

static func find_first_parent(node : Node, type):
	var parent = node.get_parent()
	while parent:
		if parent is type:
			return parent
		parent = parent.get_parent()
		
static func find_first_parent_with_method(node : Node, method_name : String):
	var parent = node.get_parent()
	while parent:
		if parent.has_method(method_name):
			return parent
		parent = parent.get_parent()

static func load_resources_in_directory(directory_name : String, in_out_array : Array):
	var path = directory_name
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			var resource = load(path + "/" + file)
			if resource:
				in_out_array.append(resource)

	dir.list_dir_end()
