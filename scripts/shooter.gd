extends CharacterBody2D

@export var fire_rate: float = 2.0
@export var projectile_scene: PackedScene
@export var rotation_speed: float = 2.0  # radians per second
@export var detection_radius: float = 300.0  # only track player within this range

@onready var shoot_timer = $Timer
@onready var muzzle = $Marker2D  # should be offset from center so it rotates with the enemy

var player: Node2D = null

func _ready():
	shoot_timer.wait_time = fire_rate
	shoot_timer.timeout.connect(_shoot)
	shoot_timer.start()
	# Assumes player is in group "player"
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if player == null:
		return

	var dist = global_position.distance_to(player.global_position)
	if dist > detection_radius:
		return  # player is too far, don't track

	# Rotate toward the player smoothly
	var target_angle = global_position.direction_to(player.global_position).angle()
	rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)

func _shoot():
	if player == null or projectile_scene == null:
		return

	var dist = global_position.distance_to(player.global_position)
	if dist > detection_radius:
		return  # don't shoot if player is out of range

	var p = projectile_scene.instantiate()
	get_parent().add_child(p)
	p.global_position = muzzle.global_position
	# Shoot in the direction the enemy is currently facing
	p.direction = Vector2.RIGHT.rotated(rotation)
