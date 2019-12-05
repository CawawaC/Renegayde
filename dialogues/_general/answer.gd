extends Button

var link_id
signal on_answer_pressed


func _on_answer_pressed():
	emit_signal("on_answer_pressed", link_id)
