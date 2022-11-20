class_name MorseChat
extends Control

onready var keys = {
	".": [$L/MorseO],
	"-": [$L/MorseL],
	"..": [$L/MorseO, $L/MorseOo],
	".-": [$L/MorseO, $L/MorseOl],
	"-.": [$L/MorseL, $L/MorseLo],
	"--": [$L/MorseL, $L/MorseLl],
	"...": [$L/MorseO, $L/MorseOo, $L/MorseOoo],
	"..-": [$L/MorseO, $L/MorseOo, $L/MorseOol],
	".-.": [$L/MorseO, $L/MorseOl, $L/MorseOlo],
	".--": [$L/MorseO, $L/MorseOl, $L/MorseOll],
	"-..": [$L/MorseL, $L/MorseLo, $L/MorseLoo],
	"-.-": [$L/MorseL, $L/MorseLo, $L/MorseLol],
	"--.": [$L/MorseL, $L/MorseLl, $L/MorseLlo],
	"---": [$L/MorseL, $L/MorseLl, $L/MorseLll],
	"....": [$L/MorseO, $L/MorseOo, $L/MorseOoo, $L/MorseOooo],
	"...-": [$L/MorseO, $L/MorseOo, $L/MorseOoo, $L/MorseOool],
	"..-.": [$L/MorseO, $L/MorseOo, $L/MorseOol, $L/MorseOolo],
	"..--": [$L/MorseO, $L/MorseOo, $L/MorseOol, $L/MorseOoll],
	".-..": [$L/MorseO, $L/MorseOl, $L/MorseOlo, $L/MorseOloo],
	".--.": [$L/MorseO, $L/MorseOl, $L/MorseOll, $L/MorseOllo],
	".---": [$L/MorseO, $L/MorseOl, $L/MorseOll, $L/MorseOlll],
	"-...": [$L/MorseL, $L/MorseLo, $L/MorseLoo, $L/MorseLooo],
	"-..-": [$L/MorseL, $L/MorseLo, $L/MorseLoo, $L/MorseLool],
	"-.-.": [$L/MorseL, $L/MorseLo, $L/MorseLol, $L/MorseLolo],
	"-.--": [$L/MorseL, $L/MorseLo, $L/MorseLol, $L/MorseLoll],
	"--..": [$L/MorseL, $L/MorseLl, $L/MorseLlo, $L/MorseLloo],
	"--.-": [$L/MorseL, $L/MorseLl, $L/MorseLlo, $L/MorseLlol],
	"---.": [$L/MorseL, $L/MorseLl, $L/MorseLll, $L/MorseLllo],
	"----": [$L/MorseL, $L/MorseLl, $L/MorseLll, $L/MorseLlll],
	".....": [$L/MorseO, $L/MorseOo, $L/MorseOoo, $L/MorseOooo, $L/MorseOoooo],
	"....-": [$L/MorseO, $L/MorseOo, $L/MorseOoo, $L/MorseOooo, $L/MorseOoool],
	"...--": [$L/MorseO, $L/MorseOo, $L/MorseOoo, $L/MorseOool, $L/MorseOooll],
	"..---": [$L/MorseO, $L/MorseOo, $L/MorseOol, $L/MorseOoll, $L/MorseOolll],
	".----": [$L/MorseO, $L/MorseOl, $L/MorseOll, $L/MorseOlll, $L/MorseOllll],
	"-....": [$L/MorseL, $L/MorseLo, $L/MorseLoo, $L/MorseLooo, $L/MorseLoooo],
	"--...": [$L/MorseL, $L/MorseLl, $L/MorseLlo, $L/MorseLloo, $L/MorseLlooo],
	"---..": [$L/MorseL, $L/MorseLl, $L/MorseLll, $L/MorseLllo, $L/MorseLlloo],
	"----.": [$L/MorseL, $L/MorseLl, $L/MorseLll, $L/MorseLlll, $L/MorseLlllo],
	"-----": [$L/MorseL, $L/MorseLl, $L/MorseLll, $L/MorseLlll, $L/MorseLllll]
}

onready var all := []

var _current := ""

func _ready() -> void:
	for i in $L.get_children():
		all.append(i)

func hide_all(_new := "") -> void:
	_current = ""
	for i in all:
		(i as Sprite).visible = false

func show_part(s: String) -> void:
	if _current == s:
		return
	_current = s
	if keys.has(s):
		hide_all()
		for p in keys[s]:
			(p as Sprite).visible = true
