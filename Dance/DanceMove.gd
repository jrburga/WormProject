tool
extends Resource
class_name DanceMove

export(String) var id : String
export(String) var display_name : String
export(PoolByteArray) var data : PoolByteArray setget _set_data

var times = []
var worm_states = []

func _set_data(value : PoolByteArray):
	data = value
	times = []
	worm_states = []
	read_data()

func save_move(name : String):
	
	# worm states and times don't get serialized 
	# since we're not exporting them
	# serialize them ourselves as a ByteArray
	var worm_state_dicts = [] as Array
	for worm_state in worm_states:
		worm_state_dicts.append(worm_state.to_dict())
	var dict = {
		"worm_states": worm_state_dicts,
		"times": times
	}
	
	data = var2bytes(dict) as PoolByteArray
	
	var path = "res://Dance/Moves/" + name + ".tres"
	ResourceSaver.save(path, self)
	
func read_data():
	if data.size() == 0:
		return
		
	var dict = bytes2var(data) as Dictionary
	if dict == null:
		print("dict is null")
		push_warning("failed to read dictionary from data")
		return
	
	if dict.has('times') and dict.has('worm_states'):
		for time in dict['times']:
			times.append(time)
			
		for worm_state_dict in dict['worm_states']:
			worm_states.append(Dance.WormState.from_dict(worm_state_dict))

func test_save():
	var segment_state = Dance.SegmentState.new()
	var worm_state = Dance.WormState.new()
	worm_state.segment_states.push_back(segment_state)
	worm_state.grabbed_segments.push_back(0)
	
	save_states_var(worm_state)
	
func save_states_file_store(worm_state : Dance.WormState):

	# saving data as bytes
	var save_game = File.new()
	save_game.open("user://worm_state.save", File.WRITE)
	worm_state.file_store(save_game)
	
	# loading data from bytes
	save_game.open("user://worm_state.save", File.READ)
	var worm_state_from_save = Dance.WormState.new().file_get(save_game)
	save_game.close()

	print(worm_state_from_save)
	
func save_states_var(worm_state : Dance.WormState):
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
	var from_dict = Dance.WormState.from_dict(dict_from_save)
	print(from_dict)
	
func save_states_buffer(worm_state : Dance.WormState):
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
	var from_dict = Dance.WormState.from_dict(dict)
	print(from_dict)
	
