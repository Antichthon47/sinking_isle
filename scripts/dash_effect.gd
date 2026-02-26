extends AnimatedSprite2D

var spawn_pos: Vector2
var scale_x: float

func _ready() -> void:
	global_position = spawn_pos
	scale.x = scale_x
	
	$Particles.gravity *= scale.x
	$Particles.direction *= scale.x
	
	play("default")
	$Particles.emitting = true

func _on_particles_finished() -> void:
	queue_free()
