class_name Bunker
extends Spatial

signal troop_died()
var _troop_dead := false

onready var troop: Troop = $"%Troop"
onready var starting_points := [
	$StartingPoints/Spot1,
	$StartingPoints/Spot2
]

func get_troop_info() -> Dictionary:
	return {
		"pos": troop.global_transform.origin,
		"dir": troop.get_direction()
	}

func set_troop_pos(idx: int) -> void:
	var starting_point: Spatial = starting_points[idx]
	troop.global_transform.origin = starting_point.global_transform.origin
	troop.set_initial_rotation(starting_point.rotation_degrees.y)

func get_letter(letter: String) -> void:
	if _troop_dead:
		return
	match letter:
		"G":
			troop.speed_up()
		"S":
			troop.slow_down()
		_:
			troop.next_instruction = letter

func _on_Troop_died() -> void:
	_troop_dead = true
	emit_signal("troop_died")
