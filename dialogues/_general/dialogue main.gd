extends Node2D

onready var character_portraits = $characters.get_children()

signal new_episode

func _ready():
	Game.init_missing_characters()
	
	$text.start()
	
	for c in character_portraits:
		c.init()

func bring_characters_forward(character_names):
	print_debug(str("character forwards: ", character_names))
	
	for c in character_portraits:
		if character_names.has(c.name):
			c.modulate = Color.white
		else:
			c.modulate = Color("#474747")

func find_portrait(c_name):
	for p in character_portraits:
		if p.name == c_name.to_lower():
			return p

func _on_text_new_episode(episode):
	emit_signal("new_episode", episode)

func _on_text_emotion_change(char_emo):
	var p = find_portrait(char_emo[0])
	if p:
		p.apply_emotion(char_emo[1].to_lower())