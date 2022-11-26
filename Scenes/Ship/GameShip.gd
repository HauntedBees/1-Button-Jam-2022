extends GameBase

const HIT_MARKER: PackedScene = preload("res://Scenes/Ship/HitMarker.tscn")
const X_AXIS := ["A", "B", "C", "D", "E"]
const Y_AXIS := ["1", "2", "3", "4", "5"]
const VALID_INPUTS := ["A", "B", "C", "D", "E", "1", "2", "3", "4", "5"]
const GRID_OFFSET := Vector2(20.0, 14.0)
const GRID_SIZE := 42.0

onready var ship_scene: ShipScene = $"%ShipScene"
onready var target_grid: Control = $"%TargetInfo"
onready var our_grid: Control = $"%OurInfo"
onready var enemy_timer: Timer = $"%EnemyTimer"

var _already_guessed := []
var _target_coords := []
var _current_command := ""
var _player_coords := [Vector2(1, 4), Vector2(2, 4)]
var _enemy_options := []
var _game_over := false

func _ready() -> void:
	input_matters = true
	randomize()
	for x in 5:
		for y in 5:
			_enemy_options.append(Vector2(x, y))
	var pos1 := Vector2(randi() % 5, randi() % 5)
	var dir_x := 1 if randf() < 0.5 else 0
	var dir_y := 0 if dir_x == 1 else 1
	if dir_x == 1:
		if pos1.x == 4: # 4 2 3
			dir_x = -1
		elif pos1.x == 3: # 2 3 4
			pos1.x = 2
	elif dir_y == 1:
		if pos1.y == 4:
			dir_y = -1
		elif pos1.y == 3:
			pos1.y = 2
	_target_coords.append(pos1)
	var pos2 := Vector2(pos1.x + dir_x, pos1.y + dir_y)
	_target_coords.append(pos2)
	var pos3 := Vector2(pos1.x + 2 * dir_x, pos1.y + 2 * dir_y)
	_target_coords.append(pos3)
	print(_target_coords)

func _on_letter_sent(s: String) -> void:
	if VALID_INPUTS.find(s) < 0 || _game_over:
		return
	_current_command += s
	if _current_command.length() >= 2:
		_guess(_current_command)
		_current_command = ""

func _guess(s: String) -> void:
	if s.length() != 2:
		return
	var c := Vector2(X_AXIS.find(s[0]), Y_AXIS.find(s[1]))
	emit_signal("add_space")
	if c.x < 0 || c.y < 0 || _already_guessed.find(c) >= 0:
		return
	get_tree().call_group("sound", "play_sound", "cannon")
	_already_guessed.append(c)
	var marker: AnimatedSprite = HIT_MARKER.instance()
	if _target_coords.find(c) < 0:
		marker.animation = "Miss"
		get_tree().call_group("sound", "play_sound", "splash")
		marker.frame = randi() % 10
		ship_scene.fire_player_cannon(false)
	else:
		marker.animation = "Hit"
		get_tree().call_group("sound", "play_sound", "smash")
		marker.frame = randi() % 5
		_target_coords.erase(c)
		ship_scene.fire_player_cannon(true)
	marker.position = GRID_OFFSET + c * GRID_SIZE
	target_grid.add_child(marker)
	if _target_coords.size() == 0:
		_game_over = true
		input_matters = false
		ship_scene.sink_them()
		GameData.story_score += 20
		GameData.milestones.append("SOS_VICTORY")
		yield(get_tree().create_timer(4.0), "timeout")
		emit_signal("choice_made", "won")

func _on_EnemyTimer_timeout() -> void:
	if _game_over:
		return
	var idx := randi() % _enemy_options.size()
	var pos: Vector2 = _enemy_options[idx]
	_enemy_options.remove(idx)
	var marker: AnimatedSprite = HIT_MARKER.instance()
	get_tree().call_group("sound", "play_sound", "cannon")
	if _player_coords.find(pos) < 0:
		marker.animation = "Miss"
		get_tree().call_group("sound", "play_sound", "splash")
		marker.frame = randi() % 10
		ship_scene.fire_enemy_cannon(false)
	else:
		get_tree().call_group("sound", "play_sound", "smash")
		marker.animation = "Hit"
		marker.frame = randi() % 5
		ship_scene.fire_enemy_cannon(true)
		_player_coords.erase(pos)
	marker.position = GRID_OFFSET + pos * GRID_SIZE
	our_grid.add_child(marker)
	if _player_coords.size() == 0:
		_game_over = true
		input_matters = false
		ship_scene.sink_me()
		GameData.milestones.append("SOS_DEFEAT")
		yield(get_tree().create_timer(4.0), "timeout")
		emit_signal("choice_made", "lost")
	else:
		enemy_timer.start(2.0 + randf() * 10.0)
