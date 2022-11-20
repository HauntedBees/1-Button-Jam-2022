class_name Buble
extends MarginContainer

onready var text: Label = $MarginContainer/Text
onready var timer: Timer = $Timer

var _current_text := ""

func _on_MorseParser_current_val_string(s: String) -> void:
	visible = true
	#text.text = _current_text + s
	text.text = s

func _on_MorseParser_send_letter(s: String) -> void:
	visible = false
	#if s != "?":
	#	_current_text += s
	#text.text = _current_text
