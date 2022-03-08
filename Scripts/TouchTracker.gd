extends Object

class_name TouchTracker

class TrackerObject extends Object:
	var object = null
	var touch_position = Vector2()
	var touch_index = -1


var tracker_objects = []
func set_tracker_object(touch_index : int, touch_position : Vector2, object : Object):
	if touch_index < 0:
		return
	if touch_index >= tracker_objects.size():
		tracker_objects.resize(touch_index + 1)
	
	var tracker_object = tracker_objects[touch_index] as TrackerObject
	if tracker_object == null:
		tracker_object = TrackerObject.new()
		tracker_objects[touch_index] = tracker_object
	tracker_object.object = object
	tracker_object.touch_index = touch_index
	tracker_object.touch_position = touch_position
		
func update_tracker_object(touch_index : int, touch_position : Vector2):
	var tracker_object = find_tracker_object_at(touch_index)
	if tracker_object:
		tracker_object.touch_position = touch_position
			
func find_tracker_object(object : Object) -> TrackerObject:
	for tracker_object in tracker_objects:
		var as_tracker_object = tracker_object as TrackerObject
		if as_tracker_object and as_tracker_object.object == object:
			return tracker_object
	return null

func find_tracker_object_at(index : int) -> TrackerObject:
	return tracker_objects[index] if index >= 0 and index < tracker_objects.size() else null
	
func clear_tracker_object_at(index: int):
	if index >= 0 and index < tracker_objects.size():
		var tracker_object = tracker_objects[index] as TrackerObject
		if tracker_object:
			tracker_object.object = null

func _to_string():
	return "tracker object"
