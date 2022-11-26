class_name Troop
extends Spatial

signal died()
signal clear_type()

enum STATE { WALKING, STOPPED, TURNING, DEAD, COVER, KNEEL }

const TURN_RADS := PI / 2
const EPSILON := 0.1
const TURN_TIME := 0.5
const ALIGN_TIME := 0.2

onready var _huh_anim: AnimationPlayer = $Huh/HuhAnim
onready var _troop_anim: AnimatedSprite3D = $PlayerBody
onready var _collider: Area = $Body/TroopCollider
onready var _tween: Tween = $Tween

var move_speed := 3
var next_instruction := ""

var _curr_state = STATE.WALKING
var _direction := Vector3(0, 0, -1)
var _can_go_left := false
var _can_go_right := false
var _can_go_forward := false

var _curr_safety_area: CoverArea = null
var _last_position := Vector3.ZERO
var _at_turn := false
var _targets := []

var health := 5
var hit_chance := 0.5
var shoot_time := 0.0
var is_shooting := false

func _ready() -> void:
	randomize()
	health = 6 + GameData.difficulty # 1 to 5
	hit_chance = 0.7 - GameData.difficulty * 0.1

func take_hit() -> void:
	health -= 1
	if health <= 0:
		_set_state(STATE.DEAD)

func is_safe() -> bool:
	return _curr_state == STATE.COVER

func _process(delta: float) -> void:
	match _curr_state:
		STATE.STOPPED, STATE.KNEEL, STATE.COVER:
			if !is_shooting && next_instruction != "":
				_handle_input()
			if _curr_state == STATE.STOPPED || is_shooting:
				return
			shoot_time -= delta
			if shoot_time <= 0.0 && _targets.size() > 0:
				is_shooting = true
				shoot_time += 0.2 + randf()
				if _curr_state == STATE.KNEEL:
					_troop_anim.play("SquatShoot")
				else:
					_troop_anim.play("CoverShoot")
				yield(get_tree().create_timer(0.25), "timeout")
				is_shooting = false
				for t in _targets:
					if randf() <= hit_chance:
						var e := t as EnemyTroop
						e.get_shot()
						if !e.is_alive():
							_targets.erase(e)

func _physics_process(delta: float) -> void:
	if _curr_state == STATE.WALKING:
		global_transform.origin += _direction * move_speed * delta

func _set_state(state) -> void:
	if _curr_state == state:
		return
	_troop_anim.flip_h = false
	match state:
		STATE.WALKING:
			_troop_anim.play("Run")
		STATE.STOPPED:
			_troop_anim.play("Look")
		STATE.DEAD:
			_troop_anim.play("Fail")
			move_speed = 0.0
			emit_signal("died")
		STATE.COVER:
			_troop_anim.play("Cover")
		STATE.KNEEL:
			_troop_anim.play("Squat")
	_curr_state = state

func reverse() -> void:
	if move_speed > 0:
		_turn(2)

func get_direction() -> Vector3:
	return _direction

# -x = west, +x = east, -z = north, +z = south
func _on_collider_entered(area: Area) -> void:
	var area_pos := area.global_transform.origin
	area_pos.y = global_transform.origin.y
	if area is AutoTurnArea:
		_handle_autoturn(area, area_pos)
	elif area is TurnArea:
		_handle_turn(area, area_pos)
	elif area is FailZone:
		_set_state(STATE.DEAD)
	elif area is CoverArea:
		_curr_safety_area = area

func _on_collider_exited(area: Area) -> void:
	if area is CoverArea:
		_curr_safety_area = null

func _handle_autoturn(ata: AutoTurnArea, area_pos: Vector3) -> void:
	var turn_dir := 0
	match get_direction_string():
		"N":
			turn_dir = ata.from_south_dir
		"S":
			turn_dir = ata.from_north_dir
		"W":
			turn_dir = ata.from_east_dir
		"E":
			turn_dir = ata.from_west_dir
		_:
			print("well this certainly shouldn't happen! ha ha!")
	if turn_dir != 0:
		_tween.interpolate_property(self, "global_transform:origin", global_transform.origin, area_pos, ALIGN_TIME)
		_tween.start()
		_turn(turn_dir)
	else:
		_set_state(STATE.WALKING)

func _handle_turn(ta: TurnArea, area_pos: Vector3) -> void:
	_tween.interpolate_property(self, "global_transform:origin", global_transform.origin, area_pos, ALIGN_TIME)
	_tween.start()
	match get_direction_string():
		"N":
			_can_go_forward = ta.north
			_can_go_left = ta.west
			_can_go_right = ta.east
		"S":
			_can_go_forward = ta.south
			_can_go_left = ta.east
			_can_go_right = ta.west
		"W":
			_can_go_forward = ta.west
			_can_go_left = ta.south
			_can_go_right = ta.north
		"E":
			_can_go_forward = ta.east
			_can_go_left = ta.north
			_can_go_right = ta.south
		_:
			print("uhhh fuckin arbies")
			_can_go_forward = true
			_can_go_left = true
			_can_go_right = true
	if next_instruction == "":
		_set_state(STATE.STOPPED)
		_at_turn = true
	else:
		_handle_input()

func slow_down() -> void:
	if _curr_safety_area != null:
		_last_position = global_transform.origin
		_set_state(STATE.COVER)
		_troop_anim.flip_h = _flip_for_safety_area()
		var next_pos := _curr_safety_area.get_closest_safety_rod_position(global_transform.origin, _direction)
		next_pos.y = global_transform.origin.y
		_tween.interpolate_property(self, "translation", global_transform.origin, next_pos, TURN_TIME)
		_tween.start()
	else:
		_set_state(STATE.KNEEL)

func _flip_for_safety_area() -> bool:
	if _curr_safety_area == null:
		return false
	match get_direction_string():
		"N": return _curr_safety_area.global_transform.origin.x < _last_position.x
		"E": return _curr_safety_area.global_transform.origin.z > _last_position.z
		"W": return _curr_safety_area.global_transform.origin.z < _last_position.z
		"S": return _curr_safety_area.global_transform.origin.x > _last_position.x
	return false

func speed_up() -> void:
	if _curr_state == STATE.COVER:
		_tween.interpolate_property(self, "translation", global_transform.origin, _last_position, TURN_TIME)
		_tween.start()
		_maybe_resume()
	elif _curr_state == STATE.KNEEL:
		_maybe_resume()
	elif move_speed == 0:
		move_speed = 3
	else:
		move_speed = 6

func _maybe_resume() -> void:
	move_speed = 3
	if _at_turn:
		_set_state(STATE.STOPPED)
	else:
		_set_state(STATE.WALKING)

func get_direction_string() -> String:
	if _direction.z < -EPSILON:
		return "N"
	elif _direction.z > EPSILON:
		return "S"
	elif _direction.x < -EPSILON:
		return "W"
	elif _direction.x > EPSILON:
		return "E"
	else:
		return "?"

func _handle_input() -> void:
	match next_instruction:
		"L":
			if _can_go_left:
				_turn(1)
			else:
				_signal_confusion()
		"R":
			if _can_go_right:
				_turn(-1)
			else:
				_signal_confusion()
		"F":
			if _can_go_forward:
				_set_state(STATE.WALKING)
			else:
				_signal_confusion()
		_:
			_signal_confusion()
	next_instruction = ""
	emit_signal("clear_type")

func _signal_confusion() -> void:
	_huh_anim.play("Huh")

func set_initial_rotation(angle: float) -> void:
	print(int(floor(angle / 90.0)))
	_turn(int(floor(angle / 90.0)), true)

func _turn(rotation_dir: int, force := false) -> void:
	if _curr_state == STATE.TURNING:
		return
	_at_turn = false
	if rotation_dir == 0:
		_set_state(STATE.WALKING)
		return
	next_instruction = ""
	var turn_radians := TURN_RADS * rotation_dir
	_direction = _direction.rotated(Vector3.UP, turn_radians)
	var new_dir := Vector3(0, rotation.y + turn_radians, 0)
	if force:
		rotation = new_dir
		_set_state(STATE.WALKING)
	else:
		_tween.interpolate_property(self, "rotation", rotation, new_dir, TURN_TIME)
		_set_state(STATE.TURNING)
		_tween.start()
		yield(_tween, "tween_completed")
		_set_state(STATE.WALKING)

func _on_ShootRangeArea_area_entered(area: Area) -> void:
	var parent := area.get_parent()
	if parent is EnemyTroop && (parent as EnemyTroop).is_alive():
		_targets.append(parent)

func _on_ShootRangeArea_area_exited(area: Area) -> void:
	var parent := area.get_parent()
	if parent is EnemyTroop:
		_targets.erase(parent)
