extends CharacterBody2D

@export var fire_rate: float = 2.0
@export var projectile_scene: PackedScene

@onready var shoot_timer = $Timer
@onready var muzzle = $Marker2D

func _ready():
	shoot_timer.wait_time = fire_rate
	shoot_timer.timeout.connect(_shoot)
	shoot_timer.start()

func _shoot():
	if projectile_scene:
		var p = projectile_scene.instantiate()
		get_parent().add_child(p)
		p.global_position = muzzle.global_position
