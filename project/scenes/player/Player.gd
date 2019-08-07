extends KinematicBody2D
class_name Player

const ACC = 4
const SPEED = 20
const FRIC = 1
const GRAV = 30

var motion = Vector2()

func _physics_process(delta: float) -> void:
	move_and_slide(motion)
	movement_logic()
	#air_logic()
	sprite_dir()

func movement_logic():
	if Input.is_action_pressed("ui_right") && !Input.is_action_pressed("ui_left"):
		motion.x = clamp((motion.x + ACC), 0, SPEED)
	elif Input.is_action_pressed("ui_left") && !Input.is_action_pressed("ui_right"):
		motion.x = clamp((motion.x - ACC), -SPEED, 0)
	else:
		motion.x = lerp(motion.x, 0, FRIC) 

func air_logic():
	if !is_on_floor():
		motion.y = GRAV
	else:
		motion.y = 0

func sprite_dir():
	if motion.x > 0:
		$Sprite.flip_h = false
	if motion.x < 0:
		$Sprite.flip_h = true