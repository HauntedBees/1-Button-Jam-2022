class_name EnemyTroop
extends Spatial

signal shoot()
enum STATE { WALKING, DEAD, SIGHTED }

export(int) var min_difficulty := 1
export(Array, int) var turn_directions := [] #-1 left #1 right 0 straight
export(NodePath) var player_path: NodePath
export(Vector3) var direction := Vector3(1, 0, 0)
export(bool) var custom_autoturns := false

const TURN_RADS := PI / 2
const EPSILON := 0.1

onready var sprite: AnimatedSprite3D = $Sprite

onready var fov_collider: CollisionShape = $FOV/CollisionShape
onready var fov_mesh: MeshInstance = $FOV/MeshInstance

var _player_mesh#: Troop # love me some got dang cyclical references
var _turn_idx := 0
var _curr_state = STATE.WALKING
var _player_in_view := false

func _ready() -> void:
	_player_mesh = get_node(player_path)

func _process(delta: float) -> void:
	if _curr_state == STATE.DEAD:
		return
	if _player_in_view:
		if _is_looking_at_player():
			sprite.animation = "Shoot"
			_curr_state = STATE.SIGHTED
		else:
			_curr_state = STATE.WALKING
	else:
		_curr_state = STATE.WALKING
	if _curr_state != STATE.WALKING:
		return
	var d := _get_relative_dir()
	match d:
		"F":
			if sprite.animation != "Front":
				sprite.animation = "Front"
				sprite.flip_h = false
		"B":
			if sprite.animation != "Back":
				sprite.animation = "Back"
				sprite.flip_h = false
		"W":
			if sprite.animation != "Side":
				sprite.animation = "Side"
			sprite.flip_h = false
		"E":
			if sprite.animation != "Side":
				sprite.animation = "Side"
			sprite.flip_h = true

func _is_looking_at_player() -> bool:
	return _get_relative_dir() == "F"

func is_alive() -> bool:
	return _curr_state != STATE.DEAD

func get_shot() -> void:
	sprite.animation = "Die"
	_curr_state = STATE.DEAD

# -x = west, +x = east, -z = north, +z = south
# this is absolutely the wrong way to do this but I forgot math and this jam is due in 25 hours so
func _get_relative_dir() -> String:
	var pl_dir: String = _player_mesh.get_direction_string()
	var me_dir := _get_direction_string()
	if pl_dir == "N":
		match me_dir:
			"N": return "B"
			"S": return "F"
			"E": return "E"
			"W": return "W"
	elif pl_dir == "S":
		match me_dir:
			"N": return "F"
			"S": return "B"
			"E": return "W"
			"W": return "E"
	elif pl_dir == "W":
		match me_dir:
			"N": return "E"
			"S": return "W"
			"E": return "F"
			"W": return "B"
	elif pl_dir == "E":
		match me_dir:
			"N": return "W"
			"S": return "E"
			"E": return "B"
			"W": return "F"
	return "?"

func _get_direction_string() -> String:
	if direction.z < -EPSILON:
		return "N"
	elif direction.z > EPSILON:
		return "S"
	elif direction.x < -EPSILON:
		return "W"
	elif direction.x > EPSILON:
		return "E"
	else:
		return "?"

func _physics_process(delta: float) -> void:
	if _curr_state == STATE.WALKING:
		global_transform.origin += direction * 3.0 * delta

func _on_Core_area_entered(area: Area) -> void:
	var area_pos := area.global_transform.origin
	area_pos.y = global_transform.origin.y
	if area is AutoTurnArea:
		if custom_autoturns:
			_handle_turn(area, area_pos)
		else:
			_handle_autoturn(area, area_pos)
	elif area is TurnArea:
		_handle_turn(area, area_pos)

func _handle_autoturn(ata: AutoTurnArea, area_pos: Vector3) -> void:
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
		_turn(turn_dir)

func _handle_turn(ta: TurnArea, area_pos: Vector3) -> void:
	_turn(turn_directions[_turn_idx])
	_turn_idx += 1
	if _turn_idx >= turn_directions.size():
		_turn_idx = 0

func _turn(rotation_dir: int) -> void:
	var turn_radians := TURN_RADS * rotation_dir
	direction = direction.rotated(Vector3.UP, turn_radians)

func _is_player(area: Area) -> bool:
	return area.get_parent().get_parent() == _player_mesh

func _on_FOV_area_entered(area: Area) -> void:
	if _is_player(area):
		_player_in_view = true

func _on_FOV_area_exited(area: Area) -> void:
	if _is_player(area):
		_player_in_view = false

func _on_ShootTimer_timeout() -> void:
	if _curr_state != STATE.SIGHTED:
		return
	emit_signal("shoot")
