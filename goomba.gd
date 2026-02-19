extends CharacterBody2D

@export var speed: float = 60.0
@export var damage: int = 10

var direction: int = 1

func _ready():
	$Area2D.body_entered.connect(_on_area_2d_body_entered)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += 900 * delta
	velocity.x = speed * direction
	move_and_slide()
	if is_on_wall():
		direction *= -1

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(damage)
