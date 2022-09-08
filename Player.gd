extends KinematicBody2D


export(int) var GRAVITY = 10
export(int) var MAX_SPEED = 80
export(int) var JUMP_SPEED = -210
export(int) var RUN_ACCELERATION = 10
export(int) var RUN_FRICTION = 10

var velocity = Vector2.ZERO

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	apply_gravity()
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	if input.x == 0:
		apply_friction()
	else:
		apply_acceleration(input.x)	
		
	if is_on_floor():
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = JUMP_SPEED

	velocity = move_and_slide(velocity, Vector2.UP)
	
func apply_gravity():
	velocity.y += GRAVITY

func apply_acceleration(amount):
	velocity.x = move_toward(velocity.x, MAX_SPEED * amount, RUN_ACCELERATION)

func apply_friction():
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, RUN_FRICTION)
	else:	
		velocity.x = move_toward(velocity.x, 0, RUN_FRICTION/10)	
