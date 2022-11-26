class_name MorseParser
extends Node

signal new_part(s)
signal send_letter(s)
signal press()
signal press_key(s)
signal hold(delta)
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

var _current_stack := "" # current ordering of dots and dashes
var _current_input := "" # the key or button currently being pressed, if any
var _event_time := 0.0 # how long the current input has been held down, or how long nothing has been held for

func _get_input_string(event: InputEvent) -> String:
	if event is InputEventKey:
		return "Key_%s" % (event as InputEventKey).scancode
	elif event is InputEventJoypadButton:
		return "Button_%s" % (event as InputEventJoypadButton).button_index
	elif event is InputEventMouseButton:
		return "Mouse_%s" % (event as InputEventMouseButton).button_index
	return ""

func _input(event: InputEvent) -> void:
	# mouse, keyboard, and gamepad only
	if !(event is InputEventMouseButton || event is InputEventKey || event is InputEventJoypadButton):
		return
	if GameData.PRESS_INPUT != "" && _get_input_string(event) != GameData.PRESS_INPUT:
		return
	if event.is_pressed():
		if GameData.debug_mode && event is InputEventKey:
			var key := char((event as InputEventKey).scancode)
			emit_signal("send_letter", key)
		else:
			# another input is aleady pressed, ignore this
			if _current_input != "":
				return
			_event_time = 0.0
			_current_input = _get_input_key(event)
			emit_signal("press")
			emit_signal("press_key", _get_input_string(event))
			var next := _current_stack + "."
			emit_signal("current_val", next)
			emit_signal("current_val_string", _current_selection(next))
			get_tree().call_group("sound", "start_morse")
	elif _current_input == "":
		return
	else:
		var key := _get_input_key(event)
		# releasing some secondary input, ignore this
		if _current_input != key:
			return
		if _event_time >= GameData.DASH_LENGTH:
			_current_stack += "-"
		else:
			_current_stack += "."
		_current_input = ""
		_event_time = 0.0
		emit_signal("new_part", _current_selection(_current_stack))
		emit_signal("release")
		get_tree().call_group("sound", "stop_morse")

func _process(delta: float) -> void:
	_event_time += delta
	if _current_input == "" && _event_time > GameData.WAIT_LENGTH && _current_stack != "":
		emit_signal("send_letter", _current_selection(_current_stack))
		_current_stack = ""
	elif _current_input != "":
		var next := _current_stack
		if _event_time > GameData.DASH_LENGTH:
			next += "-"
		else:
			next += "."
		emit_signal("current_val", next)
		emit_signal("hold", delta)
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
