extends Area2D
var SPEED = 400
var max_pos = Vector2.ZERO
var type1 = ""
@onready var player_col = $player_col
@onready var wall_col = $wall_col
@onready var player = get_tree().get_first_node_in_group("player")
@onready var hunter = get_tree().get_first_node_in_group("hunter")
@onready var slime_time = $slime_time
@onready var audio = $AudioStreamPlayer
@onready var anim = $AnimationPlayer
@onready var slime_sounds = [preload("res://assets/sounds/power_ups/slime1.wav"),
preload("res://assets/sounds/power_ups/slime2.wav"),
preload("res://assets/sounds/power_ups/slime3.wav")]

func _ready():
	set_physics_process(false)
	monitoring = false
	anim.play("RESET")
	

func assign_proj_type(type):
	await self.ready
	type1 = type
	match type:
		"sling":
			$AnimatedSprite2D.frame = 1
			player_col.set_shape(load("res://assets/resource files/circle_proj.tres"))
			monitoring = true
			wall_col.monitoring = false
		"slimer":
			$AnimatedSprite2D.frame = 0
			player_col.set_shape(load("res://assets/resource files/capsule_proj.tres"))
			SPEED = 150
			var rand_max = transform.x * SPEED * randi_range(1, 3)
			max_pos = global_position + rand_max
			SPEED = 400
	set_physics_process(true)

func _physics_process(delta):
	if max_pos == Vector2.ZERO:
		position += transform.x * SPEED * delta
	elif global_position <= max_pos:
		position += transform.x * SPEED * delta
	else:
		set_physics_process(false)
		rotation_degrees = 0
		monitoring = true

func _on_body_entered_player_col(body):
	if body == player:
		set_deferred("monitoring", false)
		if type1 == "sling":
			player.take_dmg()
			queue_free()
		else:
			randomize()
			audio.stream = slime_sounds.pick_random()
			audio.play()
			anim.play("slime_stick")
			await anim.animation_finished
			queue_free()
	elif body != hunter:
		queue_free()

func change_player_spd(speed):
	player.speed = speed

func _on_wall_col_body_entered(_body):
	set_physics_process(false)
	rotation_degrees = 0
	set_deferred("monitoring", true)
	wall_col.set_deferred("monitoring", false)

func point_at_player():
	look_at(player.global_position)
	#rotation_degrees += 90
