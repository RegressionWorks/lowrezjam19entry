extends Node2D

func _process(delta):
	handle_quit()

func handle_quit():
	if Input.is_action_pressed("ui_quit"):
		get_tree().quit()




func _on_Goal_body_entered(body):
	if body.name == "Player":
		if body.keys == 4:
			get_tree().quit()
