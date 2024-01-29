extends PlayerState
class_name Walk

func Enter_state():
	MainThemeController.fade_up()
	general_aud.stop()
	anim.play("walk")

func Update(delta: float):
	if player.current_carry != null:
		Transitioned.emit(self, "carry")
	if player.moving == false:
		Transitioned.emit(self, "idle")
