extends KinematicBody2D


export(int) var GRAVITY = 10
export(int) var MAX_SPEED = 80
export(int) var JUMP_SPEED = -210
export(int) var MIN_JUMP_SPEED = -105
export(int) var RUN_ACCELERATION = 10
export(int) var RUN_FRICTION = 10
export(int) var AIR_FRICTION = 1

var velocity = Vector2.ZERO

onready var animatedSprite = $AnimatedSprite

func _ready():
	animatedSprite.frames = load("res://PlayerGreenSkin.tres")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	apply_gravity()
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")


	if input.x == 0:
		apply_friction()
		animatedSprite.animation = "Idle"
	else:
		apply_acceleration(input.x)
		animatedSprite.animation = "Run"
		if input.x > 0:
			animatedSprite.flip_h = true
		else:
			animatedSprite.flip_h = false
		
	if is_on_floor():
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = JUMP_SPEED
	else:
		animatedSprite.animation = "Jump"
		if Input.is_action_just_released("ui_up") and velocity.y < MIN_JUMP_SPEED:
			velocity.y = MIN_JUMP_SPEED
	
	var was_in_air = not is_on_floor()
	velocity = move_and_slide(velocity, Vector2.UP)
	var just_landed = is_on_floor() and was_in_air
	if just_landed:
		animatedSprite.animation = "Run"
		animatedSprite.frame = 1
	
func apply_gravity():
	velocity.y += GRAVITY
	velocity.y = min(velocity.y, 300)

func apply_acceleration(amount):
	velocity.x = move_toward(velocity.x, MAX_SPEED * amount, RUN_ACCELERATION)

func apply_friction():
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, RUN_FRICTION)
	else:	
		velocity.x = move_toward(velocity.x, 0, AIR_FRICTION)	
