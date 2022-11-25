tool
class_name CoverArea
extends Area

export(float) var distance := 4.0 setget _on_distance_change
export(float) var offset := -0.5 setget _on_offset_change

onready var safety_rod_a: MeshInstance = $SafetyRod
onready var safety_rod_b: MeshInstance = $SafetyRod2

func _on_distance_change(v: float) -> void:
	distance = v
	if safety_rod_a == null:
		safety_rod_a = $SafetyRod
	if safety_rod_b == null:
		safety_rod_b = $SafetyRod2
	safety_rod_a.transform.origin.z = -v / 2.0
	safety_rod_b.transform.origin.z = v / 2.0

func _on_offset_change(v: float) -> void:
	offset = v
	if safety_rod_a == null:
		safety_rod_a = $SafetyRod
	if safety_rod_b == null:
		safety_rod_b = $SafetyRod2
	safety_rod_a.transform.origin.x = offset
	safety_rod_b.transform.origin.x = offset

func get_closest_safety_rod_position(pos: Vector3, dir: Vector3) -> Vector3:
	pos = pos + dir * 10.0
	if safety_rod_a.global_transform.origin.distance_to(pos) <= safety_rod_b.global_transform.origin.distance_to(pos):
		return safety_rod_a.global_transform.origin
	else:
		return safety_rod_b.global_transform.origin
