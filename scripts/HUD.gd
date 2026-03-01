extends CanvasLayer


## - margin_px = distance from screen edges
## - BAR_W / BAR_H  = bar size in pixels

@export var margin_px: int = 8

const BAR_W: float = 70.0
const BAR_H: float = 8.0

@onready var air_stack: Control = $Root/AirStack
@onready var air_bar: ProgressBar = $Root/AirStack/AirBar
@onready var air_text: Label = $Root/AirStack/AirBarText

var player: Node = null

var _bg_style: StyleBoxFlat = null
var _fill_style: StyleBoxFlat = null

func _ready() -> void:
	## defaults
	air_stack.custom_minimum_size = Vector2(BAR_W, BAR_H)
	air_bar.min_value = 0.0
	air_bar.show_percentage = false

	_apply_bar_styles()
	_reposition()

func _process(_delta: float) -> void:
	
	_reposition()

	# finds the player
	if player == null:
		player = _find_player()

	# update bar from player_air 
	if player != null and ("player_air" in player):
		var max_air: float = 100.0
		if "max_air" in player:
			max_air = float(player.max_air)

		var cur_air: float = clamp(float(player.player_air), 0.0, max_air)
		air_bar.max_value = max_air
		air_bar.value = cur_air

		# hides air bar 
		air_stack.visible = cur_air < (max_air - 0.01)


## ignore this, this is for if player was named something else 
## or not in the right group
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

## ignore this, this is for if player was named something else 
## or not in the right group
func _find_node_with_air(n: Node) -> Node:
	if ("player_air" in n):
		return n
	for c in n.get_children():
		var found: Node = _find_node_with_air(c)
		if found != null:
			return found
	return null

func _reposition() -> void:
	var stack_size: Vector2 = air_stack.size
	if stack_size.x <= 1.0 or stack_size.y <= 1.0:
		stack_size = air_stack.get_combined_minimum_size()

	air_stack.position = Vector2(float(margin_px), float(margin_px))

func _apply_bar_styles() -> void:
	# background rectangle for air bar 
	_bg_style = StyleBoxFlat.new()
	_bg_style.bg_color = Color(0.07, 0.13, 0.16, 0.90)
	_bg_style.corner_radius_top_left = 0
	_bg_style.corner_radius_top_right = 0
	_bg_style.corner_radius_bottom_left = 0
	_bg_style.corner_radius_bottom_right = 0
	air_bar.add_theme_stylebox_override("background", _bg_style)

	# fill color teal rectangle
	_fill_style = StyleBoxFlat.new()
	_fill_style.bg_color = Color(0.40, 1.00, 0.95, 1.0)
	_fill_style.corner_radius_top_left = 0
	_fill_style.corner_radius_bottom_left = 0
	_fill_style.corner_radius_top_right = 0
	_fill_style.corner_radius_bottom_right = 0
	air_bar.add_theme_stylebox_override("fill", _fill_style)

	# text and centering
	air_text.text = "AIR"
	air_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	air_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
