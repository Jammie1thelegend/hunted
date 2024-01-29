extends PlayerState
class_name CarryIdle

func Enter_state():
	general_aud.stop()
	anim.play("carry_idle")

func Update(delta: float):
	if player.moving == true:
		Transitioned.emit(self, "carry")
	elif player.current_carry == null:
		Transitioned.emit(self, "idle")

