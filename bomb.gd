extends Area2D

func start_explode():
	$AnimationPlayer.play("explode")

func _on_body_entered(body):
	if body.is_in_group("player") and $Timer.is_stopped():
		$Timer.start()
		body.take_dmg()

func _on_animation_player_animation_finished(_anim_name):
	queue_free()
