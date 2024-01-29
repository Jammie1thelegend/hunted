extends Node2D

func _ready():
	for c in get_children():
		if c.name == "respawn":
			c.hide()

func _on_button_button_down():
	if name == "tutorial":
		get_tree().change_scene_to_file("res://main scene.tscn")
	elif name == "level":
		get_tree().paused = false
		get_tree().change_scene_to_file("res://tutorial.tscn")
