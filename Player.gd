extends KinematicBody2D
class_name Player

enum { MOVE, CLIMB }

export(Resource) var moveData

var velocity = Vector2.ZERO
var state = MOVE
var double_jump
var buffered_jump = false
var coyote_jump = false

onready var animatedSprite: = $AnimatedSprite
onready var ladderCheck: = $LadderCheck
onready var jumpBufferTimer: = $JumpBufferTimer
onready var coyoteJumpTimer: = $CoyoteJumpTimer

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
	
	if input.x == 0: #check horizontal movement input
		apply_friction()
		animatedSprite.animation = "Idle"
	else:
		apply_acceleration(input.x)
		animatedSprite.animation = "Run"
		animatedSprite.flip_h = input.x > 0

	if is_on_floor():
		reset_double_jump()
	else: 
		animatedSprite.animation = "Jump"

	if can_jump():
		input_jump()
	else:
		input_jump_release()		
		input_double_jump()	
		buffer_jump()

	
	var was_in_air = not is_on_floor()

	velocity = move_and_slide(velocity, Vector2.UP)
	var just_landed = is_on_floor() and was_in_air
	if just_landed:
		animatedSprite.animation = "Run"
		animatedSprite.frame = 1
		SoundPlayer.play_sound(SoundPlayer.LAND)
	
	var just_left_ground = not (is_on_floor() or was_in_air)
	if just_left_ground and velocity.y >= 0:
		coyote_jump = true
		coyoteJumpTimer.start()
		
	
func climb_state(input):
	if not is_on_ladder():
		state = MOVE
	if input.length() != 0:
		animatedSprite.animation = "Run"
	else:
		animatedSprite.animation = "Idle"
				
	velocity = input * moveData.CLIMB_SPEED
	velocity = move_and_slide(velocity, Vector2.UP)

func player_die():
	SoundPlayer.play_sound(SoundPlayer.HURT)
	get_tree().reload_current_scene()
	
func input_jump():
	if Input.is_action_just_pressed("ui_up") or buffered_jump:
		SoundPlayer.play_sound(SoundPlayer.JUMP1)
		velocity.y = moveData.JUMP_SPEED
		buffered_jump = false

func input_jump_release():
	if Input.is_action_just_released("ui_up") and velocity.y < moveData.MIN_JUMP_SPEED:
		velocity.y = moveData.MIN_JUMP_SPEED
		
func input_double_jump():
	if Input.is_action_just_pressed("ui_up") and double_jump > 0:
		velocity.y = moveData.JUMP_SPEED
		SoundPlayer.play_sound(SoundPlayer.JUMP2)
		double_jump -= 1

func buffer_jump():
	if Input.is_action_just_pressed("ui_up"):
		buffered_jump = true
		jumpBufferTimer.start()	

func reset_double_jump():
	double_jump = moveData.DOUBLE_JUMP_COUNT
	
func can_jump():
	return is_on_floor() or coyote_jump

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

func _on_JumpBufferTimer_timeout():
	buffered_jump = false

func _on_CoyoteJumpTimer_timeout():
	coyote_jump = false
