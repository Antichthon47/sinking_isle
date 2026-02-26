extends Node2D

@export var sprites: AnimatedSprite2D

@onready var player: CharacterBody2D = get_owner()

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if !player.special_animation():
		if player.is_on_floor():
			if abs(player.velocity.x) > 0 && sprites.animation != "walking":
				sprites.play("walking")
			elif player.velocity.x == 0 && sprites.animation != "idle":
				sprites.play("idle")
		elif player.is_on_wall_only():
			if sprites.animation != "cling":
				sprites.play("cling")
		else:
			if !player.is_attacking && sprites.animation != "jumping":
				sprites.play("jumping")

func _on_sprites_animation_finished() -> void:
	if sprites.animation == "hit":
		sprites.play("idle")
