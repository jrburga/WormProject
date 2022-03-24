extends Node
class_name DanceDetector

class SegmentState:
	var transform = Transform2D()
	
	func to_dict() -> Dictionary:
		return inst2dict(self) 
		
	static func from_dict(dict : Dictionary) -> Object:
		return dict2inst(dict)
		
	func _to_string():
		
		return "[SegmentState " + String(transform) + "]"
		
	func file_store(file : File):
		file.store_var(transform)
		
	func file_get(file : File) -> SegmentState:
		file.get_var(transform)
		return self

class WormState:
	var segment_states = []
	
	# list of indices
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
			
	

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var segment_state = SegmentState.new()
	var worm_state = WormState.new()
	worm_state.segment_states.push_back(segment_state)
	worm_state.grabbed_segments.push_back(0)
	
	save_states_var(worm_state)
	
func save_states_file_store(worm_state : WormState):

	# saving data as bytes
	var save_game = File.new()
	save_game.open("user://worm_state.save", File.WRITE)
	worm_state.file_store(save_game)
	
	# loading data from bytes
	save_game.open("user://worm_state.save", File.READ)
	var worm_state_from_save = WormState.new().file_get(save_game)
	save_game.close()

	print(worm_state_from_save)
	
func save_states_var(worm_state : WormState):
	# convert data to dict (custom process)
	var dict = worm_state.to_dict()

	# saving data as bytes
	var save_game = File.new()
	save_game.open("user://worm_state.save", File.WRITE)
	save_game.store_var(dict)
	save_game.close()
	
	# loading data from bytes
	save_game.open("user://worm_state.save", File.READ)
	var dict_from_save = save_game.get_var()
	save_game.close()
	
	# assumes the bytes are of type WormState
	var from_dict = WormState.from_dict(dict_from_save)
	print(from_dict)
	
func save_states_buffer(worm_state : WormState):

	
	# convert data to dict (custom process)
	var dict = worm_state.to_dict()
	var bytes = var2bytes(dict) as PoolByteArray

	# saving data as bytes
	var save_game = File.new()
	save_game.open("user://worm_state.save", File.WRITE)
	save_game.store_buffer(bytes)
	save_game.close()
	
	# loading data from bytes
	save_game.open("user://worm_state.save", File.READ)
	var bytes_from_save = save_game.get_buffer(save_game.get_len())
	save_game.close()
	
	# assumes the bytes are of type WormState
	var from_bytes = bytes2var(bytes_from_save)
	var from_dict = WormState.from_dict(dict)
	print(from_dict)
	
