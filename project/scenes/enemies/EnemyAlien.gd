extends Node2D


var health = 2

func _physics_process(delta):
	if health == 0:
		queue_free()

func _on_Attack_Collider_body_entered(body):
	if body.name == "Player":
		body.hurt()


func _on_Hurtbox_area_entered(area):
	if area.name == "Player_Fire":
		health -= 1

