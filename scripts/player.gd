class_name Player extends CharacterBody2D

@export var acceleration := 10.0
@export var deceleration := 4.0
@export var max_speed := 400.0
@export var rotation_speed := 300.0
@export var rate_of_fire := 0.25

@onready var sprite := $Sprite2D
@onready var cannon := $Cannon

var laser_cooldown := false
var alive := true
var laser_scene := preload("res://scenes/laser.tscn")

signal laser_shot(laser)
signal died


func _process(_delta):
	if Input.is_action_pressed("shoot"):
		if !laser_cooldown:
			laser_cooldown = true
			shoot_laser()
			
			await get_tree().create_timer(rate_of_fire).timeout
			laser_cooldown = false


func _physics_process(delta):
	var input_vector := Vector2(0, Input.get_axis("accelerate", "decelerate"))
	
	velocity += input_vector.rotated(rotation) * lerp(0.5, acceleration, clampf(velocity.length() * acceleration, 0, 1.0))
	
	if Input.is_action_pressed("rotate_right"):
		rotate(deg_to_rad(rotation_speed * delta))
	
	if Input.is_action_pressed("rotate_left"):
		rotate(deg_to_rad(-rotation_speed * delta))
	
	if input_vector.y == 0:
		var deceleration_factor = lerp(0.5, deceleration, clampf(velocity.length()  * max_speed, 0, 1.0))
		
		velocity = velocity.move_toward(Vector2.ZERO, deceleration_factor)
	
	# Update the velocity
	velocity = velocity.limit_length(max_speed)
	
	# Move the player
	move_and_slide()
	
	# Reset the player position to the opposite
	# side when they travel off the screen
	var screen_size = get_viewport_rect().size
	
	# Reset Y
	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0
	
	# Reset X
	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0


func shoot_laser():
	var l = laser_scene.instantiate()
	
	l.global_position = cannon.global_position
	l.rotation = rotation
	
	emit_signal("laser_shot", l)
	

func die():
	if alive == true:
		alive = false
		sprite.visible = false
		emit_signal("died")
		
		process_mode = Node.PROCESS_MODE_DISABLED


func respawn(pos):
	if alive == false:
		global_position = pos
		velocity = Vector2.ZERO
		sprite.visible = true
		alive = true
		
		process_mode = Node.PROCESS_MODE_INHERIT
