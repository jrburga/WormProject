extends Object


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


static func find_first_parent(node : Node, type):
	var parent = node.get_parent()
	while parent:
		if parent is type:
			return parent
		parent = parent.get_parent()
		
static func find_first_parent_witd_method(node : Node, method_name : String):
	var parent = node.get_parent()
	while parent:
		if parent.has_method(method_name):
			return parent
		parent = parent.get_parent()
