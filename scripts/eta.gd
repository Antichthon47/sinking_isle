extends CharacterBody2D

@export var lock_camera_y: bool = false

@onready var camera = $PlayerCamera

const max_hp = 10
const max_air = 100

const speed = 150.0
const dash_speed = 400.0
const wall_jump_distance = 50
const jump_height = -400.0
const gravity = 20.0

var player_hp = max_hp
var player_air = max_air

var var_gravity = gravity

var moving: bool
var can_dash: bool = true
var dashing: bool = false

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

var is_attacking: bool = false
var can_attack: bool = true
var hit: bool = false
var arrow = preload("res://scenes/Arrow.tscn")
var dash = preload("res://scenes/DashEffect.tscn")

func _ready() -> void:
	if lock_camera_y:
		camera.limit_left = 0
		camera.limit_right = 0
	
	$Sprites.play("idle")

func _physics_process(_delta: float) -> void:
	if is_on_wall_only():
		can_wall_jump = true
		if velocity.y <= 150:
			velocity.y += var_gravity
		else:
			velocity.y = 150
	elif is_on_floor():
		hit = false
		can_jump = true
		$CoyoteTime.stop()
		if jump_buffer && Input.is_action_pressed("SPACE"):
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
				wall_jump()
			elif can_jump || (can_wall_jump && !is_on_wall_only()):
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
		if !is_on_wall_only():
			var dash_effect = dash.instantiate()
			dash_effect.spawn_pos = global_position
			dash_effect.scale_x = last_direction
			get_parent().add_child(dash_effect)
			
			$Sprites.play("dash")
			dashing = true
			can_dash = false
			jump_locked = true
			$DashCooldown.start()
			$DashTimer.start()
			var_gravity = 0
			velocity.y = 0 
			velocity.x = last_direction * dash_speed
	
	if Input.is_action_just_pressed("ENTER") && can_attack:
		is_attacking = true
		if is_on_floor():
			$Sprites.play("ground_shooting")
		else:
			$Sprites.play("air_shooting")
		var instance = arrow.instantiate()
		instance.spawn_pos = global_position
		instance.direction = last_direction
		get_parent().add_child(instance)
		
		can_attack = false
		$AttackTimer.start()
		$AttackCooldown.start()
	
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
		if !is_on_floor() || !$DashTimer.is_stopped() || hit:
			if abs(velocity.x) > 0:
				velocity.x = move_toward(velocity.x, 0, 15)
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
	
	$Sprites.flip_h = !bool((last_direction + 1) / 2)

	move_and_slide()

func take_damage(dmg: int, immunity: bool) -> void:
	if immunity:
		$ImmunityTimer.start()
	player_hp -= dmg

func hit_player(knockback_direction: int) -> void:
	print((speed) * last_direction * knockback_direction)
	$Sprites.play("hit")
	velocity.y = (jump_height/2)
	velocity.x = (speed) * last_direction * knockback_direction
	hit = true
	move_and_slide()

func drain_air(air_loss: int) -> void:
	
	player_air -= air_loss

func wall_jump() -> void:
	wall_jump_applied = true
	velocity.x = speed * -last_direction
	velocity.y = jump_height

func jump_action() -> void:
	var_jump_applied = false
	jump_released = false
	velocity.y = jump_height

func special_animation() -> bool:
	return is_attacking || dashing || $Sprites.animation == "hit"

func _on_coyote_time_timeout() -> void:
	can_jump = false

func _on_jump_buffer_timeout() -> void:
	jump_buffer = false

func _on_dash_timer_timeout() -> void:
	dashing = false
	var_gravity = gravity
	jump_locked = false

func _on_dash_cooldown_timeout() -> void:
	can_dash = true

func _on_wall_coyote_time_timeout() -> void:
	can_wall_jump = false

func _on_attack_cooldown_timeout() -> void:
	can_attack = true

func _on_attack_timer_timeout() -> void:
	is_attacking = false


func _on_hitbox_area_area_entered(area: Area2D) -> void:
	if (area.is_in_group("Enemy") || area.is_in_group("Projectile")) && $ImmunityTimer.is_stopped():
		take_damage(1, true)
		if area.get_owner().direction_x == last_direction && last_direction * (global_position.x - area.get_owner().global_position.x) > 0:
			hit_player(1)
		else:
			hit_player(-1)

func _on_hitbox_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("hazard") && $ImmunityTimer.is_stopped():
		take_damage(1, true)
		hit_player(-last_direction)
	elif $DrainTimer.is_stopped():
		if body.is_in_group("water"):
			drain_air(1)
		elif body.is_in_group("acid"):
			drain_air(5)
