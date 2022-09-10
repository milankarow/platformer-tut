extends KinematicBody2D
class_name Player

enum { MOVE, CLIMB }

export(Resource) var moveData

var velocity = Vector2.ZERO
var state = MOVE

onready var animatedSprite = $AnimatedSprite
onready var ladderCheck = $LadderCheck

func _ready():
	animatedSprite.frames = load("res://PlayerGreenSkin.tres")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):


	var input = Vector2.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")
	
	match state:
		CLIMB: climb_state(input)
		MOVE: move_state(input)


		
func move_state(input):
	
	if is_on_ladder() and input.y < 0:
		state = CLIMB
	
	apply_gravity()
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
	
func climb_state(input):
	if not is_on_ladder():
		state = MOVE
	if input.length() != 0:
		animatedSprite.animation = "Run"
	else:
		animatedSprite.animation = "Idle"
				
	velocity = input * 50
	velocity = move_and_slide(velocity, Vector2.UP)

func is_on_ladder():
	if not ladderCheck.is_colliding(): return false
	var collider = ladderCheck.get_collider()
	if not collider is Ladder: return false
	return true
	
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
