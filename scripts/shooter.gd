extends CharacterBody2D

@export var fire_rate: float = 2.0
@export var projectile_scene: PackedScene
@export var rotation_speed: float = 5.0  # radians per second
#@export var detection_radius: float = 300.0  # only track player within this range

@onready var shoot_timer = $ShootCooldown
@onready var buffer_timer = $Buffer
@onready var muzzle = $Sprite/SpawnMarker  # should be offset from center so it rotates with the enemy

@export var quadrant: int # For starting rotation

const const_rotation = PI - atan2(2, 1) # Measured exactly as the rotation of the cannon sprite
var default_rotation: float

var target: CharacterBody2D
var tracking: bool = false
var can_shoot: bool = false

var player: Node2D = null

var direction_x = 0

var projectile: PackedScene = preload("res://scenes/shooter_p.tscn")

func _ready():
	'''shoot_timer.wait_time = fire_rate
	shoot_timer.timeout.connect(_shoot)
	shoot_timer.start()
	# Assumes player is in group "player"
	player = get_tree().get_first_node_in_group("player")'''
	default_rotation = const_rotation - (PI/4 + ((PI/2) * (quadrant - 1)))
	$Sprite.global_rotation = default_rotation

func _physics_process(delta):
	'''if player == null:
		return

	var dist = global_position.distance_to(player.global_position)
	if dist > detection_radius:
		return  # player is too far, don't track

	# Rotate toward the player smoothly
	var target_angle = global_position.direction_to(player.global_position).angle()
	rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)'''
	if target != null && tracking:
		$RayCastTracker.target_position = target.global_position - global_position
		if !$RayCastTracker.is_colliding():
			buffer_timer.stop()
			can_shoot = true
			var target_angle = const_rotation + (atan2($RayCastTracker.target_position.y, $RayCastTracker.target_position.x))
			$Sprite.global_rotation = lerp_angle($Sprite.global_rotation, target_angle, rotation_speed * delta)
			
			if shoot_timer.is_stopped():
				shoot_timer.start()
		else:
			$Sprite.global_rotation = lerp_angle($Sprite.global_rotation, default_rotation, rotation_speed * delta)
			if buffer_timer.is_stopped():
				buffer_timer.start()
			can_shoot = false

func shoot():
	'''if player == null or projectile_scene == null:
		return

	var dist = global_position.distance_to(player.global_position)
	if dist > detection_radius:
		return  # don't shoot if player is out of range

	var p = projectile_scene.instantiate()
	get_parent().add_child(p)
	p.global_position = muzzle.global_position
	# Shoot in the direction the enemy is currently facing
	p.direction = Vector2.RIGHT.rotated(rotation)'''
	if can_shoot && target != null:
		shoot_timer.start()
		var distance = target.global_position - global_position
		
		var instance = projectile.instantiate()
		instance.global_position = muzzle.global_position
		instance.direction = distance.normalized()
		instance.z_index = z_index - 1
		get_parent().add_child(instance)

func _on_detection_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		tracking = true
		if area.get_owner() is CharacterBody2D:
			target = area.get_owner()
		else:
			print("ERROR")

func _on_detection_area_exited(area: Area2D) -> void:
	if area.is_in_group("Player"):
		tracking = false
		target = null

func _on_shoot_cooldown_timeout() -> void:
	shoot()
	$ShootCooldown.start()

func _on_buffer_timeout() -> void:
	shoot_timer.stop()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerProjectile"):
		queue_free()
