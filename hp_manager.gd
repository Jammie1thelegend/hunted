extends Node2D

const HP_SCENE = preload("res://hp.tscn")
const MAX_HP = 16
var HP_instances = []
var HP = 0
var changing_hp = false
@onready var hurt_aud = $"../hurt"
@onready var hit_sounds = [preload("res://assets/sounds/player/hit1.wav"), 
preload("res://assets/sounds/player/hit2.wav"), 
preload("res://assets/sounds/player/hit3.wav")]

func _ready():
	gain_hp(4, true)
	
func add_to_HP_array(node):
	var hp_pt = []
	hp_pt.append(node)
	hp_pt.append(abs(node.region_rect.position.x -48) / 24)
	HP_instances.append(hp_pt)

func check_amnt(amount):
	var Amount_true = amount
	var tmp_hp = HP + amount
	var prev_HP = HP
	HP = clampi(tmp_hp, 0, MAX_HP)
	if HP == MAX_HP:
		Amount_true = 0
		while Amount_true <= (MAX_HP -1) - prev_HP:
			Amount_true += 1
	elif HP == 0:
		Amount_true = 0
		while (prev_HP -1) + Amount_true >= 0:
			Amount_true -= 1
	return Amount_true

func gain_hp(amount, starter: bool):
	changing_hp = true
	amount = check_amnt(amount)
	var tmp = amount
	while tmp >= 1:
		if HP_instances.is_empty() == false:
			var last_pt = HP_instances[-1]
			var last_pt_anim = last_pt[0].get_node("AnimationPlayer")
			if last_pt[1] == 1:
				if starter == false:
					last_pt_anim.play_backwards("half_hp")
					await last_pt_anim.animation_finished
				else:
					last_pt_anim.play("RESET")
				last_pt[1] = 2
			elif last_pt[1] == 2:
				var h = HP_SCENE.instantiate()
				call_deferred("add_child", h)
				last_pt_anim = h.get_node("AnimationPlayer")
				align_hearts(h)
				if starter == false:
					last_pt_anim.play_backwards("no_hp")
					await last_pt_anim.animation_finished
				else:
					last_pt_anim.play("RESET")
				add_to_HP_array(h)
		else:
			var h = HP_SCENE.instantiate()
			call_deferred("add_child", h)
			var pt_anim = h.get_node("AnimationPlayer")
			align_hearts(h)
			if starter == false:
				pt_anim.play_backwards("no_hp")
				await pt_anim.animation_finished
			else:
				pt_anim.play("RESET")
			add_to_HP_array(h)
		if starter == false:
			handle_sound(load("res://assets/sounds/player/health_up.wav"))
			tmp -= 1
		else:
			tmp -= 2
	changing_hp = false
	#print("HP_instances: ", HP_instances)

func align_hearts(H):
	var hearts_arr = []
	for i in HP_instances:
		hearts_arr.append(i[0])
	if H != null:
		hearts_arr.append(H)
	if hearts_arr.size() <= (MAX_HP / 4) +1:
		#print("1 row")
		for h in hearts_arr:
			var h_ind = hearts_arr.find(h) +0.5
			var tot_length = float(hearts_arr.size()) /2
			h.position.x = (h_ind - tot_length) * ((24 * h.scale.x) / 1.2)
			h.position.y = 0
	else:
		#print("2 rows")
		var tmp_hearts_arr = []
		while tmp_hearts_arr.size() <= (MAX_HP / 4) +1:
			tmp_hearts_arr.append(hearts_arr.pop_front())
		for h in hearts_arr:
			var h_ind = hearts_arr.find(h) +0.5
			var tot_length = float(hearts_arr.size()) /2
			h.position.x = (h_ind - tot_length) * ((24 * h.scale.x) / 1.2)
			h.position.y = 0
		for th in tmp_hearts_arr:
			var th_ind = tmp_hearts_arr.find(th) +0.5
			var tot_length = float(tmp_hearts_arr.size()) /2
			th.position.x = (th_ind - tot_length) * ((24 * th.scale.x) / 1.2)
			th.position.y = -(24 * th.scale.x)

func lose_hp(amount):
	changing_hp = true
	amount = abs(check_amnt(amount))
	if HP == 0:
		print("insert death function here")
		get_tree().paused = true
		get_parent().get_parent().get_node("respawn").show()
		return
	var tmp = amount
	while tmp >= 1:
		var last_pt = HP_instances[-1]
		var last_pt_anim = last_pt[0].get_node("AnimationPlayer")
		if last_pt[1] == 2:
			last_pt_anim.play("half_hp")
			await last_pt_anim.animation_finished
			last_pt[1] = 1
		elif last_pt[1] == 1:
			last_pt_anim.play_backwards("no_hp")
			await last_pt_anim.animation_finished
			HP_instances.erase(last_pt)
			align_hearts(null)
			last_pt[0].queue_free()
		randomize()
		handle_sound(hit_sounds.pick_random())
		tmp -= 1
	changing_hp = false

func handle_sound(sound):
	hurt_aud.stream = sound
	hurt_aud.play()
