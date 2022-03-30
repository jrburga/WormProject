extends Resource
class_name DanceMove

export(String) var id : String
export(String) var display_name : String
export(Animation) var animation : Animation
export(int, FLAGS,
 "0",
 "1",
 "2",
 "3",
 "4",
 "5",
 "6",
 "7",
 "8",
 "9",
 "10",
 "11",
 "12",
 "13") var grabbed_segments

func _get_property_list():
	var properties = []
	properties.append({
		name = "Grabbed Segments",
		type = TYPE_NIL,
		hint_string = "grabbed_segments",
		usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
	})
	return properties
