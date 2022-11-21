extends Sprite

onready var soldiers := [$Soldier1]
var _current_soldier := 0
var _soldier_aware = false

func _ready() -> void:
	for i in soldiers:
		i.visible = false
	if GameData.active_troops:
		_current_soldier = 0
		soldiers[_current_soldier].visible = true
