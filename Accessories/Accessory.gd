extends Object
class_name Accessory

enum Type {
	Glasses,
	Hat,
	Mask
}

static func type_to_string(type : int):
	match type:
		Type.Glasses: return "Glasses"
		Type.Hat: return "Hat"
		Type.Mask: return "Mask"
	return ""
