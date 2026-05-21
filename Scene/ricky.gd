extends CharacterBody2D

var SPEED = 300.0
var JUMP_VELOCITY = -400.0

@onready var anim = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movimiento
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Animaciones
	if direction > 0:
		anim.play("walk")
		anim.flip_h = false  # derecha
	elif direction < 0:
		anim.play("walk")
		anim.flip_h = true   # izquierda
	else:
		anim.play("idle")
