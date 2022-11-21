extends Node

var placeholder := MessageData.new("", [])

const CHAR_INFO := {
	"Siarland": { "name": "Jiongeo", "pronoun": "him" },
	"Inguing": { "name": "Manatar", "pronoun": "her" },
	"Sipoam": { "name": "Alafo", "pronoun": "him" },
	"Mastong": { "name": "Teng", "pronoun": "them" },
	"Xunhuinam": { "name": "Li", "pronoun": "her" },
	"Masomai": { "name": "Mingal", "pronoun": "him" }
}

var messages := {
	"START": MessageData.new("Okay, I think the coast is clear. We need to send a message out and see if we can get a response. Send out a \"CQ 5\" and we'll get this show on the road.", [
		InputData.new("CQ", 1.0, "CIPHER_TEST", "START_FAIL")
	]),
	"START_FAIL": MessageData.new("No, that wasn't right. Send out C Q 5. Look at the chart at the bottom of your desk. \"C\" is \"dot dash dot dash,\" \"Q\" is \"dash dash dot dash,\" and \"5\" is \"dot dot dot dot dot.\" Give it another try.", [
		InputData.new("CQ", 1.0, "CIPHER_TEST", "START_FAIL")
	]),
	"CIPHER_TEST": MessageData.new("Great. Let's see if we get a response. .... .... .... Okay, great. Someone replied. We need to make sure they're on our side now, so let's send an encoded message. See the ROT13 Cipher on your desk? We're going to use that to send them a \"HELLO.\" Based on that chart, you'd send \"URYYB,\" so send that. Add a \"5\" to the end to signify the end of your transmission.", [
		InputData.new("URYYB", 0.6, "CIPHER_PASS", "CIPHER_WRONG"),
		InputData.new("HELLO", 0.6, "CIPHER_WRONG", "CIPHER_BONKED")
	]),
	"CIPHER_PASS": MessageData.new("Perfect! To any enemies, they'll just get gibberish, but our allies will know to decode it and-- aha, we got a response already! \"URL\" - or \"HEY\" when decoded! Perfect! Alright, now we're among friends! Let them know who we are, so send \"FROM P H 5\" to let them know it's us - Pezan and Hails.", [
		InputData.new("FROMPH", 0.5, "GREETED", "GREETED")
	]),
	"CIPHER_WRONG": MessageData.new("That's a good greeting, but we need to make sure the right person is getting this message. We'll encode it with a cipher that only our allies know. So instead of \"HELLO,\" use the ROT13 cipher and send \"URYYB\" instead. And then add a \"5\" at the end to signify the end of transmission.", [
		InputData.new("URYYB", 0.6, "CIPHER_PASS", "CIPHER_WRONG"),
		InputData.new("HELLO", 0.6, "CIPHER_WRONG", "CIPHER_BONKED")
	]),
	"CIPHER_BONKED": MessageData.new("No, I don't think that's right. See the ROT13 cipher on your desk? When encoding something with it, you replace each letter in the word with the corresponding letter on the bottom of that chart. So A becomes N, B becomes O, C becomes P, and so on. So let's try sending an encoded \"HELLO,\" which would be \"URYYB.\" Then add a \"5\" at the end to signify the end of transmission.", [
		InputData.new("URYYB", 0.6, "CIPHER_PASS", "CIPHER_WRONG"),
		InputData.new("HELLO", 0.6, "CIPHER_WRONG", "CIPHER_BONKED")
	]),
	"GREETED": MessageData.new("Okay, let's see what they say... .... .... .... .... .... .... Looks like we're talking to Jorent, Bezatong, and Bangord. Let's get a status message from them, send \"STATUS 5.\"", [
		InputData.new("STATUS", 0.0, "", "", InputData.SPECIAL.DIFFICULTY_BRANCH, {
			1: "LV1_MISSION1",
			2: "LV2_MISSION1"
		})
	]),
	
	"LV1_MISSION1": MessageData.new(".... .... .... They suspect someone in the northern bloc is a spy; somebody is sneaking out towards the docks at night to talk to police officers. We have access to a camera near those docks. Let's keep an eye on them; let's switch to the dock camera and try to figure out who it is. Pay attention to their movements and body shape to figure out who it is, then type their name!", [
		InputData.new("", 0.0, "", "", InputData.SPECIAL.SWITCH_MISSION, { "type": "DOCK" })
	]),
	"LV1_MISSION1_FAIL": MessageData.new("Well, that doesn't help us... I guess whoever that was will get away scot-free.", [
		InputData.new("", 0.0, "LV1_UH_OH")
	]),
	"LV1_MISSION1_SUCCESS": MessageData.new("%s? %s %s? Wow... I never would have expected %s to be a spy... Well, it looks like we'll put a stop to that now, at least.", [
		InputData.new("", 0.0, "LV1_UH_OH", "", InputData.SPECIAL.START_TROOPS)
	]),
	"LV1_UH_OH": MessageData.new("Uh-oh!", [
		InputData.new("", 0.0, "START")
	])
}
