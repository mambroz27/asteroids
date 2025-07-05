class_name Asteroid extends Area2D

@export var base_speed := 65.0
@export var size := AsteroidSize.LARGE

@onready var sprite := $Sprite2D
@onready var collision := $CollisionShape2D

var movement_vector := Vector2(0, -1)
var speed := base_speed

enum AsteroidSize{LARGE, MEDIUM, SMALL}

signal exploded(position, size)


func _ready():
	rotation = randf_range(0, 2*PI)
	
	match size:
		AsteroidSize.LARGE:
			speed = randf_range(base_speed, base_speed * 1.5)
			sprite.texture = preload("res://assets/textures/asteroid_big_04.png")
			collision.set_deferred("shape", preload("res://resources/asteroid_collision_large.tres"))
		AsteroidSize.MEDIUM:
			speed = randf_range(base_speed * 2, base_speed * 3)
			sprite.texture = preload("res://assets/textures/asteroid_med_02.png")
			collision.set_deferred("shape", preload("res://resources/asteroid_collision_medium.tres"))
		AsteroidSize.SMALL:
			speed = randf_range(base_speed * 2, base_speed * 4)
			sprite.texture = preload("res://assets/textures/asteroid_tiny_01.png")
			collision.set_deferred("shape", preload("res://resources/asteroid_collision_small.tres"))


func _physics_process(delta):
	global_position += movement_vector.rotated(rotation) * speed * delta
	
	# Reset the player position to the opposite
	# side when they travel off the screen
	var screen_size = get_viewport_rect().size
	var collision_radius = collision.shape.radius
	
	# Reset Y
	if (global_position.y + collision_radius) < 0:
		global_position.y = (screen_size.y + collision_radius)
	elif (global_position.y - collision_radius) > screen_size.y:
		global_position.y = (0 - collision_radius)
	
	# Reset X
	if (global_position.x + collision_radius) < 0:
		global_position.x = (screen_size.x + collision_radius)
	elif (global_position.x - collision_radius) > screen_size.x:
		global_position.x = (0 - collision_radius)


func explode():
	emit_signal("exploded", global_position, size)
	queue_free()
