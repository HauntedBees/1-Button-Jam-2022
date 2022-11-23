class_name MessagesGame
extends GameBase

onready var speech: RichTextLabel = $"%Speech"
onready var _timer := $Timer
onready var press_to_advance: AnimationPlayer = $"%AnimationPlayer"

var _message_stack := ""
var _current_message := ""
var _current_letters := 0
var _quick_advance_open := false

var _current_idx := "TEST"#"LV1_MISSION1"#"START"
var _current_input := ""
var _waiting := false

func _ready() -> void:
	_start_message()

func set_state(state: String, args: Array = []) -> void:
	_current_idx = state
	_start_message(args)

func _start_message(args: Array = []) -> void:
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
		_current_input += s
	else:
		if _quick_advance_open:
			_quick_advance_open = false
			press_to_advance.play("MoveOut")
		var mi: MessageData = MessageInfo.messages[_current_idx]
		var res: MessageResponse = mi.evaluate(_current_input)
		match res.type:
			MessageResponse.TYPE.DONE:
				emit_signal("add_space")
				if GameData.active_troops:
					get_tree().call_group("troops", "_start_troops")
				_current_idx = res.val
				_start_message()
			MessageResponse.TYPE.SWITCH_SCENE:
				emit_signal("add_space")
				GameData.last_state = _current_idx
				emit_signal("choice_made", res.val)

func _on_timer() -> void:
	if _current_message == "":
		return
	_current_letters += 1
	if _current_letters >= _current_message.length(): # end of message
		_message_stack += "%s\n" % _current_message
		_current_message = ""
		speech.bbcode_text = _message_stack
		input_matters = true
		_waiting = false
		emit_signal("add_space")
		if MessageInfo.messages[_current_idx].is_quick_advance():
			press_to_advance.play("MoveIn")
			_quick_advance_open = true
	elif _current_message[_current_letters] == " ": # end of word
		var word := _current_message.split(" ")[0]
		_current_message = _current_message.substr(_current_letters + 1)
		_message_stack += word + " "
		_current_letters = 0
		speech.bbcode_text = _message_stack
	else: # middle of word
		var msg := _current_message.substr(0, _current_letters)
		var remaining_len := " ".repeat((_current_message.replace(msg, "").split(" ")[0] as String).length())
		speech.bbcode_text = "%s%s%s" % [_message_stack, msg, remaining_len]
