extends KinematicBody2D
class_name Player

const ACC = 8
const SPEED = 40
const FRIC = 1
const GRAV = 160

const JUMP_SPEED = 80

var motion = Vector2()

func _physics_process(delta: float) -> void:
	movement_logic()
	handle_gravity(delta)
	handle_jump()
	motion = move_and_slide(motion, Vector2(0, -1))
	set_animations()
	sprite_dir()

func movement_logic():
	if Input.is_action_pressed("ui_right") && !Input.is_action_pressed("ui_left"):
		motion.x = clamp((motion.x + ACC), 0, SPEED)
	elif Input.is_action_pressed("ui_left") && !Input.is_action_pressed("ui_right"):
		motion.x = clamp((motion.x - ACC), -SPEED, 0)
	else:
		motion.x = lerp(motion.x, 0, FRIC) 

func handle_gravity(delta: float):
	motion.y += delta * GRAV

func handle_jump():
	if !is_on_floor():
		return
	if Input.is_action_pressed("jump"):
		motion.y = -JUMP_SPEED
		$Sprite/AnimationPlayer.play("jump")

func set_animations():
	if !is_on_floor() and motion.y > 0:
		$Sprite/AnimationPlayer.play("fall")
	elif motion.x == 0:
		$Sprite/AnimationPlayer.play("idle")

func sprite_dir():
	if motion.x > 0:
		$Sprite.flip_h = false
	if motion.x < 0:
		$Sprite.flip_h = true
