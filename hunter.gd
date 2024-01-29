extends CharacterBody2D
var speed = 25000
var friction = 0.1
var acceleration = 0.3
var just_hit = false
var max_angle = 20
var current_pwr_up: String
@onready var timer = $Timer
@onready var anim = $AnimatedSprite2D
@onready var player = $"../player"
@onready var following = player
@onready var ray = $RayCast2D
@onready var pwr_timer = $pwr_timer
@onready var pwr_ups = $RayCast2D/pwr_ups
@onready var proj_scene = preload("res://projectile.tscn")
@onready var bomb_scene = preload("res://bomb.tscn")
@onready var audio = $AudioStreamPlayer
@onready var sling_sounds = [preload("res://assets/sounds/power_ups/sling1.wav"),
preload("res://assets/sounds/power_ups/sling2.wav"),
preload("res://assets/sounds/power_ups/sling3.wav")]

func _ready():
	timer.timeout.connect(look_pwr_up.bind(null))
	timer.start()
	#set_physics_process(false)

func look_pwr_up(excluded: Node):
	var nearest = null
	var nearest_distance = 10000
	var pwr_up_nodes = get_tree().get_nodes_in_group("pwr_up")
	pwr_up_nodes.erase(excluded)
	for p in pwr_up_nodes:
		if p.global_position.distance_to(global_position) <= nearest_distance:
			nearest = p
			nearest_distance = p.global_position.distance_to(global_position)
	if nearest != null:
		following = nearest

func get_input():
	if following == null:
		look_pwr_up(null)
	var angle = int(rad_to_deg(get_angle_to(following.global_position)))
	angle = snapped(angle, 10)
	var dir = Vector2.ZERO
	if ray.is_colliding() and ray.get_collider() == player and just_hit == true:
		angle = -1 * angle
	if angle in range(-180, -90):
		dir = Vector2(-1, -1)
	elif angle in range(90, 180):
		dir = Vector2(-1, 1)
	elif angle in range(-90, 0):
		dir = Vector2(1, -1)
	elif angle in range(0, 90):
		dir = Vector2(1, 1)
	else:
		var temp = str(angle)
		match temp:
			"0":
				dir = Vector2(1, 0)
			"90":
				dir = Vector2(0, 1)
			"180":
				dir = Vector2(-1, 0)
			"-90":
				dir = Vector2(0, -1)
	return dir

func _physics_process(delta):
	var direction = get_input()
	if direction.length() > 0:
		velocity = velocity.lerp(direction.normalized() * speed, acceleration)
		anim.play("walk")
	else:
		velocity = velocity.lerp(Vector2.ZERO, friction)
	velocity = velocity * delta
	move_and_slide()
	deal_with_ray()

func deal_with_ray():
	ray.look_at(player.global_position)
	ray.rotation_degrees -= 90
	if ray.is_colliding() and ray.get_collider() == player and just_hit == false:
		deal_dmg()
		timer.start()

func deal_dmg():
	player.take_dmg()
	look_pwr_up(null)
	just_hit = true
	await get_tree().create_timer(0.5).timeout
	just_hit = false

func use_pwr_up(type, caller):
	current_pwr_up = type
	match type:
		"speed":
			speed = 37500
			anim.speed_scale = 1.2
		"sling":
			pwr_ups.play("sling")
			pwr_ups.visible = true
			while pwr_ups.frame != 7:
				await pwr_ups.frame_changed
			shoot(type)
			randomize()
			audio.stream = sling_sounds.pick_random()
			audio.play()
		"sword":
			ray.target_position.y = 40
			pwr_ups.animation = "sword"
			pwr_ups.visible = true
		"bomb":
			caller.queue_free()
			var bomb = bomb_scene.instantiate()
			owner.call_deferred("add_child", bomb)
			bomb.global_position = global_position
			bomb.start_explode()
		"slimer":
			shoot(type)
	pwr_timer.start()
	await pwr_timer.timeout
	match type:
		"speed":
			speed = 25000
			anim.speed_scale = 1
		"sword":
			ray.target_position.y = 20
			pwr_ups.visible = false
	current_pwr_up = ""

func shoot(type):
	var proj = proj_scene.instantiate()
	owner.call_deferred("add_child", proj)
	proj.global_position = to_global(ray.target_position.rotated(deg_to_rad(-90)))
	var ray_rot = ray.rotation_degrees +90
	var possible_angles = range(ray_rot - max_angle, ray_rot + max_angle + 1)
	randomize()
	proj.rotation_degrees = possible_angles.pick_random()
	proj.assign_proj_type(type)
