extends Control

@onready var score = $Score:
	set(value):
		score.text = "SCORE: " + str(value)

@onready var lives := $Lives

var lives_scene = preload("res://scenes/lives.tscn")

func init_lives(amount):
	for life in lives.get_children():
		life.queue_free()
	
	for i in amount:
		var life = lives_scene.instantiate()
		
		lives.add_child(life)
