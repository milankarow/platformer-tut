extends Node

const HURT = preload("res://Sounds/ouch.wav")
const JUMP1 = preload("res://Sounds/jump_1.wav")
const JUMP2 = preload("res://Sounds/jump_2.wav")
const LAND = preload("res://Sounds/land3.wav")
const BGM = preload("res://Sounds/HeatleyBros - HeatleyBros VI - 8 Bit Play.mp3")

onready var audioPlayers = $AudioPlayers
onready var musicPlayer = $MusicPlayer/MusicStream

func _ready():
	play_music(BGM)

func play_sound(sound):
	for stream in audioPlayers.get_children():
		if not stream.playing:
			stream.stream = sound
			stream.play()
			break

func play_music(track):
	musicPlayer.stream = track
	musicPlayer.play()
