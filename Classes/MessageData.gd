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
					pass
		else:
			fail = id.fail_next
	if fail == "": # message still too short
		return MessageResponse.new(MessageResponse.TYPE.NOT_LONG_ENOUGH)
	else: # message fully failed
		return MessageResponse.new(MessageResponse.TYPE.DONE, fail)
