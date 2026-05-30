extends Node


var gun_sound_list : Array = [
	preload("res://Sound/blast-37988.mp3") # 0 
]

var monster_sound_list : Array = [
	preload("res://Sound/monster_grunt_1.mp3") # 0
	
]


func play_gun_sound(sound_index):
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = gun_sound_list[sound_index]
	get_tree().current_scene.sound_root.add_child(audio_player)
	audio_player.play()
	audio_player.finished.connect(audio_player.queue_free)
	
func play_monster_sound(sound_index):
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = monster_sound_list[sound_index]
	get_tree().current_scene.sound_root.add_child(audio_player)
	audio_player.play()
	audio_player.finished.connect(audio_player.queue_free)
