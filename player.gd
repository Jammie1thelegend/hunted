extends CharacterBody2D
var speed = 40000
var friction = 0.1
var acceleration = 0.3
var carrying = false
var can_carry = true
var power_time = 5
var is_idle = false
var moving = false
# index 0 = hold_time, index 1 = cooldown
@onready var current_carry = null
@onready var anim = $AnimatedSprite2D
@onready var general_aud = $general
@onready var HP_manager = $hp_manager
@onready var cooldown_bar = $cooldown
@onready var hold_time_bar = $hold_time
@onready var tween

func _ready():
	cooldown_bar.visible = false
	hold_time_bar.visible = false

func get_input():
	var input = Vector2.ZERO
	input.x = int(Input.is_action_pressed('right')) - int(Input.is_action_pressed('left'))
	input.y = int(Input.is_action_pressed('down')) - int(Input.is_action_pressed('up'))
	if Input.is_action_just_pressed("carry") and can_carry == true:
		carrying = true
		box_action()
	if Input.is_action_just_released("carry"):
		carrying = false
		box_action()
	return input

func _physics_process(delta):
	var direction = get_input()
	if direction.length() > 0:
		velocity = velocity.lerp(direction.normalized() * speed, acceleration)
		moving = true
	else:
		velocity = velocity.lerp(Vector2.ZERO, friction)
		moving = false
	velocity = velocity * delta
	move_and_slide()

func box_action():
	if carrying == true:
		get_tree().call_group("pwr_up", "detect_player")
	if current_carry == null:
		return
	if tween:
		tween.kill()
	if carrying == true:
		box_stuff(false)
		hold_time_bar.value = 100
		tween = create_tween()
		tween.tween_property(hold_time_bar, "value", 0, power_time)
		tween.finished.connect(end_hold_time)
		hold_time_bar.visible = true
			
	else:
		box_stuff(true)
		current_carry.get_node("CollisionShape2D").disabled = false
		current_carry = null
		can_carry = false
		cooldown_bar.value = 100
		tween = create_tween()
		tween.tween_property(cooldown_bar, "value", 0, float(power_time) / 2)
		tween.finished.connect(end_cooldown)
		cooldown_bar.visible = true

func box_stuff(IO: bool):
	cooldown_bar.visible = IO
	hold_time_bar.visible = not IO
	current_carry.set_physics_process(not IO)
	current_carry.visible = IO
	

func end_cooldown():
	cooldown_bar.visible = false
	can_carry = true

func end_hold_time():
	hold_time_bar.visible = false
	carrying = false
	box_action()

func take_dmg():
	if HP_manager.changing_hp == true:
		while HP_manager.changing_hp == true:
			await get_tree().create_timer(0.34).timeout
			if HP_manager.changing_hp == false:
				update_hp("ff5959")
				HP_manager.lose_hp(-1)
				break
	else: 
		update_hp("ff5959")
		HP_manager.lose_hp(-1)

func update_hp(colour):
	$AnimatedSprite2D.modulate = colour
	await get_tree().create_timer(0.1).timeout
	$AnimatedSprite2D.modulate = "ffffff"


func heal(amount):
	if HP_manager.changing_hp == true:
		while HP_manager.changing_hp == true:
			await get_tree().create_timer(0.34).timeout
			if HP_manager.changing_hp == false:
				update_hp("40f780")
				HP_manager.gain_hp(amount, false)
				break
	else: 
		update_hp("40f780")
		HP_manager.gain_hp(amount, false)
