extends GameBase

const EPSILON := 0.1
# getting some cyclic dependencies on this bad boy when I say it's a bunker :/
# godot 4.0 plz fix this
onready var bunker = $"%Bunker"
onready var player_cursor: Sprite = $"%PlayerCursor"

func _ready() -> void:
	input_matters = true

func additional_setup(i: int) -> void:
	bunker.set_troop_pos(i - 1)

func _on_letter_sent(s: String) -> void:
	bunker.get_letter(s)

# pos: top left is -50, -50, bottom right is 50, 50 (map is 990 x 1000)
# dir: (0, 0, -1) is north, (-1, 0, 0) is west
func _process(_delta: float) -> void:
	var info: Dictionary = bunker.get_troop_info()
	var pos: Vector3 = info["pos"]
	var map_pos := Vector2((pos.x + 50.0) * 9.9, (pos.z + 50.0) * 10.0)
	player_cursor.position = map_pos
	var dir: Vector3 = info["dir"]
	if dir.x < -EPSILON:
		player_cursor.rotation_degrees = 90.0
	elif dir.x > EPSILON:
		player_cursor.rotation_degrees = -90.0
	elif dir.z > EPSILON:
		player_cursor.rotation_degrees = 0.0
	elif dir.z < -EPSILON:
		player_cursor.rotation_degrees = 180.0
