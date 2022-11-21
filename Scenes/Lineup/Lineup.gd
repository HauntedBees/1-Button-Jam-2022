class_name Lineup
extends Node2D

onready var _char_sprite: AnimatedSprite = $"%Character"
var character := "Siarland"

func anim_react() -> void:
	_char_sprite.animation = "React%s" % character

func anim_walk() -> void:
	_char_sprite.animation = "Walk%s" % character

func anim_rotate() -> void:
	_char_sprite.flip_h = true
