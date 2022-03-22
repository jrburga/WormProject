extends Node2D

export(PackedScene) var Fish : PackedScene = null

func _ready():
	$SpawnFishTimer.connect("timeout", self, "_on_SpawnFishTimer_timeout")
	
	
func _on_SpawnFishTimer_timeout():
	_spawn_fish_random()
	
func _spawn_fish_random():
	if Fish:
		var new_fish = Fish.instance() as Node2D
		
		var spawn_position = Vector2()
		
		var path_idx = randi() % 2
		if path_idx == 0:
			spawn_position = ($SpawnPath2D_0 as Path2D).curve.interpolate(0, randf())
		if path_idx == 1:
			spawn_position = ($SpawnPath2D_1 as Path2D).curve.interpolate(0, randf())
			
		var fish_velocity = Vector2()
		if spawn_position.x > 0:
			fish_velocity = Vector2(-200, 0)
		else:
			fish_velocity = Vector2(200, 0)
		new_fish.global_position = spawn_position
		new_fish.velocity = fish_velocity
		add_child(new_fish)
		
	else:
		print("no fish to spawn!")
		
		
func _process(delta):
	pass
	
