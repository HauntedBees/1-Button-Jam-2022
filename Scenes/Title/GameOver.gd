class_name GameOver
extends GameBase

onready var info_text: RichTextLabel = $"%InfoText"

func _on_letter_sent(s: String) -> void:
	emit_signal("choice_made", "")

func _ready() -> void:
	input_matters = true
	var messages: PoolStringArray = ["You've had a busy day as a radio operator for the resistance, but it's all in a day's work."]
	# Docks
	if GameData.milestones.has("FOUND_SPY"):
		messages.append("You stopped a spy in their tracks, stopping the state from gaining an advantage in the coming days.")
	elif GameData.milestones.has("NO_SPY_KILL"):
		messages.append("You failed to identify the spy sneaking to the docks. A few days after your mission, the leaked intel led to an ambush, killing three of your comrades and injuring six others.")
	elif GameData.milestones.has("INNOCENT_KILL"):
		messages.append("Your misidentification of a spy led to an innocent comrade being executed. A few days after your mission, the leaked intel led to an ambush, killing four of your comrades and injuring seven others.")
	# Boat Attack
	if GameData.milestones.has("SOS_IGNORED"):
		messages.append("You missed a distress call, leading to a boat of your comrades being sunk by the state. Three people lost their lives in the ship, and several more died in the following days as the medicine they needed was not delivered.")
	elif GameData.milestones.has("SOS_DEFEAT"):
		messages.append("You failed to defend a boat of your comrades from being sunk by the state. Three people lost their lives in the ship, and several more died in the following days as the medicine they needed was not delivered.")
	elif GameData.milestones.has("SOS_VICTORY"):
		messages.append("You helped your comrades escape an attack at sea, allowing them to deliver life-saving medications to other fighters.")
	# Escape Mission
	if GameData.milestones.has("ESCAPE_IGNORED"):
		messages.append("You missed a distress call, leading to your friend Jast Kongueo being killed in an enemy camp.")
	elif GameData.milestones.has("ESCAPE_CORNERED"):
		messages.append("You led your friend Jast Kongueo into a dead end, where they were quickly killed by state soldiers.")
	elif GameData.milestones.has("ESCAPE_KILLED"):
		messages.append("You failed to guide your friend Jast Kongueo out of an enemy camp.")
	elif GameData.milestones.has("ESCAPE_SURVIVED"):
		messages.append("You guided your friend Jast Kongueo out of an enemy camp, bringing valuable intel with him, turning the tides of the next few battles in your favor.")
	elif GameData.milestones.has("ESCAPE_OVERKILL"):
		messages.append("You guided your friend Jast Kongueo out of an enemy camp and helped him kill every last fascist in there. No survivors means they'll never know what happened, but among your circles, you and Kongueo are now legends.")
	# General
	if GameData.milestones.has("MAIN_DIED"):
		if GameData.milestones.size() == 1:
			messages = ["You were killed pretty much immediately by an enemy soldier who found you under the floorboards. Keep an eye on the soldier when you're typing and make sure to pause when he's getting suspicious! Or start on a lower difficulty next time."]
		else:
			messages.append("Then you were killed by an enemy soldier who found you under the floorboards. Don't type so loudly next time!")
	# Score
	messages.append("Story Score: %s" % GameData.story_score)
	messages.append("Typing Accuracy: %.2f%%" % (100.0 * GameData.typing_score / GameData.max_typing_score))
	messages.append("Morse \"5\" (five dots) to return to the main menu.")
	info_text.bbcode_text = messages.join("\n")
