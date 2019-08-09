extends Node2D

func _process(delta):
	handle_quit()

func handle_quit():
	if Input.is_action_pressed("ui_quit"):
		get_tree().quit()
