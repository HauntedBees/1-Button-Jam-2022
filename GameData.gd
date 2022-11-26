extends Node

var difficulty := 1
var story_score := 0.0
var typing_score := 0.0
var last_state := ""
var active_troops := true

var milestones := []

var DOT_LENGTH := 0.1
var DASH_LENGTH := 0.25
var WAIT_LENGTH := 0.5
var PRESS_INPUT := ""

# Dock
#  FOUND_SPY
#  INNOCENT_KILL
#  NO_SPY_KILL

# Boat Attack
#  SOS_IGNORED
#  SOS_DEFEAT
#  SOS_VICTORY

# Escape Mission
#  ESCAPE_IGNORED
