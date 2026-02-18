extends Area2D

@export var speed: float = 200.0
@export var damage: int = 10
var direction: Vector2 = Vector2.LEFT  # set this after instantiating

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(damage)
	queue_free()
