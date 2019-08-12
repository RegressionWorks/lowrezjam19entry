extends KinematicBody2D
class_name Player

const ACC = 8
const SPEED = 40
const FRIC = 1
const GRAV = 160
const JUMP_SPEED = 80

var motion = Vector2()
var priority_anims: Array = Array()

func _ready():
	for anim in $Sprite/AnimationPlayer.get_animation_list():
		if anim == "run" or anim == "idle":
			continue
		priority_anims.append(anim)

func _physics_process(delta: float) -> void:
	movement_logic()
	handle_gravity(delta)
	handle_jump()
	handle_landed()
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
	if !on_floor():
		motion.y += delta * GRAV

var jumping = false
func handle_jump():
	jumping = false
	if !on_floor():
		return
	if Input.is_action_pressed("jump"):
		motion.y = -JUMP_SPEED
		jumping = true

var falling = true
var landed = false
func handle_landed():
	# landed will be true on a single frame
	landed = falling and on_floor()
	falling = !on_floor() && motion.y > 10

func set_animations():
	var current = $Sprite/AnimationPlayer.current_animation
	var is_priority = priority_anims.has(current)
	var is_playing = $Sprite/AnimationPlayer.is_playing()
	var is_priority_playing = is_priority and is_playing
	if !on_floor() and motion.y > 2:
		$Sprite/AnimationPlayer.play("fall")
	if landed:
		$Sprite/AnimationPlayer.play("land")
	if jumping:
		$Sprite/AnimationPlayer.play("jump")
	elif !is_priority_playing:
		if on_floor() and motion.x != 0:
			$Sprite/AnimationPlayer.play("run")
		elif on_floor() and motion.x == 0:
			$Sprite/AnimationPlayer.play("idle")

func sprite_dir():
	if motion.x > 0:
		$Sprite.flip_h = false
	if motion.x < 0:
		$Sprite.flip_h = true

func on_floor():
	return $FloorLeft.is_colliding() or $FloorRight.is_colliding()
