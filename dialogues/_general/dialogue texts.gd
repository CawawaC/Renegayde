extends CanvasLayer

export (String) var dialogue_name
export (PackedScene) var answer_template
export (PackedScene) var exotic_answer_template
export (PackedScene) var next_template
export (PackedScene) var next_episode_template

export var passages_v_padding = 10
export var upshifting_duration = 0.5
export var anchor_offset = 0.5


var dialogue
var player_name = Game.player_name

var passage
#onready var tween = $"tween"

signal line_speaker
signal new_episode
signal emotion_change

func _ready():
	var file = File.new()
	file.open(str("res://texts/", dialogue_name, ".json"), file.READ)
	var text = file.get_as_text()
	var json_result = JSON.parse(text)
	
	dialogue = json_result.result
	
func start():
	set_passage(get_starting_passage())

func get_starting_passage():
	var start_id = dialogue.startnode
	return find_passage_data(start_id)
	
func remove_passages():
	for p in $passages.get_children():
		p.queue_free()

func set_passage(passage_data):
	var tags = passage_data.tags
	var speaker = get_speaker(passage_data.tags)
	
	var passage = Game.get_textbox(speaker)
	
	passage.connect("passage_added", self, "on_passage_added")
#	position_passage(passage, speaker)
	
	remove_passages()
	
	emit_signal("line_speaker", [speaker])
	
	apply_emotions(get_emotion_applications(tags))
	
	remove_answers()
	if passage_data.has("links"):
		print_debug(passage_data.links)
		add_answers(passage, passage_data)
	else:
		add_button_to_next_episode(passage_data)
	
	passage.set_text(passage_data.text)
	$passages.add_child(passage)
	passage.start_revelating()

func add_answers(passage, passage_data):
	if links_to_player(passage_data.links): # links to PC lines
		for i in range(0, passage_data.links.size()):
			
			var link = passage_data.links[i]
			
			if not link.has("pid"):
				printerr("No pid on link: ", link, "in passage_data: ", passage_data.pid)
				continue
			
			var target_passage = find_passage_data(link.pid)
			var conditions = get_emotion_conditions(target_passage.tags)
			var passage_available = is_passage_available(conditions)
			
			if passage_available:
				
				var answer
				if conditions.size() > 0:
					answer = exotic_answer_template.instance()
				else:
					answer = answer_template.instance()
				
				answer.text = link.name
				answer.link_id = link.pid
				answer.connect("on_answer_pressed", self, "on_answer_pressed")
				$answers.add_child(answer)
				print_debug(answer)
	elif passage_data.links.size() == 1: # links to a NPC line
#		on_answer_pressed(passage_data.links[0].pid)
		var answer = next_template.instance()
		var link = passage_data.links[0]
		answer.link_id = link.pid
		answer.connect("on_answer_pressed", self, "on_answer_pressed")
		$answers.add_child(answer)
	else:
		print_debug("hoho")

func add_button_to_next_episode(data):
	var instance = next_episode_template.instance()
	
	var next_episode = extract_next_episode_name(data.text)
	data.text = clear_next_episode_instruction(data.text)
	print_debug(next_episode)
	
	instance.next_episode = next_episode
	instance.connect("episode_pressed", self, "on_episode_pressed")
	$answers.add_child(instance)

func clear_next_episode_instruction(text):
	var i = text.find("{")
	var j = text.find("}")
	text.erase(i, j-i+1)
	return text

func on_episode_pressed(episode):
	print_debug("next episode")
	emit_signal("new_episode", episode)

func extract_next_episode_name(text):
	var ss = text.split("{")
	var episode_name = ss[1].split("}")[0]
	return episode_name


func extract_destination(text):
	return text

# If at least one of the links goes to a player answer, the player can choose between links.
# This is done to temporarily fix the case where multiple links go to both player and NPC answers.
# Which is bad and should not happen
func links_to_player(links):
	var value = false
	for l in links:
		if not l.has("pid"):
			continue
		var passage_data = find_passage_data(l.pid)
	
		if get_speaker(passage_data.tags) == Game.player_name.to_lower() or get_speaker(passage_data.tags) == "radio" or get_speaker(passage_data.tags) == "description":
			value = true
	return value

func remove_answers():
	for a in $answers.get_children():
		a.queue_free()

func get_speaker(tags):
	for t in tags:
		if Game.characters.has(t.to_lower()):
			return t.to_lower()

func get_emotion_applications(tags):
	var es = []
	for t in tags:
		if t.find("+") >= 0:
			es.push_back(t)
	return es

func is_passage_available(tags):
	var available = true
	for t in tags:
		var ss = t.split(":")
		
		var character = ""
		if ss.size() < 1 or ss[0] == "":
			character = "jessie"
		else:
			character = ss[0].to_lower()
			
		var emotion = ss[1].to_lower()
		
		print_debug(str("Emotional check: ", character, " : ", emotion, " : "))
		if Game.char_emotions[character] != emotion.to_lower():
			available = false
			break
		else:
			print_debug("passed")
	return available

func get_emotion_conditions(tags):
	var es = []
	for t in tags:
		if t.find(":") >= 0:
			es.push_back(t)
	return es

func apply_emotions(emotional_tags):	
	for t in emotional_tags:
		var ss = t.split("+")
		
		var character = ""
		if ss.size() < 1 or ss[0] == "":
			character = "jessie"
		else:
			character = ss[0].to_lower()
			
		var emotion = ss[1].to_lower()
		
		print_debug(str(character, " --> ", emotion))
		Game.char_emotions[character] = emotion.to_lower()
		
		print_debug(str("Emotional change: ", character, " --> ", emotion))
		emit_signal("emotion_change", [character, emotion])

func get_emotions(tags):
	var es = []
	for t in tags:
		if Game.emotions.has(t.to_lower()):
			es.push_back(t.to_lower())
	return es


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
	passage.rect_position.y = 280
#	passage.rect_global_position.y = $answers.rect_global_position.y - passage.rect_size.y

#	match speaker:
#		"jessie":
#			passage.anchor_left = anchor_offset
#		"radio":
#			passage.anchor_left = passage.anchor_left
#		"description":
#			passage.anchor_left = passage.anchor_left
#		_:
#			passage.anchor_right = 1 - anchor_offset
	
#	passage.rect_size.y = get_viewport().size.y - passage.rect_global_position.y
