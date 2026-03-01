extends Node2D

@export var width: float = 2000.0
@export var segment_count: int = 2  # 2 point line

@export var fill_color: Color = Color(0.0, 0.60, 0.60, 0.50)  # teal + transparent
@export var surface_color: Color = Color(0.70, 1.00, 1.00, 0.90)
@export var surface_width: float = 3.0

@export var fill_bottom_y: float = 2000.0
@export var fill_padding_below_view: float = 600.0

@onready var line: Line2D = $Line2D
@onready var fill: Polygon2D = $Polygon2D

func _ready() -> void:
	segment_count = max(segment_count, 2)

	line.default_color = surface_color
	line.width = surface_width
	fill.color = fill_color

	_update_geometry()

func _process(_delta: float) -> void:
	
	_update_geometry()

func _update_geometry() -> void:

	line.clear_points()

	 ## this loop draws the line for the water 
	for i in range(segment_count):
		var t: float = float(i) / float(segment_count - 1)
		var x: float = lerp(-width * 0.5, width * 0.5, t)
		line.add_point(Vector2(x, 0.0))


	var poly := PackedVector2Array()
	poly.resize(segment_count + 2)

	for i in range(segment_count):
		poly[i] = line.get_point_position(i)

	 ## extends the water fill so that it doesn't fly offscreen as it goes up for long enough
	var bottom_y: float = fill_bottom_y
	var cam := get_viewport().get_camera_2d()
	if cam != null:
		var screen_size := get_viewport_rect().size
		var world_bottom := cam.global_position.y + (screen_size.y * 0.5) + fill_padding_below_view
		bottom_y = to_local(Vector2(cam.global_position.x, world_bottom)).y

	poly[segment_count] = Vector2(line.get_point_position(segment_count - 1).x, bottom_y)
	poly[segment_count + 1] = Vector2(line.get_point_position(0).x, bottom_y)

	fill.polygon = poly
