extends KinematicBody2D
class_name Player

const ACC = 8
const SPEED = 40
const FRIC = 1
const GRAV = 160
const JUMP_SPEED = 80
const WALL_GRAB_GRAVITY = 20
const WALL_JUMP_FRIC = 0.065
const WALL_JUMP_YSPEED = 70
const WALL_JUMP_XSPEED = 100
const WALL_JUMP_SPEED_CUTOFF = 50

var motion: Vector2 = Vector2()
var priority_anims: Array = Array()
var anim_player: AnimationPlayer

var health = 3

func _ready():
	anim_player = $Sprite/AnimationPlayer
	for anim in $Sprite/AnimationPlayer.get_animation_list():
		if anim == "run" or anim == "idle" or anim == "fall":
			continue
		priority_anims.append(anim)

func _physics_process(delta: float) -> void:
	movement_logic()
	handle_wall_grab()
	handle_wall_jump(delta)
	handle_gravity(delta)
	handle_jump()
	handle_landed()
	gun_shooting()
	motion = move_and_slide(motion, Vector2(0, -1))
	set_animations()
	sprite_dir()
	die()

func movement_logic():
	if wall_jumping:
		return
	if Input.is_action_pressed("ui_right") && !Input.is_action_pressed("ui_left"):
		motion.x = clamp((motion.x + ACC), 0, SPEED)
		$Sprite/Gun_Muzzle.position.x = abs($Sprite/Gun_Muzzle.position.x)
	elif Input.is_action_pressed("ui_left") && !Input.is_action_pressed("ui_right"):
		motion.x = clamp((motion.x - ACC), -SPEED, 0)
		$Sprite/Gun_Muzzle.position.x = -abs($Sprite/Gun_Muzzle.position.x)
	else:
		motion.x = lerp(motion.x, 0, FRIC) 

var wall_grabbing = false
var wall_snapping = false
var wall_jumping = false

func handle_wall_grab():
	var wall_grab_before = wall_grabbing
	wall_grabbing = !on_floor() and has_wall()
	if !wall_grabbing:
		wall_snapping = false
	if !wall_grab_before and wall_grabbing:
		wall_snapping = true
	if wall_snapping:
		#motion.y = 0
		anim_player.play("wall_snap")
	if !wall_snapping and wall_grabbing:
		motion.y = WALL_GRAB_GRAVITY
		anim_player.play("wall_fall")
	if wall_grabbing and Input.is_action_pressed("jump"):
		wall_jumping = true
		motion.x = WALL_JUMP_XSPEED if has_wall_left() else -WALL_JUMP_XSPEED
		motion.y = -WALL_JUMP_YSPEED
		anim_player.play("jump")

func handle_wall_jump(delta):
	if wall_jumping:
		motion.x = lerp(motion.x, 0, WALL_JUMP_FRIC)
		if abs(motion.x) < WALL_JUMP_SPEED_CUTOFF:
			wall_jumping = false

func has_wall():
	return has_wall_left() or has_wall_right()

func has_wall_left():
	return (
		$WallLeftUp.is_colliding() or
		$WallLeftDown.is_colliding())
	
func has_wall_right():
	return ($WallRightUp.is_colliding() or
		$WallRightDown.is_colliding())


func handle_gravity(delta: float):
	if !on_floor() and !wall_grabbing:
		motion.y += delta * GRAV

var jumping = false

func handle_jump():
	jumping = false
	if !on_floor():
		return
	if Input.is_action_pressed("jump"):
		motion.y = -JUMP_SPEED
		jumping = true
		anim_player.play("jump")

var falling = true
var landed = false

func handle_landed():
	# landed will be true on a single frame
	landed = falling and on_floor()
	falling = !on_floor() && motion.y > 10
	if landed:
		anim_player.play("land")

var shooting = false
var can_shoot = true
onready var muzzle = $Sprite/Gun_Muzzle
const FIRE = preload("res://scenes/player/Player_Fire.tscn")

func gun_shooting():
	shooting = false
	if can_shoot && Input.is_action_just_pressed("fire"):
		motion.x = 0
		shooting = true
		can_shoot = false
		$FireTimer.start()
		var fire = FIRE.instance()
		fire.get_node('Sprite').flip_h = $Sprite/Gun_Muzzle.position.x < 0
		get_parent().add_child(fire)
		fire.position = muzzle.global_position
		anim_player.play("shoot")
		anim_player.seek(0)

func _on_FireTimer_timeout():
	can_shoot = true

var keys = 0
var dead = false

func hurt():
	health -= 1
	if !dead:
		$HurtAnim.play("hurt")

func die():
	if health == 0:
		dead = true
		set_physics_process(false)
		anim_player.play("death")

func set_animations():
	var current = anim_player.current_animation
	var is_priority = priority_anims.has(current)
	var is_playing = anim_player.is_playing()
	var is_priority_playing = is_priority and is_playing
	if !is_priority_playing:
		if on_floor() and motion.x != 0:
			anim_player.play("run")
		elif on_floor() and motion.x == 0:
			anim_player.play("idle")
		elif !on_floor() and motion.y > 2:
			anim_player.play("fall")

func sprite_dir():
	if motion.x > 0:
		$Sprite.flip_h = false
	if motion.x < 0:
		$Sprite.flip_h = true

func on_floor():
	return $FloorLeft.is_colliding() or $FloorRight.is_colliding()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "wall_snap":
		wall_snapping = false
	if anim_name == "death":
		get_tree().reload_current_scene()


