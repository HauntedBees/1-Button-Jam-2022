class_name Bunker
extends Spatial

const BULLETHOLE_SCENE: PackedScene = preload("res://Scenes/Bunker/Bullethole.tscn")

signal troop_died()
signal clear_type()
signal troop_won()

var _troop_dead := false
var _shoot_chance := 0.01

onready var bullet_hud: Control = $Bullets
onready var die_anim: AnimationPlayer = $"%DieAnim"
onready var troop: Troop = $"%Troop"
onready var enemy_container: Spatial = $Enemies
onready var starting_points := [
	$StartingPoints/Spot1and2,
	$StartingPoints/Spot1and2,
	$StartingPoints/Spot3,
	$StartingPoints/Spot4,
	$StartingPoints/Spot5
]
var _enemies := []
func _ready() -> void:
	for e in enemy_container.get_children():
		if GameData.difficulty < (e as EnemyTroop).min_difficulty:
			enemy_container.remove_child(e)
			e.queue_free()
		else:
			_enemies.append(e)

func get_troop_info() -> Dictionary:
	return {
		"pos": troop.global_transform.origin,
		"dir": troop.get_direction()
	}

func get_enemy_info() -> Array:
	var es := []
	for ee in _enemies:
		var e: EnemyTroop = ee
		es.append({
			"pos": e.global_transform.origin,
			"dir": e.direction,
			"dead": !e.is_alive()
		})
	return es

func set_troop_pos(idx: int) -> void:
	var starting_point: Spatial = starting_points[idx]
	troop.global_transform.origin = starting_point.global_transform.origin
	troop.set_initial_rotation(starting_point.rotation_degrees.y)

func get_letter(letter: String) -> void:
	if _troop_dead:
		return
	match letter:
		"U":
			troop.reverse()
			emit_signal("clear_type")
		"G":
			troop.speed_up()
			emit_signal("clear_type")
		"S":
			troop.slow_down()
			emit_signal("clear_type")
		_:
			troop.next_instruction = letter

func _on_Troop_died() -> void:
	die_anim.play("YouHaveDied")
	_troop_dead = true
	emit_signal("troop_died")

func _on_EnemyTroop_shoot() -> void:
	get_tree().call_group("sound", "play_sound", "gun")
	if _troop_dead || troop.is_safe():
		return
	elif randf() < _shoot_chance:
		_shoot_chance -= 0.25
		var shot: AnimatedSprite = BULLETHOLE_SCENE.instance()
		shot.frame = randi() % 6
		bullet_hud.add_child(shot)
		bullet_hud.move_child(shot, 0)
		shot.position = Vector2(randi() % int(bullet_hud.rect_size.x), randi() % int(bullet_hud.rect_size.y))
		troop.take_hit()
	else:
		_shoot_chance += randf() * 0.05

func _on_Troop_clear_type() -> void:
	emit_signal("clear_type")

func _on_Troop_won() -> void:
	var alive_troops := 0
	for ee in _enemies:
		var e: EnemyTroop = ee
		if e.is_alive():
			alive_troops += 1
	die_anim.play("Win")
	if alive_troops == 0:
		GameData.story_score += 500
		GameData.milestones.append("ESCAPE_OVERKILL")
	else:
		GameData.milestones.append("ESCAPE_SURVIVED")
	emit_signal("troop_won")
