extends Spatial

# get_tree().call_group("sound", "play_sound", "gun")
const SOUNDS := {
	"gun": preload("res://Assets/Sound/Gunshot.ogg"),
	"cannon": preload("res://Assets/Sound/Cannonfire.ogg"),
	"smash": preload("res://Assets/Sound/Crash.ogg"),
	"splash": preload("res://Assets/Sound/Splash.ogg")
}

onready var banks := [$AudioStreamPlayer, $AudioStreamPlayer2, $AudioStreamPlayer3, $AudioStreamPlayer4, $AudioStreamPlayer5]
onready var morse_stream: AudioStreamPlayer = $MorseStreamPlayer
var idx := 0

func play_sound(key: String) -> void:
	if !SOUNDS.has(key):
		return
	var bank: AudioStreamPlayer = banks[idx]
	bank.play()
	idx += 1
	if idx >= banks.size():
		idx = 0
	bank.stream = SOUNDS[key]
	bank.play()

func start_morse() -> void:
	morse_stream.play()

func stop_morse() -> void:
	morse_stream.stop()
