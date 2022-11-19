class_name Bunker
extends Spatial

onready var troop: Troop = $"%Troop"

func _on_letter_sent(letter: String) -> void:
	match letter:
		"U":
			troop.reverse()
		"Q", "G":
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
