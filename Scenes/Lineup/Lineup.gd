extends Node2D

onready var char_sprite: AnimatedSprite = $"%Character"
var character := "Siarland"

func _ready() -> void:
	anim_walk()

func anim_react() -> void:
	char_sprite.animation = "React%s" % character

func anim_walk() -> void:
	char_sprite.animation = "Walk%s" % character

func anim_rotate() -> void:
	char_sprite.flip_h = true
