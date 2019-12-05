extends CanvasLayer

export (String) var dialogue_name
export (PackedScene) var answer_template
export (PackedScene) var next_template
export (PackedScene) var next_episode_template

export var passages_v_padding = 10
export var upshifting_duration = 0.5
export var anchor_offset = 0.5


var dialogue
var player_name = Game.player_name

onready var passage = $"passage"
onready var tween = $"tween"

signal line_speaker
signal new_episode

func _ready():
	var file = File.new()
	file.open(str("res://texts/", dialogue_name, ".json"), file.READ)
	var text = file.get_as_text()
	var json_result = JSON.parse(text)
	
	dialogue = json_result.result
	
	set_passage(get_starting_passage())

func get_starting_passage():
	var start_id = dialogue.startnode
	return find_passage_data(start_id)
	

func set_passage(passage_data):
	var tags = passage_data.tags
	var speaker = get_speaker(passage_data.tags)
	
#	var previous_passage = null
#	if($passages.get_child_count() > 0):
#		previous_passage = $passages.get_children()[$passages.get_child_count()-1]
#		print(previous_passage.bbcode_text)
	
	var passage = Game.text_boxes[speaker].instance()
	passage.bbcode_text = strip_passage_text(passage_data.text)
	passage.connect("passage_added", self, "on_passage_added")
	position_passage(passage, speaker)
	
	$passages.add_child(passage)
	
	emit_signal("line_speaker", [speaker])
	
#	var emotion = get_imperative_emotion(tags)
#	print(emotion)

	
	remove_answers()
	if passage_data.has("links"):
		print(passage_data.links)
		add_answers(passage, passage_data)
	else:
		add_button_to_next_episode(passage_data)
	
	passage.start_revelating()

func add_answers(passage, passage_data):
	if links_to_player(passage_data.links): # links to PC lines
		for i in range(0, passage_data.links.size()):
			var link = passage_data.links[i]
			var answer = answer_template.instance()
			answer.text = link.name
			answer.link_id = link.pid
			answer.connect("on_answer_pressed", self, "on_answer_pressed")
			$answers.add_child(answer)
			print(answer)
	elif passage_data.links.size() == 1: # links to a NPC line
#		on_answer_pressed(passage_data.links[0].pid)
		var answer = next_template.instance()
		var link = passage_data.links[0]
		answer.link_id = link.pid
		answer.connect("on_answer_pressed", self, "on_answer_pressed")
		$answers.add_child(answer)
	else:
		print("hoho")

func add_button_to_next_episode(data):
	var instance = next_episode_template.instance()
	
	var next_episode = extract_next_episode_name(data.text)
	
	instance.next_episode = next_episode
	instance.connect("episode_pressed", self, "on_episode_pressed")
	$answers.add_child(instance)

func on_episode_pressed(episode):
	emit_signal("new_episode", episode)

func extract_next_episode_name(text):
	var ss = text.split("{")
	var episode_name = ss[1].split("}")[0]
	return episode_name

func strip_passage_text(passage):
	var i = passage.find("[[")
	var text = ""
	if i < 0:
		text = passage
	else:
		text = passage.left(i)
	
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

func extract_destination(text):
	return text

func links_to_player(links):	
	var passage_data = find_passage_data(links[0].pid)
	print(passage_data.tags)
	if !passage_data.has("tags"):
		return false
	if get_speaker(passage_data.tags) == Game.player_name.to_lower() or get_speaker(passage_data.tags) == "radio":
		return true
	else:
		return false

func remove_answers():
	for a in $answers.get_children():
		a.queue_free()

func get_speaker(tags):
	for t in tags:
		if Game.characters.has(t.to_lower()):
			return t.to_lower()

func get_conditional_emotion(tags):
	if tags.has("LOVE"):
		return "LOVE"
	elif tags.has("HATE"):
		return "HATE"
	else:
		return ""

func get_imperative_emotion(tags):
	if tags.has("LOVE"):
		return "LOVE"
	elif tags.has("HATE"):
		return "HATE"
	else:
		return ""

func on_answer_pressed(link_id):
	var passage_data = find_passage_data(link_id)
	set_passage(passage_data)

func find_passage_data(link_id):
	for p in dialogue.passages:
		if p.pid == link_id:
			return p
	print(str("No passage found for id: ", link_id))

func on_passage_added(passage):
	var up = passage.get_size().y
	move_passages_up(up + passages_v_padding, true)

func move_passages_up(shift_height, exclude_current_passage):
	for child in $"passages".get_children():
		if !exclude_current_passage or child != passage:
			child.move_up(shift_height + passages_v_padding, upshifting_duration)
			child.modulate.a = (child.rect_position.y + child.rect_size.y + 100) / ($passages.rect_size.y)

func position_passage(passage, speaker):
	passage.rect_position.y = 300
#	passage.rect_global_position.y = $answers.rect_global_position.y - passage.rect_size.y

	match speaker:
		"jessie":
			passage.anchor_left = anchor_offset
		"radio":
			passage.anchor_left = passage.anchor_left
		"description":
			passage.anchor_left = passage.anchor_left
		_:
			passage.anchor_right = 1 - anchor_offset
