extends Node

var player_name = "jessie"

onready var text_box_factory = load("res://dialogues/text boxes/factory.tscn").instance()

func _ready():
	print("svf")
	

var characters = [
	"jessie",
	"bar-man",
	"horace",
	"radio",
	"description",
	"berta",
	"nona",
	"cowgirl-npc"
]

var emotions = [
	"ashamed",
	"pumped",
	"bruised",
	"fine",
	"misinformed",
	"trueInfo",
	"nottalked",
	"impressed",
	"unimpressed",
	"foolish",
	"interested",
	"annoyed",
	"bored",
	"flirting",
	"happy",
	"pity"
]

var char_emotions = {}

func init_char_emotions(): 
	for c in characters:
		char_emotions[c] = "fine"

func init_missing_characters():
	for c in characters:
		if !char_emotions.has(c):
			char_emotions[c] = "fine"

func get_textbox(speaker):
	var t = text_box_factory.get_node(speaker)
	if t:
		return t.duplicate()
	else:
		return text_box_factory.get_node("description").duplicate()

var text_boxes = {
	"jessie": load("res://dialogues/text boxes/jessie.tscn"),
	"radio": load("res://dialogues/text boxes/radio.tscn"),
	"horace": load("res://dialogues/text boxes/horace.tscn"),
	"description": load("res://dialogues/text boxes/description.tscn"),
	"berta": load("res://dialogues/text boxes/berta.tscn"),
	"nona": load("res://dialogues/text boxes/nona.tscn"),
	"cowgirl-npc": load("res://dialogues/text boxes/description.tscn")
}