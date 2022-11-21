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
	"START": MessageData.new("Okay, I think the coast is clear. We need to send a message out and see if we can get a response. Send out a \"CQ\" and we'll get this show on the road.", [
		InputData.new("CQ", 1.0, "CIPHER_TEST", "START_FAIL")
	]),
	"START_FAIL": MessageData.new("No, that wasn't right. Send out C Q. Look at the chart at the bottom of your desk. \"C\" is \"dot dash dot dash\" and \"Q\" is \"dash dash dot dash.\" Give it another try.", [
		InputData.new("CQ", 1.0, "CIPHER_TEST", "START_FAIL")
	]),
	"CIPHER_TEST": MessageData.new("Great. Let's see if we get a response. .... .... .... Okay, great. Someone replied. We need to make sure they're on our side now, so let's send an encoded message. See the ROT13 Cipher on your desk? We're going to use that to send them a \"HELLO.\" Based on that chart, you'd send \"URYYB,\" so send that.", [
		InputData.new("URYYB", 0.6, "CIPHER_PASS", "CIPHER_WRONG"),
		InputData.new("HELLO", 0.6, "CIPHER_WRONG", "CIPHER_BONKED")
	]),
	"CIPHER_PASS": MessageData.new("Perfect! To any enemies, they'll just get gibberish, but our allies will know to decode it and-- aha, we got a response already! \"URL\" - or \"HEY\" when decoded! Perfect! Alright, now we're among friends! Let them know who we are, so send \"FROM PEZAN AND HAILS.\"", [
		InputData.new("FROM PEZAN AND HAILS", 0.5, "GREETED", "GREETED")
	]),
	"CIPHER_WRONG": MessageData.new("That's a good greeting, but we need to make sure the right person is getting this message. We'll encode it with a cipher that only our allies know. So instead of \"HELLO,\" use the ROT13 cipher and send \"URYYB\" instead.", [
		InputData.new("URYYB", 0.6, "CIPHER_PASS", "CIPHER_WRONG"),
		InputData.new("HELLO", 0.6, "CIPHER_WRONG", "CIPHER_BONKED")
	]),
	"CIPHER_BONKED": MessageData.new("No, I don't think that's right. See the ROT13 cipher on your desk? When encoding something with it, you replace each letter in the word with the corresponding letter on the bottom of that chart. So A becomes N, B becomes O, C becomes P, and so on. So let's try sending an encoded \"HELLO,\" which would be \"URYYB.\"", [
		InputData.new("URYYB", 0.6, "CIPHER_PASS", "CIPHER_WRONG"),
		InputData.new("HELLO", 0.6, "CIPHER_WRONG", "CIPHER_BONKED")
	]),
	"GREETED": MessageData.new("Okay, let's see what they say... .... .... .... .... .... .... Looks like we're talking to Jorent, Bezatong, and Bangord. Let's get a status message from them, send \"STATUS.\"", [
		InputData.new("STATUS", 0.0, "", "", InputData.SPECIAL.DIFFICULTY_BRANCH, {
			1: "LV1_MISSION1",
			2: "LV2_MISSION1"
		})
	]),
	"LV1_MISSION1": MessageData.new(".... .... .... They suspect someone in the northern bloc is a spy, someone is sneaking out towards the docks at night to talk to someone. We have access to a camera near those docks. Let's keep an eye on them; type \"DOCK\" to switch to the dock camera.", [
		InputData.new("DOCK", 0.0, "", "", InputData.SPECIAL.SWITCH_MISSION, {
			"type": "DOCK",
			"difficulty": 1
		})
	])
}
