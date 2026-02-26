extends CharacterBody2D

@export var speed: float = 60.0
@export var damage: int = 10
@export var moving: bool = true

const knockback_height: float = -150
const gravity: float = 30.0

var direction_x: int = 1

func _ready():
	if moving:
		$Sprites.play("walk")
	else:
		$Sprites.play("idle")

func _physics_process(_delta):
	if moving:
		if not is_on_floor():
			velocity.y += gravity
		velocity.x = speed * direction_x
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

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerProjectile"):
		speed = 0
		velocity.y = knockback_height
		kill()

func _on_death_timer_timeout() -> void:
	queue_free()
