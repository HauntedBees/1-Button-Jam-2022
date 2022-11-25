class_name Bunker
extends Spatial

const BULLETHOLE_SCENE: PackedScene = preload("res://Scenes/Bunker/Bullethole.tscn")

signal troop_died()
var _troop_dead := false
var _shoot_chance := 0.01
var health := 5

onready var bullet_hud: Control = $Bullets
onready var die_anim: AnimationPlayer = $"%DieAnim"
onready var troop: Troop = $"%Troop"
onready var starting_points := [
	$StartingPoints/Spot1,
	$StartingPoints/Spot2
]

func _ready() -> void:
	randomize()
	health = 6 + GameData.difficulty

func get_troop_info() -> Dictionary:
	return {
		"pos": troop.global_transform.origin,
		"dir": troop.get_direction()
	}

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
		"G":
			troop.speed_up()
		"S":
			troop.slow_down()
		_:
			troop.next_instruction = letter

func _on_Troop_died() -> void:
	die_anim.play("YouHaveDied")
	_troop_dead = true
	emit_signal("troop_died")

func _on_EnemyTroop_shoot() -> void:
	if _troop_dead || troop.is_safe():
		return
	elif randf() < _shoot_chance:
		_shoot_chance -= 0.25
		var shot: AnimatedSprite = BULLETHOLE_SCENE.instance()
		shot.frame = randi() % 6
		bullet_hud.add_child(shot)
		bullet_hud.move_child(shot, 0)
		shot.position = Vector2(randi() % int(bullet_hud.rect_size.x), randi() % int(bullet_hud.rect_size.y))
		health -= 1
		if health <= 0:
			troop.die()
	else:
		_shoot_chance += randf() * 0.05
