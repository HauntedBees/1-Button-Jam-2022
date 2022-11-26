extends GameBase

onready var texts := [$InfoText, $CreditsText, $SettingsText]
onready var settings_text: RichTextLabel = $SettingsText

var _current_input := ""
var state := 0
var settings_state := 0
var settings_bucket := []
var holding := false
var current_hold := 0.0
var has_broken_first_hold := false

func _ready() -> void:
	input_matters = true
	_switch_state(0)

func _switch_state(i: int) -> void:
	for t in texts:
		t.visible = false
	state = i
	texts[state].visible = true
	emit_signal("add_space")

func _on_letter_sent(s: String) -> void:
	_current_input += s
	if state == 1:
		_switch_state(0)
		return
	if state == 2 && settings_state == 4:
		match _current_input:
			"O":
				return
			"OK":
				_switch_state(0)
			_:
				_current_input = ""
				emit_signal("add_space")
	elif state == 0:
		match _current_input:
			"1", "2", "3", "4", "5":
				GameData.difficulty = int(_current_input)
				emit_signal("choice_made", _current_input)
			"C":
				_switch_state(1)
			"S", "O":
				_switch_state(2)
				_set_settings_state(0)
			"U", "UP", "UPG", "UPGA", "UPGAM", "UPGAME", "UPGAMER", "F", "D", "DE", "DEB", "DEBU":
				return
			"DEBUG":
				_current_input = ""
				GameData.debug_mode = !GameData.debug_mode
				emit_signal("add_space")
			"FF":
				_current_input = ""
				GameData.fast_forward = !GameData.fast_forward
				emit_signal("add_space")
			"UPGAMERS":
				pass
			_:
				_current_input = ""
				emit_signal("add_space")

func _set_settings_state(i: int) -> void:
	settings_state = i
	match settings_state:
		0:
			settings_bucket = []
			settings_text.bbcode_text = "[color=#AA0000]Tap[/color] any key or button 5 times as quickly as is comfortable for you. This will determine how long your short presses/dots are.\n\n"
		1:
			settings_bucket = []
			settings_text.bbcode_text = "Your short presses are around %.3f seconds long. Now [color=#AA0000]press and hold[/color] any key or button 5 times, ensuring that your presses are longer than that. This will determine how long your long presses/dashes are.\n\n" % GameData.DOT_LENGTH
		2:
			settings_bucket = []
			has_broken_first_hold = false
			settings_text.bbcode_text = "Your long presses are around %.3f seconds long. Now do 5 short or long presses - but keep track of [color=#AA0000]the gap in time between your presses[/color]. This will determine how long the game will wait before starting a new letter.\n\n" % GameData.DASH_LENGTH
		3:
			settings_bucket = []
			settings_text.bbcode_text = "Your letter gaps are around %.3f seconds long. As long as you start another press in less time than that, it'll count as part of the same letter. Finally, [color=#AA0000]press one key or button twice if you only want that key or button to be accepted as valid game input, otherwise press any key or button, then any other key or button[/color]." % GameData.WAIT_LENGTH
		4:
			settings_text.bbcode_text = "You're all set! Morse [color=#AA0000]OK[/color] to return to the main menu!"
			emit_signal("add_space")
		-1:
			settings_bucket = []
			settings_text.bbcode_text = "Your long presses were shorter than your short presses! Let's try again. Try [color=#AA0000]quickly tapping[/color] any key or button 5 times, as quickly as you can. This will determine how long your short presses/dots are.\n\n"

func _process(delta: float) -> void:
	if holding || (settings_state == 2 && has_broken_first_hold):
		current_hold += delta

func _on_press_key(s: String) -> void:
	if state != 2 || settings_state != 3:
		return
	settings_bucket.append(s)
	if settings_bucket.size() >= 2:
		if settings_bucket[0] == settings_bucket[1]:
			GameData.PRESS_INPUT = settings_bucket[0]
		else:
			GameData.PRESS_INPUT = ""
		_set_settings_state(4)

func _on_press() -> void:
	if state != 2 || holding:
		return
	if settings_state == 2:
		if current_hold > 0.0:
			settings_bucket.append(current_hold)
			settings_text.bbcode_text += "%.3fs\n" % current_hold
			if settings_bucket.size() >= 5:
				var avg := 0.0
				for s in settings_bucket:
					avg += s
				GameData.WAIT_LENGTH = avg / settings_bucket.size()
				_set_settings_state(3)
	holding = true
	current_hold = 0.0

func _on_release() -> void:
	if state != 2 || !holding:
		return
	holding = false
	match settings_state:
		-1, 0, 1:
			settings_bucket.append(current_hold)
			settings_text.bbcode_text += "%.3fs\n" % current_hold
			if settings_bucket.size() >= 5:
				var avg := 0.0
				for s in settings_bucket:
					avg += s
				if settings_state <= 0:
					GameData.DOT_LENGTH = avg / settings_bucket.size()
					_set_settings_state(1)
				elif settings_state == 1:
					GameData.DASH_LENGTH = avg / settings_bucket.size()
					if GameData.DASH_LENGTH < (GameData.DOT_LENGTH + 0.025):
						_set_settings_state(-1)
					else:
						_set_settings_state(2)
		2:
			current_hold = 0.0
			has_broken_first_hold = true
