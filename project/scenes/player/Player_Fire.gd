extends Area2D



func _on_Player_Fire_body_entered(body):
	pass


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fire":
		queue_free()
