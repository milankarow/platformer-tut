extends Node2D


enum {WATCH,ALERT,JUMP}
onready var animation_player = $AnimationPlayer


var state = WATCH


func _physics_process(delta):
	match state:
		WATCH: watch_state()
		ALERT: alert_state()
		JUMP: jump_state()

func watch_state():
	animation_player.play("Dart_eyes")
	
func alert_state():
	state = JUMP

func jump_state():
	print("jump")
	animation_player.play("Jump")
	yield(animation_player,"animation_finished")
	state = WATCH


func _on_AlertZone_body_entered(body):
	if body is Player:
		print("Player")
		state = jump_state()


func _on_AlertZone_body_exited(body):
	pass # Replace with function body.
