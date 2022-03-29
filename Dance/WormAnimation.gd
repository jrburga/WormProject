extends Animation
class_name WormAnimation

func worm_track_path(idx, value_name) -> String:
	return "Worm" + str(idx) + ":" + value_name
	
func worm_add_tracks(worm : WormKB2D):
	var num_segs = worm.num_segments
	var idx = 0
	for seg_idx in num_segs:
		add_track(TYPE_VALUE)
		track_set_path(idx, worm_track_path(seg_idx, "position"))
		idx += 1
		
		add_track(TYPE_VALUE)
		track_set_path(idx, worm_track_path(seg_idx, "rotation_degrees"))
		idx += 1
		
		add_track(TYPE_VALUE)
		track_set_path(idx, worm_track_path(seg_idx, "velocity"))
		idx += 1
		
func worm_tracks_insert_keys(worm : WormKB2D, time : float):
	var num_segs = worm.num_segments
	var idx = 0
	var head = worm.get_head()
	var offset_transform = Transform2D()
	for seg_idx in num_segs:
		var segment = worm.get_segment(seg_idx) as WormBodyKB2D
		
		var position_rel = head.to_local(segment.position)
		track_insert_key(idx, time, position_rel)
		idx += 1
		
		var rotation_rel = segment.rotation_degrees - head.rotation_degrees
		track_insert_key(idx, time, rotation_rel)
		idx += 1
		
		var velocity_rel = segment.velocity.rotated(-head.rotation)
		track_insert_key(idx, time, velocity_rel)
		idx += 1

func worm_value_tracks_interpolate(worm : WormKB2D, time_sec : float):
	var out_dict = {}
	
	var head = worm.get_head()
	var idx = 0
	var time = 0.0
	out_dict['position'] = []
	out_dict['rotation'] = []
	out_dict['velocity'] = []
	for seg_idx in worm.num_segments:	
		var segment = worm.get_segment(seg_idx) as WormBodyKB2D
		
		var position_rel = value_track_interpolate(idx, time)
		out_dict['position'].append(position_rel)
		idx += 1
		
		var rotation_rel = value_track_interpolate(idx, time)
		out_dict['rotation'].append(rotation_rel)
		idx += 1

		var velocity_rel = value_track_interpolate(idx, time)
		out_dict['velocity'].append(velocity_rel)
		idx += 1
		
	return out_dict
		
func worm_value_tracks_interpolate_local_to_worm(worm : WormKB2D, time_sec : float):
	var out_dict = {}
	
	var head = worm.get_head()
	var idx = 0
	var time = 0.0
	out_dict['position'] = []
	out_dict['rotation'] = []
	out_dict['velocity'] = []
	for seg_idx in worm.num_segments:	
		var segment = worm.get_segment(seg_idx) as WormBodyKB2D
		
		var position_rel = value_track_interpolate(idx, time)
		var position_global = head.transform.xform(position_rel)
		out_dict['position'].append(position_global)
		idx += 1
		
		var rotation_rel = value_track_interpolate(idx, time)
		var rotation_global = rotation_rel + head.rotation
		out_dict['rotation'].append(rotation_global)
		idx += 1

		var velocity_rel = value_track_interpolate(idx, time)
		var velocity_global = velocity_rel.rotated(head.rotation)
		out_dict['velocity'].append(velocity_global)
		idx += 1
		
	return out_dict

		
func tracks_take_single_frame(frame_time : float):
	tracks_trim_left(frame_time)
	tracks_trim_right( 0)
	
func tracks_trim_left(trim_time : float):
	var key_count = track_get_key_count(0)
	var trim_index = 0
	for key_idx in key_count:
		var key_time = track_get_key_time(0, key_idx)
		if key_time >= trim_time:
			trim_index = key_idx
			break
			
	print("trim left: %d - %d - %d" % [trim_index, 0, key_count])
	if trim_index > 0:
		var trim_key_time = track_get_key_time(0, trim_index)
		var track_count = get_track_count()
		for key_idx in trim_index:
			for track_idx in track_count:
				track_remove_key(track_idx, 0)
				
		var new_key_count = track_get_key_count(0)
		for key_idx in new_key_count:
			for track_idx in track_count:
				var key_time = track_get_key_time(track_idx, key_idx)
				var new_time = key_time - trim_key_time
				track_set_key_time(track_idx, key_idx, new_time)
				
		length = track_get_key_time(0, new_key_count - 1)
		
func tracks_trim_right(trim_time : float):
	var key_count = track_get_key_count(0)
	var trim_index = key_count - 1
	for key_idx in range(key_count-1, -1, -1):
		var key_time = track_get_key_time(0, key_idx)
		if key_time <= trim_time:
			trim_index = key_idx
			break
			
	print("trim right: %d - %d - %d" % [trim_index, 0, key_count])
	if trim_index < key_count - 1:
		var trim_key_time = track_get_key_time(0, trim_index)
		var track_count = get_track_count()
		for key_idx in range(key_count-1, trim_index, -1):
			for track_idx in track_count:
				track_remove_key(track_idx, key_idx)
				
		var new_key_count = track_get_key_count(0)
		length = track_get_key_time(0, new_key_count - 1)
