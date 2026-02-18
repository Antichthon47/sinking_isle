extends CharacterBody2D

const speed = 480.0

var spawn_pos: Vector2
var direction: float

func _ready() -> void:
	global_position = spawn_pos
	velocity.x = direction * speed
	#$ArrowSprite.flip_h = !bool((direction + 1) / 2)
	scale.x = direction

func _physics_process(_delta: float) -> void:
	move_and_slide()

func _on_hitbox_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("SolidTile"):
		crash()

func _on_hitbox_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		crash()

func crash() -> void:
	$HitboxArea.set_deferred("monitorable", false)
	$ArrowSprite.modulate = Color(1, 1, 1, 0)
	velocity.x = 0
	$WoodParticles.emitting = true
	$MetalParticles.emitting = true
	$KillTimer.start()

func _on_kill_timer_timeout() -> void:
	queue_free()
