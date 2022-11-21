class_name MessageData
extends Node

var message: String
var choices: Array
func _init(m: String, c: Array) -> void:
	message = m
	choices = c

func evaluate(input: String) -> MessageResponse:
	var fail := ""
	for c in choices:
		var id := c as InputData
		if input.length() < id.input.length():
			continue
		var similarity := input.similarity(id.input)
		if similarity >= id.min_score:
			GameData.typing_score += similarity
			GameData.story_score += 10
			match id.special:
				InputData.SPECIAL.NONE:
					return MessageResponse.new(MessageResponse.TYPE.DONE, id.success_next)
				InputData.SPECIAL.DIFFICULTY_BRANCH:
					return MessageResponse.new(MessageResponse.TYPE.DONE, id.special_info[GameData.difficulty])
				InputData.SPECIAL.SWITCH_MISSION:
					return MessageResponse.new(MessageResponse.TYPE.SWITCH_SCENE, id.special_info["type"])
		else:
			fail = id.fail_next
	return MessageResponse.new(MessageResponse.TYPE.DONE, fail)
