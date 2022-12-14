class_name MessageData
extends Node

var message: String
var choices: Array
var fail_story: String
func _init(m: String, c: Array, fs := "") -> void:
	message = m
	choices = c
	fail_story = fs

func is_quick_advance() -> bool:
	return choices.size() == 1 && (choices[0] as InputData).input == ""

func word_length() -> int:
	return (choices[0] as InputData).input.length()

func evaluate(input: String) -> MessageResponse:
	var fail := ""
	for c in choices:
		var id := c as InputData
		var similarity := input.similarity(id.input)
		GameData.max_typing_score += 1.0
		if similarity >= id.min_score:
			GameData.typing_score += similarity
			GameData.story_score += 10
			match id.special:
				InputData.SPECIAL.NONE:
					return MessageResponse.new(MessageResponse.TYPE.DONE, id.success_next)
				InputData.SPECIAL.DIFFICULTY_BRANCH:
					if id.special_info.has(GameData.difficulty):
						return MessageResponse.new(MessageResponse.TYPE.DONE, id.special_info[GameData.difficulty])
					else:
						return MessageResponse.new(MessageResponse.TYPE.DONE, id.special_info[1])
				InputData.SPECIAL.SWITCH_MISSION:
					if id.special_info.has("subtype"):
						return MessageResponse.new(MessageResponse.TYPE.SWITCH_SCENE, id.special_info["type"])
					else:
						return MessageResponse.new(MessageResponse.TYPE.SWITCH_SCENE, id.special_info["type"])
				InputData.SPECIAL.START_TROOPS:
					return MessageResponse.new(MessageResponse.TYPE.DONE_ALSO_ADD_SOLDIERS, id.success_next)
		else:
			fail = id.fail_next
	if fail_story != "":
		GameData.milestones.append(fail_story)
	return MessageResponse.new(MessageResponse.TYPE.DONE, fail)
