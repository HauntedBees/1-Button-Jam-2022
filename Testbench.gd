extends Control

const GAMES := {
	"BUNKER": preload("res://Scenes/Bunker/GameBunker.tscn"),
	"DOCK": preload("res://Scenes/Lineup/GameDock.tscn"),
	"MESSAGES": preload("res://Scenes/Messages/Messages.tscn")
}
enum GAME { BUNKER, MESSAGES, DOCK }

const LABEL_FORMAT_STRING := "[right]%s[/right]"
const INVALID_FORMAT_STRING := "[color=#666666]%s[/color]"

onready var arm: Sprite = $Room/PlayerArm
onready var label: RichTextLabel = $"%PlayerType"

onready var parser: MorseParser = $MorseParser
onready var game_holder: Control = $"%GameHolder"
onready var current_game: GameBase = $Table/GameHolder/Messages

var current_mode = GAME.MESSAGES
var current_message := ""

func _ready() -> void:
	_initialize_game()

func _initialize_game() -> void:
	if current_game:
		game_holder.remove_child(current_game)
		current_game.queue_free()
	var key_str: String = GAME.keys()[current_mode]
	current_game = GAMES[key_str].instance()
	game_holder.add_child(current_game)
	parser.connect("send_letter", current_game, "_on_letter_sent")
	current_game.connect("add_space", self, "_on_add_space")
	current_game.connect("choice_made", self, "_on_choice_made")

func _on_choice_made(choice: String) -> void:
	_on_add_space()
	match current_mode:
		GAME.MESSAGES:
			match choice:
				"DOCK":
					current_mode = GAME.DOCK
					_initialize_game()
		GAME.DOCK:
			current_mode = GAME.MESSAGES
			_initialize_game()
			var m := current_game as MessagesGame
			if choice == "":
				m.add_message("Well, that doesn't help us... I guess whoever that was will get away scot-free.")
			else:
				var person_info: Dictionary = MessageInfo.CHAR_INFO[choice]
				m.add_message("%s? %s %s? Wow... I never would have expected %s to be a spy... Well, it looks like we'll put a stop to that now, at least." % [choice, person_info["name"], choice, person_info["pronoun"]])

func _on_Node_new_part(s: String) -> void:
	var msg := s if current_game.input_matters else (INVALID_FORMAT_STRING % s)
	label.bbcode_text = "[right]%s[u]%s[/u][/right]" % [current_message, msg]

func _on_Node_send_letter(s: String) -> void:
	if s != "?":
		if current_game.input_matters:
			current_message += s
		else:
			current_message += INVALID_FORMAT_STRING % s
	label.bbcode_text = LABEL_FORMAT_STRING % current_message

func _on_add_space() -> void:
	current_message += "  "
	#if current_message.length() > 100:
	#	current_message = current_message.substr(60)
	label.bbcode_text = LABEL_FORMAT_STRING % current_message

func _on_Node_press() -> void:
	arm.rotation_degrees = 5

func _on_Node_release() -> void:
	arm.rotation_degrees = 0
