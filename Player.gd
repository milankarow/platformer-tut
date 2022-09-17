extends KinematicBody2D
class_name Player

enum { MOVE, CLIMB }

export(Resource) var moveData

var velocity = Vector2.ZERO
var state = MOVE
var double_jump = 1
var buffered_jump = false
var coyote_jump = false

onready var animatedSprite: = $AnimatedSprite
onready var ladderCheck: = $LadderCheck
onready var jumpBufferTimer: = $JumpBufferTimer
onready var coyoteJumpTimer: = $CoyoteJumpTimer
onready var remoteTransform: = $RemoteTransform2D

func _ready():
	animatedSprite.frames = load("res://PlayerGreenSkin.tres")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):


	var input = Vector2.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.y = Input.get_axis("move_up", "move_down")
	
	match state:
		CLIMB: climb_state(input)
		MOVE: move_state(input, delta)

	if position.y > 300: player_die()

		
func move_state(input, delta):
	
	if is_on_ladder() and input.y < 0:
		state = CLIMB
	
	apply_gravity(delta)
	
	if input.x == 0: #check horizontal movement input
		apply_friction(delta)
		animatedSprite.animation = "Idle"
	else:
		apply_acceleration(input.x, delta)
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
	queue_free()
	Events.emit_signal("player_died")
	#get_tree().reload_current_scene()

func connect_camera(camera):
	var camera_path = camera.get_path()
	remoteTransform.remote_path = camera_path
	
func input_jump():
	if Input.is_action_just_pressed("ui_accept") or buffered_jump:
		SoundPlayer.play_sound(SoundPlayer.JUMP1)
		velocity.y = moveData.JUMP_SPEED
		buffered_jump = false

func input_jump_release():
	if Input.is_action_just_released("ui_accept") and velocity.y < moveData.MIN_JUMP_SPEED:
		velocity.y = moveData.MIN_JUMP_SPEED
		
func input_double_jump():
	if Input.is_action_just_pressed("ui_accept") and double_jump > 0:
		velocity.y = moveData.JUMP_SPEED
		SoundPlayer.play_sound(SoundPlayer.JUMP2)
		double_jump -= 1

func buffer_jump():
	if Input.is_action_just_pressed("ui_accept"):
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
	
func apply_gravity(delta):
	velocity.y += moveData.GRAVITY * delta
	velocity.y = min(velocity.y, 300)

func apply_acceleration(amount, delta):
	velocity.x = move_toward(velocity.x, moveData.MAX_SPEED * amount, moveData.RUN_ACCELERATION * delta)

func apply_friction(delta):
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, moveData.RUN_FRICTION * delta)
	else:	
		velocity.x = move_toward(velocity.x, 0, moveData.AIR_FRICTION *delta)	

func _on_JumpBufferTimer_timeout():
	buffered_jump = false

func _on_CoyoteJumpTimer_timeout():
	coyote_jump = false
