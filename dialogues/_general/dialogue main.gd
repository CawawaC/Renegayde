extends Node2D

onready var character_portraits = $characters.get_children()

signal new_episode

func bring_characters_forward(character_names):
	print(str("character forwards: ", character_names))
	return
	for c in character_names:
		var portrait = find_portrait(c)

func find_portrait(c_name):
	for p in character_portraits:
		if p.name == c_name:
			return p

func _on_text_new_episode(episode):
	emit_signal("new_episode", episode)
