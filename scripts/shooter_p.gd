extends CharacterBody2D

@export var speed: float = 200.0
@export var damage: int = 10
var direction: Vector2  # set this after instantiating
var direction_x: float

func _ready() -> void:
	direction_x = round(direction.x)
	velocity = direction * speed

func _physics_process(_delta: float) -> void:
	move_and_slide()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("SolidTile"):
		queue_free()
	else:
		queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		queue_free()
