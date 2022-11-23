class_name Bunker
extends Spatial

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
	match letter:
		"U":
			troop.reverse()
		"G":
			if troop.move_speed == 0:
				troop.move_speed = 3
			else:
				troop.move_speed = 6
		"S":
			if troop.move_speed == 6:
				troop.move_speed = 3
			else:
				troop.move_speed = 0
		_:
			troop.next_instruction = letter
