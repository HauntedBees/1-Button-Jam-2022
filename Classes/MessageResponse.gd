class_name MessageResponse
extends Node

enum TYPE { NOT_LONG_ENOUGH, DONE }

var type: int
var val: String

func _init(t: int, v := "") -> void:
	type = t
	val = v
