extends RichTextLabel

export (float) var revelation_speed = 75 # characters per second

var time_elapsed = 0
var auto_reveal = true
#var height setget ,get_height

signal passage_added

func _ready():
	yield(get_tree(), "idle_frame")
	rect_size.y = get_v_scroll().max_value
#	rect_size.y = get_content_height()
	emit_signal("passage_added", self)

func _process(delta):
	if auto_reveal and percent_visible < 100:
		time_elapsed += delta
		visible_characters = revelation_speed * time_elapsed

func _input(event):
	if event.is_action_pressed("ui_accept"):
		end_revelation()

func end_revelation():
	percent_visible = 100
	auto_reveal = false

func start_revelating():
	percent_visible = 0
	time_elapsed = 0
	auto_reveal = true

func move_up(shift_height, duration):
	var target_height = rect_position.y - shift_height
	
	rect_position.y -= shift_height

#	tween.interpolate_method(self, "animate_pos",
#		rect_position.y, rect_position.y-shift_height, duration,
#		Tween.TRANS_CIRC, Tween.EASE_OUT)
#
#	if not tween.is_active():
#		tween.start()

#func get_height():
#	return get_v_scroll().get_max()