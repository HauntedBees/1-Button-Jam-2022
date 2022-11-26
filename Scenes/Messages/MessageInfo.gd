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
	"TEST": MessageData.new("A", [
		InputData.new("", 0.0, "", "", InputData.SPECIAL.SWITCH_MISSION, { "type": "SHIP" })
	]),
	"TEST_FAIL": MessageData.new("LOSE", [
		InputData.new("", 0.0, "", "", InputData.SPECIAL.SWITCH_MISSION, { "type": "SHIP" })
	]),
	"TEST_SUCCESS": MessageData.new("WIN", [
		InputData.new("", 0.0, "", "", InputData.SPECIAL.SWITCH_MISSION, { "type": "SHIP" })
	]),
	
	"TYPING_TRIAL": MessageData.new("I'm glad you decided to take some time to improve your morsing skills, Hails. Fast typing is the difference between winning and losing in a war like this. Remember, you'll need to type \"5\" after every prompt, and you can ignore spaces. These challenges WILL be timed; try to get as far as you can! Morse \"5\" when you're ready.", [
		InputData.new("", 0.0, "TYPING_1")
	]),
	"TYPING_1": MessageData.new("To start, type our names, \"PEZAN HAILS.\"", [
		InputData.new("PEZANHAILS", 0.75, "TYPING_2", "TYPING_FAIL")
	]),
	"TYPING_2": MessageData.new("Good. Now type our ROT13-encoded names, \"CRMNA UNVYF.\"", [
		InputData.new("CRMNAUNVYF", 0.75, "TYPING_3", "TYPING_FAIL")
	]),
	"TYPING_3": MessageData.new("Good. Now for our motto, \"BECOME UNGOVERNABLE.\"", [
		InputData.new("BECOMEUNGOVERNABLE", 0.66, "TYPING_4", "TYPING_FAIL")
	]),
	"TYPING_4": MessageData.new("Now type what we're fighting for, \"A BETTER WORLD IS POSSIBLE!!\"", [
		InputData.new("ABETTERWORLDISPOSSIBLE", 0.66, "TYPING_5", "TYPING_FAIL")
	]),
	"TYPING_5": MessageData.new("Remember the old days when we were merely protesting a failing government, instead of fighting a corrupt government? Things were so much easier then... Anyway, type our battle cry from those days: RESPECT EXISTENCE OR EXPECT RESISTANCE.", [
		InputData.new("RESPECTEXISTENCEOREXPECTRESISTANCE", 0.66, "TYPING_6", "TYPING_FAIL")
	]),
	"TYPING_6": MessageData.new("Wow, you can even type longer phrases like that. How about, uh... .... \"ANTIDISESTABLISHMENTARIANISM.\"", [
		InputData.new("ANTIDISESTABLISHMENTARIANISM", 0.5, "TYPING_7", "TYPING_FAIL")
	]),
	"TYPING_7": MessageData.new("Ha ha, neat! I don't even remember what that word means, I just remember it was one of the longest words in the English language. How about one of the longest words in OUR language, though? Type out \"MANDITAANTRIEMENETGAR!\"", [
		InputData.new("MANDITAANTRIEMENETGAR", 0.5, "TYPING_8", "TYPING_FAIL")
	]),
	"TYPING_8": MessageData.new("Manditaantriemenetgar is a type of rice porridge they used to make in the old days. I have no idea why they gave it such a long name. Let's let the world know I think that! Type \"FOODS SHOULD HAVE SHORTER NAMES.\"", [
		InputData.new("FOODSSHOULDHAVESHORTERNAMES", 0.66, "TYPING_9", "TYPING_FAIL")
	]),
	"TYPING_9": MessageData.new("Alright, two more left. Let's make this one tricky. Decode this and type out the DECODED message: \"GUNAX LBH SBE CYNLVAT.\"", [
		InputData.new("THANKYOUFORPLAYING", 0.66, "TYPING_10", "TYPING_FAIL")
	]),
	"TYPING_10": MessageData.new("Thank you for playing this game! Now type out the names of the three people most responsible for this game to thank them. \"CECILIA SKYLER SEAN.\"", [
		InputData.new("CECILIASKYLERSEAN", 0.75, "TYPING_WIN", "TYPING_FAIL")
	]),
	"TYPING_WIN": MessageData.new("You did it! Congratulations on completing the Morse Typing Challenge. You're a Morse Master now!", [
		InputData.new("", 0.0, "", "", InputData.SPECIAL.SWITCH_MISSION, { "type": "END" })
	]),
	"TYPING_FAIL": MessageData.new("Oh well... better luck next time!", [
		InputData.new("", 0.0, "", "", InputData.SPECIAL.SWITCH_MISSION, { "type": "END" })
	]),
	
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
			2: "LV2_MISSION1",
			3: "LV2_MISSION1",
			4: "LV1_MISSION1", # these difficulties start off with troops
			5: "LV1_MISSION1"
		})
	]),
	
	"LV1_MISSION1": MessageData.new(".... .... .... They suspect someone in the northern bloc is a spy; somebody is sneaking out towards the docks at night to talk to police officers. We have access to a camera near those docks. Let's keep an eye on them; let's switch to the dock camera and try to figure out who it is. Pay attention to their movements and body shape to figure out who it is, then type their name!", [
		InputData.new("", 0.0, "", "", InputData.SPECIAL.SWITCH_MISSION, { "type": "DOCK" })
	]),
	"LV1_MISSION1_FAIL": MessageData.new("Well, that doesn't help us... I guess whoever that was will get away scot-free.", [
		InputData.new("", 0.0, "LV1_UH_OH")
	]),
	"LV1_MISSION1_SUCCESS": MessageData.new("%s? %s %s? Wow... I never would have expected %s to be a spy... Well, it looks like we'll put a stop to that now, at least.", [
		InputData.new("", 0.0, "LV1_NEXT")
	]),
	
	"LV2_MISSION1": MessageData.new(".... .... .... They suspect someone in the northern bloc is a spy; somebody is sneaking out towards the docks at night to talk to police officers. We have access to a camera near those docks. Let's keep an eye on them; let's switch to the dock camera and try to figure out who it is. Pay attention to their movements and body shape to figure out who it is, then type their name!", [
		InputData.new("", 0.0, "", "", InputData.SPECIAL.SWITCH_MISSION, { "type": "DOCK" })
	]),
	"LV2_MISSION1_FAIL": MessageData.new("Well, that doesn't help us... I guess whoever that was will get away scot-free.", [
		InputData.new("", 0.0, "LV2_UH_OH")
	]),
	"LV2_MISSION1_SUCCESS": MessageData.new("%s? %s %s? Wow... I never would have expected %s to be a spy... Well, it looks like we'll put a stop to that now, at least.", [
		InputData.new("", 0.0, "LV2_UH_OH", "", InputData.SPECIAL.START_TROOPS)
	]),
	"LV2_UH_OH": MessageData.new("Uh-oh! I think someone is upstairs. We'll need to be very quiet now... be careful when typing, pause often if you can to not attract their attention...", [
		InputData.new("", 0.0, "LV1_NEXT")
	]),
		
	"LV1_NEXT": MessageData.new("We need to find out how else we can help. Send out a \"WAITING5\" and let's see what we get in response.", [
		InputData.new("WAITING", 0.6, "LV1_WAITINGRESPONSE", "LV1_NEXTFAIL")
	]),
	"LV1_NEXTFAIL": MessageData.new("No response... let's try again. Send out \"WAITING5\" and let's see what happens.", [
		InputData.new("WAITING", 0.4, "LV1_WAITINGRESPONSE", "LV1_NEXTFAIL")
	]),
	"LV1_WAITINGRESPONSE": MessageData.new("Uh-oh, we've got an SOS. \"SOS -- ERCYL JVGU EBTRE.\" I think that's ROT13 encoded. Decode it and reply back!", [
		InputData.new("ROGER", 0.5, "LV1_MISSION2", "LV1_SOSFAIL"),
		InputData.new("EBTRE", 0.5, "LV1_MISSION2", "LV1_SOSFAIL")
	], "SOS_IGNORED"),
	"LV1_SOSFAIL": MessageData.new("Hmm... They aren't responding back. You must not have replied right. Hopefully someone else will be able to help them.", [
		InputData.new("", 0.0, "LV1_NEW_SOS")
	]),
	"LV1_MISSION2": MessageData.new("Oh good, they're responding. This is a long one; let me decode it. .... .... .... .... Their ship is under attack and their cannon operator is incapacitated! They need someone to help direct their shots. I guess we'll have to help them out! You'll just need to type out grid coordinates and they'll fire there! Let's do this!", [
		InputData.new("", 0.0, "", "", InputData.SPECIAL.SWITCH_MISSION, { "type": "SHIP" })
	]),
	"LV1_MISSION2_FAIL": MessageData.new("Connection gone... I think we lost them... .... .... .... .... .... .... We don't have time to mourn them now. The best way to honor their deaths is to win this war. Jinori, Hiabind, Touinar... rest in peace.", [
		InputData.new("", 0.0, "LV1_NEW_SOS")
	]),
	"LV1_MISSION2_SUCCESS": MessageData.new("We did it! You did it! We sank their battleship! Officer Jinori sends his regards, and his boatmates Hiabind and Touinar thank you as well!", [
		InputData.new("", 0.0, "LV1_NEW_SOS")
	]),
	"LV1_NEW_SOS": MessageData.new("Oh, we're getting another encoded SOS. Send out an encoded \"STATUS\" to get more information from them!", [
		InputData.new("FGNGHF", 0.5, "LV1_MISSION3", "LV1_NEW_SOS_FAIL"),
		InputData.new("STATUS", 0.5, "LV1_NEW_SOS2_UNENCODED", "LV1_NEW_SOS_FAIL")
	], "ESCAPE_IGNORED"),
	"LV1_NEW_SOS_FAIL": MessageData.new("What are you doing?! They're not going to respond to nonsense messages like that... let's hope someone else helps them...", [
		InputData.new("", 0.0, "END")
	]),
	"LV1_NEW_SOS2_UNENCODED": MessageData.new("Oh no, you sent that \"STATUS\" message unencoded... hopefully nobody is listening in. Let's see if they respond...", [
		InputData.new("", 0.0, "LV1_MISSION3")
	]),
	"LV1_MISSION3": MessageData.new("They're responding. Let me decode this... Kongueo snuck into an enemy base to steal some intel, and now needs help getting out. Navigate by telling him how to get out and when to avoid enemies by sending him messages!", [
		InputData.new("", 0.0, "", "", InputData.SPECIAL.SWITCH_MISSION, { "type": "ESCAPE" })
	]),
	"LV1_MISSION3_SUCCESS": MessageData.new("You did it! Kongueo got out with the intel! Let's wait a minute and see what he reports when he gets back to his base! .... .... .... This is big! This could turn the tide in our favor!", [
		InputData.new("", 0.0, "END")
	]),
	"LV1_MISSION3_FAIL": MessageData.new("...Rest in Peace, Jast Kongueo. You died for a noble cause. Morse \"F\" to pay respects.", [
		InputData.new("F", 1.0, "END", "RESPECT_WRONG")
	]),
	"RESPECT_WRONG": MessageData.new("You can't even pay respects to our friend properly? You know, I'm starting to suspect that you might be a spy intentionally sabotaging our operations...", [
		InputData.new("", 0.0, "", "", InputData.SPECIAL.SWITCH_MISSION, { "type": "END" })
	]),
	"END": MessageData.new("Well, we've done all we can for now. Let's sit tight until the next mission. Good work today, Hails.", [
		InputData.new("", 0.0, "", "", InputData.SPECIAL.SWITCH_MISSION, { "type": "END" })
	])
}
