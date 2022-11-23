class_name ShipScene
extends Spatial

onready var player_cannon: AnimationPlayer = $"%PlayerCannon"
onready var enemy_cannon: AnimationPlayer = $"%EnemyCannon"
onready var blast: MeshInstance = $"%WaterBlast"
onready var blast_anim: AnimationPlayer = $"%BlastPlayer"
onready var enemy_anim: AnimationPlayer = $"%EnemyAnim"
onready var player_anim: AnimationPlayer = $"%PlayerHurtAnim"
onready var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

func fire_enemy_cannon(hit: bool) -> void:
	enemy_cannon.play("Fire")
	if hit:
		player_anim.play("Hurt")

func fire_player_cannon(hit: bool) -> void:
	player_cannon.play("Fire")
	if hit:
		enemy_cannon.play("Fire")
	else:
		blast.transform.origin.x = rng.randf_range(-30.0, 15.0)
		blast_anim.play("Splash")

func sink_them() -> void:
	enemy_anim.play("Destroy")

func sink_me() -> void:
	player_anim.play("Die")
