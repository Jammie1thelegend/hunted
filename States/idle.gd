extends PlayerState
class_name Idle

func Enter_state():
	MainThemeController.fade_down()
	general_aud.stream = load("res://assets/sounds/player/panting.wav")
	general_aud.play()
	anim.play("idle")

func Update(delta: float):
	if player.current_carry != null:
		Transitioned.emit(self, "carry")
	if player.moving == true:
		Transitioned.emit(self, "walk")
