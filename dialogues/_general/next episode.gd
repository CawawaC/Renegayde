extends Button

var next_episode

signal episode_pressed



func _on_episode_pressed():
	emit_signal("episode_pressed", next_episode)
