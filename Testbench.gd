extends Control

const GAMES := {
	"BUNKER": preload("res://Scenes/Bunker/GameBunker.tscn"),
	"DOCK": preload("res://Scenes/Lineup/GameDock.tscn"),
	"MESSAGES": preload("res://Scenes/Messages/Messages.tscn"),
	"SHIP": preload("res://Scenes/Ship/GameShip.tscn"),
	"TITLE": preload("res://Scenes/Title/TitleScreen.tscn"),
	"END": preload("res://Scenes/Title/GameOver.tscn")
}
enum GAME { BUNKER, MESSAGES, DOCK, SHIP, TITLE, END }

const LABEL_FORMAT_STRING := "[right]%s[/right]"
const INVALID_FORMAT_STRING := "[color=#666666]%s[/color]"

onready var player: Sprite = $"%Player"
onready var arm: Sprite = $"%PlayerArm"
onready var label: RichTextLabel = $"%PlayerType"

onready var last_soldier: AnimatedSprite = $"%SoldierLast"
onready var parser: MorseParser = $MorseParser
onready var game_holder: Control = $"%GameHolder"
onready var current_game: GameBase = $Table/GameHolder/Messages
onready var soldiers = $Room/Background/SoldierArea

var current_mode = GAME.TITLE#GAME.END#GAME.MESSAGES#GAME.TITLE#
var current_message := ""
var fucking_dead := false

func _ready() -> void:
	_initialize_game()

func _initialize_game(addtl_info := 0) -> void:
	if current_game:
		game_holder.remove_child(current_game)
		current_game.queue_free()
	var key_str: String = GAME.keys()[current_mode]
	current_game = GAMES[key_str].instance()
	game_holder.add_child(current_game)
	if addtl_info > 0:
		current_game.additional_setup(addtl_info)
	parser.connect("send_letter", current_game, "_on_letter_sent")
	current_game.connect("add_space", self, "_on_add_space")
	current_game.connect("choice_made", self, "_on_choice_made")
	if current_mode == GAME.TITLE:
		parser.connect("press", current_game, "_on_press")
		parser.connect("press_key", current_game, "_on_press_key")
		parser.connect("release", current_game, "_on_release")

func _on_choice_made(choice: String) -> void:
	if fucking_dead:
		return
	_on_add_space()
	match current_mode:
		GAME.END:
			current_mode = GAME.TITLE
			_initialize_game()
		GAME.TITLE:
			current_mode = GAME.MESSAGES
			soldiers.reset_troops()
			_initialize_game()
			(current_game as MessagesGame).set_state("START")
		GAME.MESSAGES:
			if choice.find("ESCAPE") == 0:
				current_mode = GAME.BUNKER
				_initialize_game(int(choice.replace("ESCAPE", "")))
			else:
				match choice:
					"DOCK": current_mode = GAME.DOCK
					"SHIP": current_mode = GAME.SHIP
					"END": current_mode = GAME.END
				_initialize_game()
		GAME.BUNKER:
			current_mode = GAME.MESSAGES
			_initialize_game()
			var m := current_game as MessagesGame
			if choice == "won":
				m.set_state("%s_%s" % [GameData.last_state, "SUCCESS"])
			else:
				m.set_state("%s_%s" % [GameData.last_state, "FAIL"])
		GAME.SHIP:
			current_mode = GAME.MESSAGES
			_initialize_game()
			var m := current_game as MessagesGame
			if choice == "won":
				m.set_state("%s_%s" % [GameData.last_state, "SUCCESS"])
			else:
				m.set_state("%s_%s" % [GameData.last_state, "FAIL"])
		GAME.DOCK:
			current_mode = GAME.MESSAGES
			_initialize_game()
			var m := current_game as MessagesGame
			if choice == "":
				m.set_state("%s_%s" % [GameData.last_state, "FAIL"])
			else:
				var person_info: Dictionary = MessageInfo.CHAR_INFO[choice]
				m.set_state("%s_%s" % [GameData.last_state, "SUCCESS"], [choice, person_info["name"], choice, person_info["pronoun"]])

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
	current_message = ""
	#if current_message.length() > 100:
	#	current_message = current_message.substr(60)
	label.bbcode_text = LABEL_FORMAT_STRING % current_message

func _on_Node_press() -> void:
	arm.rotation_degrees = 1

func _on_Node_release() -> void:
	arm.rotation_degrees = 0

func _on_SoldierArea_caught() -> void:
	last_soldier.visible = true
	# TODO: make your friend shit his drawers
	current_game.input_matters = false
	GameData.milestones.append("MAIN_DIED")
	fucking_dead = true
	yield(get_tree().create_timer(2.0), "timeout")
	last_soldier.visible = false
	player.visible = false
	arm.visible = false
	fucking_dead = false
	current_mode = GAME.END
	_initialize_game()
