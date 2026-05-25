extends CharacterBody2D

# Controla a Ricky, el personaje que mueve el jugador.

# Velocidad de movimiento horizontal.
var SPEED = 300.0
# Velocidad de salto hacia arriba.
var JUMP_VELOCITY = -400.0
# Vida del jugador.
var health = 30

# Nodo de animación de Ricky.
@onready var anim = $AnimatedSprite2D

func _ready():
	# Se ejecuta al iniciar el personaje.
	print("Ricky listo")

func _physics_process(delta: float) -> void:
	# Aplica gravedad cuando no está en el suelo.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Si pulsa el botón de salto y está en el suelo, salta.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Lee la entrada horizontal (izquierda/derecha).
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		# Reduce la velocidad cuando no se presiona ninguna tecla.
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Cambia la animación según la dirección de movimiento.
	if direction > 0:
		anim.play("walk")
		anim.flip_h = false
	elif direction < 0:
		anim.play("walk")
		anim.flip_h = true
	else:
		anim.play("idle")

func take_damage(amount):
	# Resta vida y comprueba si Ricky muere.
	health -= amount
	print("Vida de Ricky: ", health)
	if health <= 0:
		die()

func die():
	# Elimina a Ricky de la escena.
	print("Ricky murió")
	queue_free()
