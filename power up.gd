extends Area2D
var type = ""
var neighbors = 0
@onready var last_collide = null
@onready var player = get_tree().get_first_node_in_group("player")
@onready var hunter = get_tree().get_first_node_in_group("hunter")
@onready var anim = $AnimationPlayer

func _ready():
	anim.play("RESET")
	set_physics_process(false)
	randomize()
	$AnimatedSprite2D.frame = randi() % 5
	#$AnimatedSprite2D.frame = 3
	match str($AnimatedSprite2D.frame):
		"0":
			type = "speed"
		"1":
			type = "sling"
		"2":
			type = "sword"
		"3":
			type = "bomb"
		"4":
			type = "slimer"

func detect_player():
	if last_collide == player:
		player.current_carry = self
		$CollisionShape2D.disabled = true

func _physics_process(_delta):
	global_position = player.global_position + Vector2(0, 10)

func _on_body_entered(body):
	last_collide = body
	if body == hunter:
		if hunter.current_pwr_up == "sword" and type == "sling":
			hunter.look_pwr_up(self)
			return
		if hunter.current_pwr_up == "sling" and type == "sword":
			hunter.look_pwr_up(self)
			return
		if hunter.current_pwr_up == type:
			hunter.look_pwr_up(self)
			return
		hunter.use_pwr_up(type, self)
		hunter.following = player
		get_parent().nono_square.erase(self)
		anim.play("get_destroyed")
		await anim.animation_finished
		queue_free()

func _on_body_exited(body):
	if body == last_collide:
		last_collide = null

func _on_area_entered(area):
	if area.is_in_group("pwr_up"):
		neighbors += 1
		if neighbors >= 2:
			if hunter.following == self:
				hunter.look_pwr_up(null)
			get_parent().nono_square.erase(self)
			anim.play("get_destroyed")
			await anim.animation_finished
			player.heal(1)
			queue_free()

func _on_area_exited(area):
	if area != null and area.is_in_group("pwr_up"):
		neighbors -= 1
