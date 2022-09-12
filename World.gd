extends Node2D


onready var player = $Player

func _ready():
	VisualServer.set_default_clear_color(Color.lightblue)
	#SoundPlayer.play_music(SoundPlayer.BGM)

func _process(delta):
	if player.position.y > 300: player.player_die()
