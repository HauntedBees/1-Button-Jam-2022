class_name MessagesGame
extends GameBase

onready var speech: RichTextLabel = $"%Speech"
onready var _timer := $Timer
onready var press_to_advance: AnimationPlayer = $"%AnimationPlayer"
onready var clock: Sprite = $"%Clock"
onready var ticker: Sprite = $"%Ticker"
onready var clock_anim: AnimationPlayer = $"%ClockAnim"

var _message_stack := ""
var _current_message := ""
var _current_letters := 0
var _quick_advance_open := false
var clock_time_remaining := 0.0
var is_timing := false

var _current_idx := "START"
var _current_input := ""
var _waiting := false
var _last_letter := ""

func _ready() -> void:
	clock.visible = _use_clock()

func _use_clock() -> bool:
	return GameData.difficulty >= 3

func set_state(state: String, args: Array = []) -> void:
	_current_idx = state
	_start_message(args)

func _start_message(args: Array = []) -> void:
	if _message_stack != "":
		_message_stack += "\n"
	if args.size() > 0:
		add_message(MessageInfo.messages[_current_idx].message % args)
	else:
		add_message(MessageInfo.messages[_current_idx].message)

func add_message(s: String) -> void:
	input_matters = false
	_waiting = true
	_current_message = s
	_current_letters = 0
	_current_input = ""

func _on_letter_sent(s: String) -> void:
	if _waiting:
		return
	if s != "5":
		if s != "?":
			_current_input += s
	else:
		if _use_clock() && is_timing:
			clock_anim.play("FadeOut")
			is_timing = false
		if _quick_advance_open:
			_quick_advance_open = false
			press_to_advance.play("MoveOut")
		var mi: MessageData = MessageInfo.messages[_current_idx]
		var res: MessageResponse = mi.evaluate(_current_input)
		match res.type:
			MessageResponse.TYPE.DONE, MessageResponse.TYPE.DONE_ALSO_ADD_SOLDIERS:
				if res.type == MessageResponse.TYPE.DONE_ALSO_ADD_SOLDIERS:
					GameData.active_troops = true
					get_tree().call_group("troops", "reset_troops")
				emit_signal("add_space")
				if GameData.active_troops:
					get_tree().call_group("troops", "_start_troops")
				_current_idx = res.val
				_start_message()
			MessageResponse.TYPE.SWITCH_SCENE:
				emit_signal("add_space")
				GameData.last_state = _current_idx
				emit_signal("choice_made", res.val)

func _on_timer(not_again := false) -> void:
	if _current_message == "":
		return
	_current_letters += 1
	if _current_letters >= _current_message.length(): # end of message
		_message_stack += _current_message
		_last_letter = "."
		_current_message = ""
		speech.bbcode_text = _message_stack
		input_matters = true
		_waiting = false
		emit_signal("add_space")
		if MessageInfo.messages[_current_idx].is_quick_advance():
			press_to_advance.play("MoveIn")
			_quick_advance_open = true
		elif _use_clock():
			clock_anim.play("FadeIn")
			var wlen: int = MessageInfo.messages[_current_idx].word_length()
			match GameData.difficulty:
				3: clock_time_remaining = 15.0 * wlen
				4: clock_time_remaining = 10.0 * wlen
				5: clock_time_remaining = 5.0 * wlen
			ticker.rotation_degrees = 360.0 * (clock_time_remaining / 120.0)
			is_timing = true
	elif _current_message[_current_letters] == " ": # end of word
		var word := _current_message.split(" ")[0]
		_current_message = _current_message.substr(_current_letters + 1)
		_message_stack += word + " "
		_last_letter = _current_message[-1]
		_current_letters = 0
		speech.bbcode_text = _message_stack
	else: # middle of word
		var msg := _current_message.substr(0, _current_letters)
		_last_letter = msg[-1]
		var remaining_len := " ".repeat((_current_message.replace(msg, "").split(" ")[0] as String).length())
		speech.bbcode_text = "%s%s%s" % [_message_stack, msg, remaining_len]
	if GameData.fast_forward && !not_again:
		_on_timer(true)

func _process(delta: float) -> void:
	if _use_clock() && is_timing:
		clock_time_remaining -= delta
		var rotation := 360.0 * (clock_time_remaining / 120.0)
		ticker.rotation_degrees = min(350.0, rotation)
		if clock_time_remaining <= 0:
			get_tree().call_group("sound", "play_sound", "error")
			_on_letter_sent("5")

func get_some_random_data() -> String:
	return _last_letter
