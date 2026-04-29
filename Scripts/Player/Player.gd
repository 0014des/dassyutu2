extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera = $Camera3D
@onready var raycast = $Camera3D/RayCast3D
@onready var interact_label = $UI/InteractLabel
@onready var log_label = $UI/LogLabel

var look_sensitivity = 0.002

func _ready() -> void:
	add_to_group("player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if interact_label:
		interact_label.hide()
	if log_label:
		log_label.text = ""

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * look_sensitivity)
		camera.rotate_x(-event.relative.y * look_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	_check_interaction()

func _check_interaction() -> void:
	if not raycast or not interact_label:
		return
	if raycast.is_colliding():
		var target = raycast.get_collider()
		if not target:
			interact_label.hide()
			return
		if target.has_method("interact") or target.is_in_group("interactable"):
			interact_label.show()
			if Input.is_action_just_pressed("interact"):
				if target.has_method("interact"):
					target.interact(self)
		else:
			interact_label.hide()
	else:
		interact_label.hide()

func show_log(message: String) -> void:
	if log_label:
		log_label.text = message
		var timer = get_tree().create_timer(3.0)
		timer.timeout.connect(func(): if log_label: log_label.text = "")
