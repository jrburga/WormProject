extends Node2D

export(PackedScene) var Fish : PackedScene = null

func _ready():
	$SpawnFishTimer.connect("timeout", self, "_on_SpawnFishTimer_timeout")
	
	
func _on_SpawnFishTimer_timeout():
	_spawn_fish_random()
	
func _spawn_fish_random():
	if Fish:
		var new_fish = Fish.instance() as Node2D
		
		var num_spawn_positions = $SpawnPositions.get_child_count()
		var spawn_idx = randi() % num_spawn_positions
		
		var spawn_position = $SpawnPositions.get_child(spawn_idx) as Position2D
		
		var fish_velocity = Vector2()
		if spawn_position.position.x > 0:
			fish_velocity = Vector2(-200, 0)
		else:
			fish_velocity = Vector2(200, 0)
		new_fish.global_position = spawn_position.global_position
		new_fish.velocity = fish_velocity
		add_child(new_fish)
		
	else:
		print("no fish to spawn!")
		
		
func _process(delta):
	pass
	
