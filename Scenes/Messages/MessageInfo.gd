extends Node

var messages := [
	{
		"message": "Okay, I think the coast is clear. We need to send a message out and see if we can get a response. Send out a \"CQ\" and we'll get this show on the road.",
		"requirement": "CQ",
		"min_score": 1.0,
		"fail": "No, that wasn't right. Send out C Q. Look at the chart at the bottom of your desk. \"C\" is \"dot dash dot dash\" and \"Q\" is \"dash dash dot dash.\" Give it another try.",
		"repeat": true
	}
]
