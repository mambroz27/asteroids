extends CharacterBody2D

@export var acceleration := 10.0
@export var deceleration := 4.0
@export var max_speed := 500.0
@export var rotation_speed := 200.0

func _physics_process(delta):
	var input_vector := Vector2(0, Input.get_axis("accelerate", "decelerate"))
	
	velocity += input_vector.rotated(rotation) * lerp(0.5, acceleration, clampf(velocity.length() * acceleration, 0, 1.0))
	
	if (Input.is_action_pressed("rotate_right")):
		rotate(deg_to_rad(rotation_speed * delta))
	
	if (Input.is_action_pressed("rotate_left")):
		rotate(deg_to_rad(-rotation_speed * delta))
	
	if input_vector.y == 0:
		var deceleration_factor = lerp(0.5, deceleration, clampf(velocity.length()  * max_speed, 0, 1.0))
		
		velocity = velocity.move_toward(Vector2.ZERO, deceleration_factor)
	
	# Update the velocity
	velocity = velocity.limit_length(max_speed)
	
	print("Velocity: ", velocity)
	
	# Move the player
	move_and_slide()
	
	# Reset the player position to the opposite
	# side when they travel off the screen
	var screen_size = get_viewport_rect().size
	
	if (global_position.y < 0):
		global_position.y = screen_size.y
	elif (global_position.y > screen_size.y):
		global_position.y = 0
	
	if (global_position.x < 0):
		global_position.x = screen_size.x
	elif (global_position.x > screen_size.x):
		global_position.x = 0
