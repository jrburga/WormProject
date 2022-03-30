tool
extends Node

export(int) var test = 0

func _ready():
	print("ready")
#	for property in get_property_list():
#		print(property)
		
		
	PROPERTY_USAGE_STORAGE # 1                0b00000000000001
	PROPERTY_USAGE_EDITOR # 2                 0b00000000000010
	PROPERTY_USAGE_NOEDITOR # 5               0b00000000000101
	PROPERTY_USAGE_DEFAULT # 7                0b00000000000111
	PROPERTY_USAGE_EDITOR_HELPER # 8          0b00000000001000
	PROPERTY_USAGE_CHECKABLE # 16             0b00000000010000
	PROPERTY_USAGE_CHECKED # 32               0b00000000100000
	PROPERTY_USAGE_INTERNATIONALIZED # 64	  t0b00000001000000
	PROPERTY_USAGE_DEFAULT_INTL # 71          0b00000001000111
	PROPERTY_USAGE_GROUP # 128                0b00000010000000
	PROPERTY_USAGE_CATEGORY # 256             0b00000100000000
	PROPERTY_USAGE_NO_INSTANCE_STATE  # 2048  0b00100000000000
	PROPERTY_USAGE_RESTART_IF_CHANGED # 4096  0b01000000000000
	PROPERTY_USAGE_SCRIPT_VARIABLE # 8192     0b10000000000000

func _get_property_list():
	var properties = []
	properties.append({
		name = "Group",
		type = TYPE_NIL,
		hint_string = "",
		usage = PROPERTY_USAGE_GROUP
	})
	properties.append({
		name = "test",
		type = TYPE_INT,
		value = test,
		usage = PROPERTY_USAGE_DEFAULT
	})
	return properties
