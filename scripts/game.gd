extends Node2D

@onready var player := $Player
@onready var lasers := $Lasers
@onready var asteroids := $Asteroids
@onready var hud := $UI/HUD
@onready var game_over := $UI/GameOverScreen
@onready var player_spawn_pos := $PlayerSpawnPos
@onready var player_spwan_area := $PlayerSpawnPos/PlayerSpawnArea

var score: int:
	set (value):
		score = value
		hud.score = score
		
var lives: int:
	set (value):
		lives = value
		hud.init_lives(lives)

var asteroid_scene = preload("res://scenes/asteroid.tscn")

func _ready():
	score = 0
	lives = 3
	game_over.visible = false
	player.connect("laser_shot", _on_player_laser_shot)
	player.connect("died", _on_player_died)
	
	for asteroid in asteroids.get_children():
		asteroid.connect("exploded", _on_asteroid_exploded)


func _process(_delta):
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()


func _on_player_laser_shot(laser):
	$LaserSound.play()
	lasers.add_child(laser)


func _on_player_died():
	$PlayerDieSound.play()
	lives -= 1
	player.global_position = player_spawn_pos.global_position
	
	if lives <= 0:
		await get_tree().create_timer(2).timeout
		game_over.visible = true
	else:
		await get_tree().create_timer(1).timeout
	
		while !player_spwan_area.is_empty:
			await get_tree().create_timer(0.1).timeout
	
		player.respawn(player_spawn_pos.global_position)


func _on_asteroid_exploded(pos, size, points):
	$AsteroidHitSound.play()
	score += points
	
	match size:
		Asteroid.AsteroidSize.LARGE:
			spawn_asteroid(pos, Asteroid.AsteroidSize.MEDIUM)
			spawn_asteroid(pos, Asteroid.AsteroidSize.MEDIUM)
		Asteroid.AsteroidSize.MEDIUM:
			spawn_asteroid(pos, Asteroid.AsteroidSize.SMALL)
			spawn_asteroid(pos, Asteroid.AsteroidSize.SMALL)
		Asteroid.AsteroidSize.SMALL:
			pass


func spawn_asteroid(pos, size):
	var a = asteroid_scene.instantiate()
	
	a.global_position = pos
	a.size = size
	a.connect("exploded", _on_asteroid_exploded)
	asteroids.call_deferred("add_child", a)
