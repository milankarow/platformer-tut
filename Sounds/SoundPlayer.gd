extends Node

const HURT = preload("res://Sounds/ouch.wav")
const JUMP1 = preload("res://Sounds/jump_1.wav")
const JUMP2 = preload("res://Sounds/jump_2.wav")
const LAND = preload("res://Sounds/land.wav")

onready var audioPlayers = $AudioPlayers

func play_sound(sound):
	for stream in audioPlayers.get_children():
		if not stream.playing:
			stream.stream = sound
			stream.play()
			break
