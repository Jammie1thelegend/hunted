extends Node2D
var nono_square = []
var pwr_ups_spawned = 0
@onready var pwr_up_scene = preload("res://power_up.tscn")

func _ready():
	nono_square.append(get_tree().get_first_node_in_group("player"))
	nono_square.append(get_tree().get_first_node_in_group("hunter"))
	spawn_pwr_up()
	spawn_pwr_up()
	spawn_pwr_up()
	
	##testing rig for changing how fast wait time decreases
	#var Tpwr_ups_spawned = 0
	#var wait_Time = 6
	#while wait_Time != 0.5:
		#Tpwr_ups_spawned += 0.1
		#wait_Time = clampf(6 - pow(1.5, Tpwr_ups_spawned), 0.5, 7)
		#print(" wait_time: ", snapped(wait_Time, 0.0001), " amnt decreased: ", 
		#pow(1.5, Tpwr_ups_spawned), " pwr_ups_spawned: ", Tpwr_ups_spawned * 10)

func spawn_pwr_up():
	pwr_ups_spawned += 0.1
	var wait_Time = clampf(6 - pow(1.5, pwr_ups_spawned), 0.5, 7)
	$spawn_timer.start(wait_Time)
	if nono_square.size() <= 13:
		var current = pwr_up_scene.instantiate()
		call_deferred("add_child", current)
		current.visible = false
		nono_square.append(current)
		choose_pos(current)

func choose_pos(node):
	var touching = false
	randomize()
	node.global_position = Vector2(randi_range(20, 1132), randi_range(20, 628))
	for n in nono_square:
		if n != node:
			if node.global_position.distance_to(n.global_position) <= 150:
				touching = true
				break
	if touching == true:
		choose_pos(node)
		return
	else:
		node.visible = true
