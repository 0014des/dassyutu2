extends StaticBody3D

@onready var rotatable_node = $"../RotatableRoom"
var is_rotating = false

func interact(_player) -> void:
	if is_rotating: return
	is_rotating = true
	GameManager.add_log("部屋が回転する…！")
	
	var tween = create_tween()
	tween.tween_property(rotatable_node, "rotation_degrees:x", rotatable_node.rotation_degrees.x + 90.0, 2.0).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func(): is_rotating = false)
