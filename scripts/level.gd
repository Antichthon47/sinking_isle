extends Node2D

@onready var maps: Node2D = $TileMaps
@onready var enemies_mov: TileMapLayer = $MovingEnemies
@onready var enemies_still: TileMapLayer = $StillEnemies
@onready var saws_mov: TileMapLayer = $MovingSaws
@onready var saws_still: TileMapLayer = $StillSaws

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
