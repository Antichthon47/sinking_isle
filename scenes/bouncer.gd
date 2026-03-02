extends CharacterBody2D

@export var speed: float = 60.0
@export var jump_force: float = -300.0
@export var jump_interval: float = 2.0

const gravity: float = 30.0
const knockback_height: float = -150.0

var direction_x: int = 1
var was_on_floor: bool = false

func _ready():
	$Sprites.play("idle")
	$JumpTimer.start()

func _physics_process(_delta):
	if not is_on_floor():
		$Sprites.play("jump")
		velocity.y += gravity
	else:
		if not was_on_floor:
			$Sprites.play("idle")  # just landed
			velocity.x = 0
	
	was_on_floor = is_on_floor()
	move_and_slide()

	if is_on_wall():
		direction_x *= -1

	if $Buffer.is_stopped():
		for cast in $RayCasts.get_children():
			if !cast.is_colliding():
				$Buffer.start()
				direction_x *= -1

func kill() -> void:
	$DeathTimer.start()
	$HitboxArea.queue_free()
	$Sprites.play("death")

func _on_jump_timer_timeout():
	if is_on_floor():
		velocity.y = jump_force
		velocity.x = speed * direction_x  # only apply horizontal speed on jump
	$JumpTimer.start()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerProjectile"):
		speed = 0
		velocity.y = knockback_height
		kill()

func _on_death_timer_timeout() -> void:
	queue_free()
