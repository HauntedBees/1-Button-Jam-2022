extends Control

const GAME_BUNKER := preload("res://Scenes/Bunker/GameBunker.tscn")
const GAME_MESSAGE := preload("res://Scenes/Messages/Messages.tscn")
enum GAME { BUNKER, MESSAGE }

const LABEL_FORMAT_STRING := "[right]%s[/right]"
const INVALID_FORMAT_STRING := "[color=#666666]%s[/color]"

onready var mode_container: Control = $Table/Modes
onready var arm: Sprite = $Room/PlayerArm
onready var label: RichTextLabel = $"%PlayerType"

onready var parser: MorseParser = $MorseParser
onready var current_game: GameBase = $Table/Modes/Messages

var current_mode = GAME.MESSAGE
var current_message := ""

func _ready() -> void:
	_connect_game()

func _connect_game() -> void:
	parser.connect("send_letter", current_game, "_on_letter_sent")
	current_game.connect("add_space", self, "_on_add_space")

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
	label.bbcode_text = LABEL_FORMAT_STRING % current_message

func _on_Node_press() -> void:
	arm.rotation_degrees = 5

func _on_Node_release() -> void:
	arm.rotation_degrees = 0
