extends GameBase

const ENEMY_CURSOR: Texture = preload("res://Assets/Bunker/EnemyArrow.png")

const EPSILON := 0.1
# getting some cyclic dependencies on this bad boy when I say it's a bunker :/
# godot 4.0 plz fix this
onready var bunker = $"%Bunker"
onready var cursor_holder: Control = $Paper1/CursorHolder
onready var player_cursor: Sprite = $"%PlayerCursor"
var enemy_cursors := []

func _ready() -> void:
	input_matters = true
	var enemies: Array = bunker.get_enemy_info()
	for e in enemies:
		var s := Sprite.new()
		s.texture = ENEMY_CURSOR
		cursor_holder.add_child(s)
		_set_cursor(s, e)
		enemy_cursors.append(s)

func additional_setup(i: int) -> void:
	bunker.set_troop_pos(i - 1)

func _on_letter_sent(s: String) -> void:
	bunker.get_letter(s)

# pos: top left is -50, -50, bottom right is 50, 50 (map is 990 x 1000)
# dir: (0, 0, -1) is north, (-1, 0, 0) is west
func _process(_delta: float) -> void:
	_set_cursor(player_cursor, bunker.get_troop_info())
	var enemies: Array = bunker.get_enemy_info()
	for i in enemy_cursors.size():
		_set_cursor(enemy_cursors[i], enemies[i])
		if enemies[i]["dead"]:
			(enemy_cursors[i] as Sprite).modulate = Color(0.3, 0.3, 0.3)
	
func _set_cursor(cursor:Sprite, info: Dictionary) -> void:
	var pos: Vector3 = info["pos"]
	var map_pos := Vector2((pos.x + 50.0) * 9.9, (pos.z + 50.0) * 10.0)
	cursor.position = map_pos
	var dir: Vector3 = info["dir"]
	if dir.x < -EPSILON:
		cursor.rotation_degrees = 90.0
	elif dir.x > EPSILON:
		cursor.rotation_degrees = -90.0
	elif dir.z > EPSILON:
		cursor.rotation_degrees = 0.0
	elif dir.z < -EPSILON:
		cursor.rotation_degrees = 180.0

func _on_Bunker_troop_died() -> void:
	input_matters = false
	print("YYYYOUUU'RE FUKT!")

func _on_Bunker_clear_type() -> void:
	emit_signal("add_space")
