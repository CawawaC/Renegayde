extends Node

var player_name = "jessie"

var emotions = {
	"JESSIE": "NEUTRAL",
	"BAR-MAN": "NEUTRAL"
	}

var characters = [
	"jessie",
	"bar-man",
	"horace",
	"radio",
	"description"
]

var text_boxes = {
	"jessie": load("res://dialogues/text boxes/jessie.tscn"),
	"radio": load("res://dialogues/text boxes/radio.tscn"),
	"horace": load("res://dialogues/text boxes/horace.tscn"),
	"description": load("res://dialogues/text boxes/description.tscn")
}