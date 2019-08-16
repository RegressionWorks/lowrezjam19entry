extends Area2D



func _on_KeyCard_body_entered(body):
	if body.name == "Player":
		body.keys += 1
		self.queue_free()
