extends PlayerState
class_name Carry

func Enter_state():
	general_aud.stop()
	anim.play("carry")

func Update(delta: float):
	if player.moving == false:
		Transitioned.emit(self, "carryidle")
	elif player.current_carry == null:
		Transitioned.emit(self, "walk")

