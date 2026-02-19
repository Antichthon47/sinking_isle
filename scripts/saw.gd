extends TileMapLayer
@export var move_distance: float = 50.0
@export var speed: float = 2.0
@export var damage: int = 10

var start_pos: Vector2

func _ready():
	start_pos = position

func _physics_process(delta):
	position.x = start_pos.x + sin(Time.get_ticks_msec() * 0.001 * speed) * move_distance


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(damage)
