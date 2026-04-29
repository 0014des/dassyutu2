extends Area3D

var is_pressed = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("presser") or body.is_in_group("player"):
		is_pressed = true
		$MeshInstance3D.position.y = -0.05 # Sink slightly

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("presser") or body.is_in_group("player"):
		# Check if anyone else is still on it
		var overlapping = get_overlapping_bodies()
		var still_on = false
		for b in overlapping:
			if b.is_in_group("presser") or b.is_in_group("player"):
				still_on = true
				break
		if not still_on:
			is_pressed = false
			$MeshInstance3D.position.y = 0.0
