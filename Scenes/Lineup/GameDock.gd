extends GameBase

const PHOTOS := {
	"Siarland": preload("res://Assets/Lineup/SiarlandPhoto.png"),
	"Inguing": preload("res://Assets/Lineup/InguingPhoto.png"),
	"Sipoam": preload("res://Assets/Lineup/SipoamPhoto.png"),
	"Mastong": preload("res://Assets/Lineup/MastongPhoto.png"),
	"Xunhuinam": preload("res://Assets/Lineup/XunhuinamPhoto.png"),
	"Masomai": preload("res://Assets/Lineup/MasomaiPhoto.png")
}
onready var _photo_slots := [$Photo1, $Photo2, $Photo3]
onready var _lineup: Lineup = $"%Lineup"

var _current_lineup := []
var _suspect := ""
var _current_guess := ""
var _guess_now := false

func _ready() -> void:
	input_matters = true
	_current_guess = ""
	var potential_lineup := PHOTOS.keys()
	randomize()
	potential_lineup.shuffle()
	_current_lineup = potential_lineup.slice(0, 2)
	_suspect = _current_lineup[0]
	_current_lineup.shuffle()
	_lineup.character = _suspect
	_lineup.anim_walk()
	for i in 3:
		var s := Sprite.new()
		s.texture = PHOTOS[_current_lineup[i]]
		(_photo_slots[i] as Node2D).add_child(s)

func _on_letter_sent(letter: String) -> void:
	if letter == "5":
		var guess := ""
		for i in _current_lineup:
			var name: String = (i as String).to_upper()
			var similarity := _current_guess.similarity(name)
			if similarity >= 0.5:
				GameData.typing_score += similarity
				guess = i
				break
		if guess == _suspect: # guessing the right person
			GameData.story_score += 10
			GameData.milestones.append("FOUND_SPY")
		elif guess != "": # sentencing an innocent person to death
			GameData.story_score -= 5
			GameData.milestones.append("INNOCENT_KILL")
		else:
			GameData.milestones.append("NO_SPY_KILL")
		emit_signal("choice_made", guess)
	else:
		_current_guess += letter

