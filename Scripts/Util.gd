extends Object
class_name Util

# https://docs.godotengine.org/en/stable/tutorials/export/feature_tags.html
const EDITOR = "editor"
const DEBUG = "debug"
const RELEASE = "release"
const STANDALONE = "standalone"

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
	
	if not dir.dir_exists(path):
		if OS.has_feature(EDITOR):
			push_warning("Failed to load resources in directory! Does not exist: " + path)
		return
		
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
