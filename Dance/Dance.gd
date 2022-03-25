class_name Dance

class SegmentState:
	# list of transforms
	var transform : Transform2D = Transform2D()
	
	func to_dict() -> Dictionary:
		return inst2dict(self) 
		
	static func from_dict(dict : Dictionary) -> Object:
		return dict2inst(dict)
		
	func _to_string():
		
		return "[SegmentState " + String(transform) + "]"
		
	func file_store(file : File):
		file.store_var(transform)
		
	func file_get(file : File) -> SegmentState:
		transform = file.get_var()
		return self

class WormState:
	# list of SegmentState instances
	var segment_states = []
	
	# list of indices, int types
	var grabbed_segments = []
	
	func file_store(file : File):
		file.store_8(segment_states.size())
		for segment_state in segment_states:
			segment_state.file_store(file)
			
		file.store_8(grabbed_segments.size())
		for grabbed_segment in grabbed_segments:
			file.store_8(grabbed_segment)
			
	func file_get(file : File) -> WormState:
		segment_states.resize(file.get_8())
		for idx in segment_states.size():
			segment_states[idx] = SegmentState.new().file_get(file)
			
		grabbed_segments.resize(file.get_8())
		for idx in grabbed_segments.size():
			grabbed_segments[idx] = file.get_8()
			
		return self

	func to_dict() -> Dictionary:
		for segment_state in segment_states:
			if not segment_state is SegmentState:
				push_error("can't serialize WormState, invalid SegmentState")
				
		var dict = inst2dict(self)
		
		for idx in dict['segment_states'].size():
			dict['segment_states'][idx] = dict['segment_states'][idx].to_dict()
		
		return dict
		
	static func from_dict(dict : Dictionary) -> Object:
		var inst = dict2inst(dict)
		
		for idx in inst.segment_states.size():
			inst.segment_states[idx] = dict2inst(inst.segment_states[idx])
		
		return inst
		
	func _to_string():
		var segment_states_str = ""
		segment_states_str += "[\n"
		for segment_state in segment_states:
			segment_states_str += "\t" + segment_state._to_string() + "\n"
		segment_states_str += "]"
		return "[WormState - segment_states: " + segment_states_str + "]"
			
	
