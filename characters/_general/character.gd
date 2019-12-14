extends Node2D


func init():
	var e = Game.char_emotions[name]
	apply_emotion(e)

func apply_emotion(emotion):
	var found = false
	for c in get_children():
		if c.name == emotion:
			c.visible = true
			found = true
		else:
			c.visible = false
		if not found:
			$"default".visible = true