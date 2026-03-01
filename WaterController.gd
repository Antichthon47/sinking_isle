extends Node2D

@export var rise_speed: float = 30.0
@export var tick_seconds: float = 0.15
@export var flat_air_loss: float = 0.4
@export var percent_current_air: float = 0.04
@export var recovery_multiplier: float = 0.5
@export var submerge_offset_y: float = 0.0

@onready var tick_timer: Timer = $TickTimer

var player: Node = null

func _ready() -> void:
	set_process_priority(-100)
	tick_timer.wait_time = tick_seconds
	tick_timer.one_shot = false
	tick_timer.timeout.connect(_on_tick)
	tick_timer.start()

func _physics_process(delta: float) -> void:
	global_position.y -= rise_speed * delta

	_update_player_meta()
	
	## 
func _update_player_meta() -> void:
	if player == null:
		player = _find_player()
	if player == null:
		return
	if not ("player_air" in player):
		return
	var player_y: float = float(player.global_position.y) + submerge_offset_y
	var submerged: bool = player_y >= float(global_position.y)
	player.set_meta("in_water", submerged)
	player.set_meta("water_surface_y", float(global_position.y))

func _on_tick() -> void:
	if player == null:
		player = _find_player()
	if player == null:
		return
	if not ("player_air" in player):
		return

	var max_air: float = 100.0
	if "max_air" in player:
		max_air = float(player.max_air)

## I had this idea to use an offset to make it so that the player didn't lose air if they
## had their head above water but it was too much trouble 
	var player_y: float = float(player.global_position.y) + submerge_offset_y
	var submerged: bool = player_y >= float(global_position.y)

	var current_air: float = float(player.player_air)

	 ## stops running at 0 air 
	 ## all the logic for losing air underwater and gaining above
	if submerged:
		if current_air <= 0.0:
			return

		var loss: float = flat_air_loss + (current_air * percent_current_air)
		var loss_amt: int = maxi(ceili(loss), 1)
		_apply_air_change(-loss_amt, max_air)
	else:
		var gain: float = (flat_air_loss + (current_air * percent_current_air)) * recovery_multiplier
		var gain_amt: int = maxi(ceili(gain), 1)
		_apply_air_change(gain_amt, max_air)

func _apply_air_change(delta_air: int, max_air: float) -> void:
	if delta_air < 0 and player.has_method("drain_air"):
		player.drain_air(-delta_air)
		return
	if delta_air > 0 and player.has_method("restore_air"):
		player.restore_air(delta_air)
		return

	 ## clamp keeps output within possible range of air player can have 
	var new_air: float = clamp(float(player.player_air) + float(delta_air), 0.0, max_air)
	player.player_air = new_air
	player.set_meta("air_depleted", new_air <= 0.0)
	
	## If you want to do something when the player is at 0 air you can do it like this
	## if player.get_meta("air_depleted", false):

	 ## ignore this 
func _find_player() -> Node:
	var p: Node = get_tree().get_first_node_in_group("player")
	if p != null:
		return p
	p = get_tree().get_first_node_in_group("Player")
	if p != null:
		return p

	var scene: Node = get_tree().current_scene
	if scene == null:
		return null
	return _find_node_with_air(scene)

func _find_node_with_air(n: Node) -> Node:
	if "player_air" in n:
		return n
	for c in n.get_children():
		var found: Node = _find_node_with_air(c)
		if found != null:
			return found
	return null
