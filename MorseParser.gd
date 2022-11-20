class_name MorseParser
extends Node

signal new_part(s)
signal send_letter(s)
signal press()
signal release()

signal current_val(s)
signal current_val_string(s)

const MORSE := {
	".-": "A",
	"-...": "B",
	"-.-.": "C",
	"-..": "D",
	".": "E",
	"..-.": "F",
	"--.": "G",
	"....": "H",
	"..": "I",
	".---": "J",
	"-.-": "K",
	".-..": "L",
	"--": "M",
	"-.": "N",
	"---": "O",
	".--.": "P",
	"--.-": "Q",
	".-.": "R",
	"...": "S",
	"-": "T",
	"..-": "U",
	"...-": "V",
	".--": "W",
	"-..-": "X",
	"-.--": "Y",
	"--..": "Z",
	".----": "1",
	"..---": "2",
	"...--": "3",
	"....-": "4",
	".....": "5",
	"-....": "6",
	"--...": "7",
	"---..": "8",
	"----.": "9",
	"-----": "0",
}

export(float) var pause_threshold := 0.75 # how long until a silence is interpreted as a space
export(float) var dash_threshold := 0.25 # how long until a press changes from a dot to a dash

var _current_stack := "" # current ordering of dots and dashes
var _current_input := "" # the key or button currently being pressed, if any
var _event_time := 0.0 # how long the current input has been held down, or how long nothing has been held for

func _input(event: InputEvent) -> void:
	# mouse, keyboard, and gamepad only
	if !(event is InputEventMouseButton || event is InputEventKey || event is InputEventJoypadButton):
		return
	if event.is_pressed():
		# another input is aleady pressed, ignore this
		if _current_input != "":
			return
		_event_time = 0.0
		_current_input = _get_input_key(event)
		emit_signal("press")
		var next := _current_stack + "."
		emit_signal("current_val", next)
		emit_signal("current_val_string", _current_selection(next))
	elif _current_input == "":
		return
	else:
		var key := _get_input_key(event)
		# releasing some secondary input, ignore this
		if _current_input != key:
			return
		if _event_time >= dash_threshold:
			_current_stack += "-"
		else:
			_current_stack += "."
		_current_input = ""
		_event_time = 0.0
		emit_signal("new_part", _current_selection(_current_stack))
		emit_signal("release")

func _process(delta: float) -> void:
	_event_time += delta
	if _current_input == "" && _event_time > pause_threshold && _current_stack != "":
		emit_signal("send_letter", _current_selection(_current_stack))
		_current_stack = ""
	elif _current_input != "":
		var next := _current_stack
		if _event_time > dash_threshold:
			next += "-"
		else:
			next += "."
		emit_signal("current_val", next)
		emit_signal("current_val_string", _current_selection(next))

func _current_selection(stack: String) -> String:
	if MORSE.has(stack):
		return MORSE[stack]
	else:
		return "?"

func _get_input_key(event: InputEvent) -> String:
	if event is InputEventMouseButton:
		return "MOUSE_%s" % (event as InputEventMouseButton).button_index
	elif event is InputEventKey:
		return "KEY_%s" % (event as InputEventKey).scancode
	elif event is InputEventJoypadButton:
		return "GP_%s" % (event as InputEventJoypadButton).button_index
	return ""
