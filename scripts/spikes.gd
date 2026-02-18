extends Area2D

@export var damage: int = 20

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(damage)
