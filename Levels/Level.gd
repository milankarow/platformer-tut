extends Node2D


const PlayerScene = preload("res://Player.tscn")

var player_spawn_location = Vector2.ZERO

onready var player = $Player
onready var camera = $Camera2D
onready var timer = $Timer

func _ready():
	VisualServer.set_default_clear_color(Color.lightblue)
	player.connect_camera(camera)
	player_spawn_location = player.global_position
	Events.connect("player_died",self, "_on_player_died")
	Events.connect("hit_checkpoint", self, "_on_hit_checkpoint")
	#SoundPlayer.play_music(SoundPlayer.BGM)

func _on_player_died():
	timer.start(0.2)
	yield(timer, "timeout")
	var player = PlayerScene.instance()
	player.position = player_spawn_location
	add_child(player)
	player.connect_camera(camera)

func _on_hit_checkpoint(checkpoint_position):
	player_spawn_location = checkpoint_position


#func _process(delta):
#
#	if get_node_or_null("Player") != null:
#		if player.position.y > 300: player.player_die()
