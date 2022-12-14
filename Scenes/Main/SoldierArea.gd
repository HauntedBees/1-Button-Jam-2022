class_name SoldierArea
extends Sprite

signal caught()

enum SOLDIER_STATE { PASSIVE, AWARE, PEEKING, FOUND }

const SOUND_MIN_THRESHOLDS := [7.0, 10.0, 8.0, 5.0]
const SOUND_MAX_THRESHOLDS := [13.0, 15.0, 12.0, 8.0]
onready var soldiers := [$Soldier1, $Soldier2, $Soldier3, $Soldier4]
onready var look_soldier: AnimatedSprite = $SoldierAlert
var _current_soldier := 0
var _soldier_state = SOLDIER_STATE.PASSIVE

var _sound_amount := 0.0
var _last_sound_time := 0.0
var _peek_sound_count := 0.0
var _shift_time := 0.0

func _ready() -> void:
	randomize()
	_start_troops()

func reset_troops() -> void:
	_sound_amount = 0.0
	_last_sound_time = 0.0
	_peek_sound_count = 0.0
	_shift_time = 0.0
	_start_troops()

func _start_troops() -> void:
	_shift_time = 10.0 + randf() * 20.0
	look_soldier.visible = false
	for i in soldiers:
		i.visible = false
	_current_soldier = randi() % soldiers.size()
	if !GameData.active_troops:
		return
	_get_soldier().visible = true

func _on_MorseParser_press() -> void:
	if !GameData.active_troops:
		return
	_sound_amount += 1.25
	if _soldier_state == SOLDIER_STATE.PEEKING:
		_peek_sound_count += 1.0
	_set_sound()

func _on_MorseParser_hold(delta: float) -> void:
	if !GameData.active_troops:
		return
	_sound_amount += 1.25 * delta
	if _soldier_state == SOLDIER_STATE.PEEKING:
		_peek_sound_count += delta
	_set_sound()

func _process(delta: float) -> void:
	if !GameData.active_troops:
		return
	var current_soldier := _get_soldier()
	_last_sound_time -= delta
	if _last_sound_time <= 0:
		_sound_amount = 0
	else:
		_sound_amount = max(0, _sound_amount - delta)
	
	if _soldier_state == SOLDIER_STATE.PEEKING && _peek_sound_count > 3:
		GameData.active_troops = false
		look_soldier.visible = false
		emit_signal("caught")
		return
	if _sound_amount > _get_max_sound():
		if _soldier_state != SOLDIER_STATE.PEEKING:
			_soldier_state = SOLDIER_STATE.PEEKING
			look_soldier.visible = true
			current_soldier.visible = false
	elif _sound_amount > _get_min_sound():
		if _soldier_state == SOLDIER_STATE.PASSIVE:
			look_soldier.visible = false
			current_soldier.visible = true
			_soldier_state = SOLDIER_STATE.AWARE
			current_soldier.play("Aware")
	elif _soldier_state == SOLDIER_STATE.AWARE || _soldier_state == SOLDIER_STATE.PEEKING:
		look_soldier.visible = false
		current_soldier.visible = true
		_soldier_state = SOLDIER_STATE.PASSIVE
		current_soldier.play("Passive")
		_peek_sound_count = 0
	else:
		_shift_time -= delta
		if _shift_time <= 0:
			_start_troops()

func _set_sound() -> void:
	match _soldier_state:
		SOLDIER_STATE.PEEKING:
			_last_sound_time = 4.0
		SOLDIER_STATE.AWARE:
			_last_sound_time = 2.0
		SOLDIER_STATE.PASSIVE:
			_last_sound_time = 1.0

func _get_soldier() -> AnimatedSprite: return soldiers[_current_soldier]
func _get_min_sound() -> float: return SOUND_MIN_THRESHOLDS[_current_soldier]
func _get_max_sound() -> float: return SOUND_MAX_THRESHOLDS[_current_soldier]
