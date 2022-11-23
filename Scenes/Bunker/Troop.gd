class_name Troop
extends Spatial

enum STATE { WALKING, STOPPED, TURNING, CONFUSED }

const TURN_RADS := PI / 2
const EPSILON := 0.1
const TURN_TIME := 0.5
const ALIGN_TIME := 0.2

onready var _troop_anim: AnimatedSprite3D = $PlayerBody
onready var _collider: Area = $Body/TroopCollider
onready var _tween: Tween = $Tween

var move_speed := 3
var next_instruction = ""

var _curr_state = STATE.WALKING
var _direction := Vector3(0, 0, -1)
var _can_go_left := false
var _can_go_right := false
var _can_go_forward := false

func _physics_process(delta: float) -> void:
	match _curr_state:
		STATE.WALKING:
			global_transform.origin += _direction * move_speed * delta
		STATE.STOPPED, STATE.CONFUSED:
			if next_instruction != "":
				_handle_input()

func _set_state(state) -> void:
	if _curr_state == state:
		return
	match state:
		STATE.WALKING:
			_troop_anim.play("Run")
		STATE.STOPPED, STATE.CONFUSED:
			_troop_anim.play("Look")
	_curr_state = state

func reverse() -> void:
	_turn(2)

func get_direction() -> Vector3:
	return _direction

# -x = west, +x = east, -z = north, +z = south
func _on_collider_entered(area: Area) -> void:
	var area_pos := area.global_transform.origin
	area_pos.y = global_transform.origin.y
	if area is AutoTurnArea:
		var ata := area as AutoTurnArea
		var turn_dir := 0
		match _get_direction_string():
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
	else:
		_tween.interpolate_property(self, "global_transform:origin", global_transform.origin, area_pos, ALIGN_TIME)
		_tween.start()
		var ta := area as TurnArea
		match _get_direction_string():
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
		else:
			_handle_input()

func _get_direction_string() -> String:
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
				_set_state(STATE.CONFUSED)
		"R":
			if _can_go_right:
				_turn(-1)
			else:
				_set_state(STATE.CONFUSED)
		"F":
			if _can_go_forward:
				next_instruction = ""
				_set_state(STATE.WALKING)
			else:
				_set_state(STATE.CONFUSED)
		_:
			_set_state(STATE.CONFUSED)

func set_initial_rotation(angle: float) -> void:
	print(int(floor(angle / 90.0)))
	_turn(int(floor(angle / 90.0)), true)

func _turn(rotation_dir: int, force := false) -> void:
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
