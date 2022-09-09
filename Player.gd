extends KinematicBody2D
class_name Player

export(Resource) var moveData

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
		animatedSprite.flip_h = input.x > 0
		
	if is_on_floor():
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = moveData.JUMP_SPEED
	else:
		animatedSprite.animation = "Jump"
		if Input.is_action_just_released("ui_up") and velocity.y < moveData.MIN_JUMP_SPEED:
			velocity.y = moveData.MIN_JUMP_SPEED
	
	var was_in_air = not is_on_floor()
	velocity = move_and_slide(velocity, Vector2.UP)
	var just_landed = is_on_floor() and was_in_air
	if just_landed:
		animatedSprite.animation = "Run"
		animatedSprite.frame = 1
	
func apply_gravity():
	velocity.y += moveData.GRAVITY
	velocity.y = min(velocity.y, 300)

func apply_acceleration(amount):
	velocity.x = move_toward(velocity.x, moveData.MAX_SPEED * amount, moveData.RUN_ACCELERATION)

func apply_friction():
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, moveData.RUN_FRICTION)
	else:	
		velocity.x = move_toward(velocity.x, 0, moveData.AIR_FRICTION)	
