extends Control

enum GAME { BUNKER }

onready var arm: Sprite = $Room/PlayerArm
onready var label: RichTextLabel = $PanelContainer/RichTextLabel

onready var bunker: Bunker = $Table/Modes/GameBunker/ViewportContainer/Viewport/Bunker
onready var parser: MorseParser = $MorseParser

var _current_mission = GAME.BUNKER

var current_message := ""

func _ready() -> void:
	parser.connect("send_letter", bunker, "_on_letter_sent")

func _on_Node_new_part(s: String) -> void:
	label.bbcode_text = "%s[u]%s[/u]" % [current_message, s]

func _on_Node_send_letter(s: String) -> void:
	if s != "???":
		current_message += s
	label.bbcode_text = current_message


func _on_Node_press() -> void:
	arm.rotation_degrees = 5

func _on_Node_release() -> void:
	arm.rotation_degrees = 0
