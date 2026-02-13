extends CharacterBody2D

const speed = 150.0
const dash_speed = 400.0
const wall_jump_distance = 50
const jump_height = -400.0
const gravity = 20.0

var var_gravity = gravity

var moving: bool
var can_dash: bool = true

var can_jump: bool = true
var jump_applied: bool = false
var jump_buffer: bool = false
var jump_locked: bool = false

var var_jump_applied: bool = false
var jump_released: bool = true

var can_wall_jump: bool = false
var wall_jump_applied: bool = false

var last_direction: float = 1.0

var jump_threshold: float = -100

func _ready() -> void:
	$Sprites.play("idle")

func _physics_process(_delta: float) -> void:
	if is_on_wall_only():
		can_wall_jump = true
		if velocity.y <= 150:
			velocity.y += var_gravity
		else:
			velocity.y = 150
	elif is_on_floor():
		can_jump = true
		$CoyoteTime.stop()
		if jump_buffer:
			jump_action()
	else:	
		if can_jump:
			if $CoyoteTime.is_stopped():
				$CoyoteTime.start()
		elif can_wall_jump:
			if $WallCoyoteTime.is_stopped():
				$WallCoyoteTime.start()
		if velocity.y <= 300:
			velocity.y += var_gravity

	if Input.is_action_just_pressed("SPACE"):
		if !jump_locked:
			if can_wall_jump && is_on_wall_only():
				var_jump_applied = false
				jump_released = false
				wall_jump()
			elif can_jump || (can_wall_jump && !is_on_wall_only()):
				var_jump_applied = false
				jump_released = false
				jump_action()
			else:
				$JumpBuffer.start()
				jump_buffer = true
	elif !jump_released && !Input.is_action_pressed("SPACE"):
		jump_released = true
	elif jump_released && !var_jump_applied && velocity.y < 0:
		velocity.y *= 0.3
		var_jump_applied = true
	
	if Input.is_action_just_pressed("SHIFT") && can_dash:
		can_dash = false
		jump_locked = true
		$DashCooldown.start()
		$DashTimer.start()
		var_gravity = 0
		velocity.y = 0 
		velocity.x = last_direction * dash_speed
	
	var direction := Input.get_axis("KEY_A", "KEY_D")
	
	if direction:
		moving = true
		last_direction = direction
		if abs(velocity.x) > speed:
			velocity.x = move_toward(velocity.x, speed, 10)
		elif !is_on_floor():
			if abs(velocity.x) <= speed:
				velocity.x += direction * 15
		else:
			velocity.x = direction * speed
	else:
		moving = false
		if !is_on_floor() || !$DashTimer .is_stopped():
			if abs(velocity.x) > 0:
				velocity.x = move_toward(velocity.x, 0, 15)
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
	
	$Sprites.flip_h = !bool((last_direction + 1) / 2)

	move_and_slide()

func wall_jump() -> void:
	wall_jump_applied = true
	velocity.x = speed * -last_direction
	velocity.y = jump_height

func jump_action() -> void:
	velocity.y = jump_height

func _on_coyote_time_timeout() -> void:
	can_jump = false

func _on_jump_buffer_timeout() -> void:
	jump_buffer = false

func _on_dash_timer_timeout() -> void:
	var_gravity = gravity
	jump_locked = false

func _on_dash_cooldown_timeout() -> void:
	can_dash = true

func _on_wall_coyote_time_timeout() -> void:
	can_wall_jump = false
