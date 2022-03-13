tool
extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var current_hat : Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var player_config = get_node("/root/PlayerConfig")
	player_config.connect("hat_id_changed", self, "_on_hat_id_changed")
	_set_hat_by_id(player_config.hat_id)
	
func _set_hat_by_id(hat_id):
	var hat_db = get_node("/root/HatDB")
	var hat_res = hat_db.get_hat_resource(hat_id)
	
	if current_hat != null:
		current_hat.queue_free()
		current_hat = null
	
	if hat_res is HatResource:
		var hat_scene = hat_res.HatScene
		if hat_scene:
			var hat = hat_scene.instance()
			add_child(hat)
			current_hat = hat
#			current_hat.o
	elif hat_id != "":
		print("Invalid hat id!", hat_id)
		
			
func _on_hat_id_changed(new_hat_id):
	_set_hat_by_id(new_hat_id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

