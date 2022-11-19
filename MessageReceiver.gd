extends RichTextLabel

onready var _timer := Timer.new()
var _message_stack := ""
var _current_message := ""
var _current_letters := 0

func _ready() -> void:
	_timer.wait_time = 0.025
	_timer.autostart = true
	_timer.connect("timeout", self, "_on_timer")
	add_child(_timer)
	add_message("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed cursus dignissim dictum. Nam a ex est. Donec imperdiet egestas lacinia. Mauris hendrerit risus sed dui eleifend, non placerat magna sollicitudin. Cras et sem mauris. Pellentesque maximus eget dolor at aliquet. Cras iaculis vel lorem id ullamcorper. Maecenas condimentum mi et eros congue volutpat. Nulla porta imperdiet mollis. Suspendisse et ipsum ipsum. Morbi ornare ante porttitor metus consectetur auctor. Proin vitae ipsum in est interdum sagittis. In posuere ex vel tellus pretium, nec porttitor dolor varius. Nullam nibh turpis, fermentum pellentesque lobortis in, condimentum vitae sem. In dapibus consequat felis eget ultricies. Aliquam lacinia congue metus vitae accumsan. Phasellus semper aliquet lorem id interdum. Ut efficitur neque ac tempus volutpat.")

func add_message(s: String):
	_current_message = s
	_current_letters = 0

func _on_timer():
	if _current_message == "":
		return
	_current_letters += 1
	if _current_letters >= _current_message.length(): # end of message
		_message_stack += "%s\n" % _current_message
		_current_message = ""
		bbcode_text = _message_stack
	elif _current_message[_current_letters] == " ": # end of word
		var word := _current_message.split(" ")[0]
		_current_message = _current_message.substr(_current_letters + 1)
		_message_stack += word + " "
		_current_letters = 0
		bbcode_text = _message_stack
	else: # middle of word
		var msg := _current_message.substr(0, _current_letters)
		var remaining_len := " ".repeat((_current_message.replace(msg, "").split(" ")[0] as String).length())
		bbcode_text = "%s%s%s" % [_message_stack, msg, remaining_len]
