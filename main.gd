extends Node2D

export (PackedScene) var starting_scene

onready var scenes = $scenes

func _ready():
	initialize()

func hide_main_menu():
	$"main menu".hide()

func _on_start_pressed():
	hide_main_menu()
	var scene = starting_scene.instance()
	add_scene(scene)

func load_scene(scene_name):
	var res = load(str("res://dialogues/", scene_name, ".tscn"))
	var scene = res.instance()
	remove_current_scene()
	add_scene(scene)

func remove_current_scene():
	for s in scenes.get_children():
		s.queue_free()
	
func add_scene(scene):
	scenes.add_child(scene)
	scene.connect("new_episode", self, "load_scene")

func initialize():
	Game.init_char_emotions()