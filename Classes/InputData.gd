class_name InputData
extends Node

enum SPECIAL { NONE, DIFFICULTY_BRANCH, SWITCH_MISSION, START_TROOPS }

var input: String
var min_score: float
var success_next: String
var fail_next: String
var special: int
var special_info: Dictionary
func _init(m: String, s: float, next: String, fnext: String = "", extra: int = SPECIAL.NONE, extra_info: Dictionary = {}) -> void:
	input = m
	min_score = s
	success_next = next
	fail_next = fnext
	special = extra
	special_info = extra_info
