extends RichTextLabel

export (float) var revelation_speed = 75 # characters per second
export (int) var font_size = 24
export (int) var content_margin_left = 25
export (int) var content_margin_top = 15

var time_elapsed = 0
var auto_reveal = true

#var height setget ,get_height

signal passage_added

#enum ALIGN { linear,square,none }
#export(DROPOFF) var dropoff = DROPOFF.linear


func _ready():
#	yield(get_tree(), "idle_frame")
#	rect_size.y = get_v_scroll().max_value
#	if rect_size.y > get_parent().rect_size.y:
#		rect_size.y = get_parent().rect_size.y - 100
	
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

func set_text(data):
	bbcode_text = strip_passage_text(data)
	
	set_style()

func set_style():
	var sb = get_stylebox("normal")
	sb.content_margin_left = content_margin_left
	sb.content_margin_top = content_margin_top
	sb.content_margin_right = content_margin_left
	sb.content_margin_bottom = content_margin_top

func strip_passage_text(data):
	var i = data.find("[[")
	var text = ""
	if i < 0:
		text = data
	else:
		text = data.left(i)
	
	while text.ends_with("\n"):
		text = text.rstrip("\n")
	while text.begins_with("\n"):
		text = text.lstrip("\n")
	
	var ss = text.split("//")
	var count = 0
	text = ""
	for s in ss:
		if count+1 == ss.size():
			text = str(text, s)
		elif count % 2 == 0:
			text = str(text, s, "[i]")
		else:
			text = str(text, s, "[/i]")
		count += 1
	
	return text

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