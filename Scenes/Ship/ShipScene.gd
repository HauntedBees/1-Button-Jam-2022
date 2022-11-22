extends Spatial

onready var player_cannon: AnimationPlayer = $"%PlayerCannon"
onready var enemy_cannon: AnimationPlayer = $"%EnemyCannon"

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		player_cannon.play("Fire")
	elif event is InputEventKey:
		enemy_cannon.play("Fire")
