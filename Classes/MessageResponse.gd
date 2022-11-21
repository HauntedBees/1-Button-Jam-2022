class_name MessageResponse
extends Node

enum TYPE { DONE, SWITCH_SCENE }

var type: int
var val: String

func _init(t: int, v := "") -> void:
	type = t
	val = v
