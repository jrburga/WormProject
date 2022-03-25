tool
extends Node
class_name DanceDetector

# Called when the node enters the scene tree for the first time.
func _ready():
#	test_save()
	pass
	
func test_save():
	print('testing move serialization')
	var dance_move = DanceMove.new()
	dance_move.times.append(0)
	var segment_state = Dance.SegmentState.new()
	var worm_state = Dance.WormState.new()
#
	worm_state.segment_states.append(segment_state)
	worm_state.grabbed_segments.append(0)
	dance_move.worm_states.append(worm_state)
	
	dance_move.save_move("Move_Test")
	print(dance_move)
	

