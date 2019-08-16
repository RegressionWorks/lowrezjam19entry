extends Area2D






func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fire":
		queue_free()
