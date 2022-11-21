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

var _current_lineup := []
var _suspect := ""

func _ready() -> void:
	var potential_lineup := PHOTOS.keys()
	randomize()
	potential_lineup.shuffle()
	_current_lineup = potential_lineup.slice(0, 2)
	_suspect = _current_lineup[0]
	_current_lineup.shuffle()
	print(_suspect)
	for i in 3:
		var s := Sprite.new()
		s.texture = PHOTOS[_current_lineup[i]]
		(_photo_slots[i] as Node2D).add_child(s)

func _on_letter_sent(letter: String) -> void:
	print(letter)
