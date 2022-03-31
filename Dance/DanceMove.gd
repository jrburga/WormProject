tool
extends Resource
class_name DanceMove

export(String) var id : String
export(String) var display_name : String
export(Animation) var animation : Animation

# grabbed_segments is used as a binary flag
export(int, 0,26) var num_segments : int = 13 setget _set_num_segments
var grabbed_segments : int = 0

func _set_num_segments(value):
	num_segments = value
	property_list_changed_notify()

func _get_property_list():
	
	var properties = []
	properties.append({
		name = "Grabbed Segments",
		type = TYPE_NIL,
		hint_string = "grabbed_segments",
		usage = PROPERTY_USAGE_GROUP
	})
	var hint_string = ""
	for idx in num_segments:
		hint_string += str(idx) + ","
	properties.append({
		name = "grabbed_segments",
		type = TYPE_INT,
		hint = PROPERTY_HINT_FLAGS,
		hint_string = hint_string,
		usage = PROPERTY_USAGE_DEFAULT
	})
	return properties

func grabbed_segments_contains(index : int) -> bool:
	if index < 0 or index >= num_segments:
		return false
	return (1 << index) && grabbed_segments
	
func get_grabbed_segments_array() -> Array:
	var grabbed_segments_array = []
	for index in num_segments:
		if grabbed_segments_contains(index):
			grabbed_segments_array.append(index)
	return grabbed_segments_array
