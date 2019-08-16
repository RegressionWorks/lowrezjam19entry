extends Node



func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "opening":
		get_tree().change_scene("res://scenes/stage/Stage.tscn")