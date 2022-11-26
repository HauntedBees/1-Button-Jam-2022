extends Node

var difficulty := 1
var story_score := 0.0
var typing_score := 0.01
var max_typing_score := 0.01
var last_state := ""
var active_troops := false
var fast_forward := false
var debug_mode := false

var DOT_LENGTH := 0.1
var DASH_LENGTH := 0.25
var WAIT_LENGTH := 0.5
var PRESS_INPUT := ""

var milestones := []#["INNOCENT_KILL", "SOS_IGNORED", "ESCAPE_OVERKILL", "MAIN_DIED"]

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
#  ESCAPE_CORNERED
#  ESCAPE_KILLED
#  ESCAPE_SURVIVED
#  ESCAPE_OVERKILL

# General
#  MAIN_DIED
