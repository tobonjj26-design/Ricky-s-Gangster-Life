extends CharacterBody2D

# Timmy es un enemigo que detecta a Ricky y lanza un bate cuando está cerca.

# Nodo de animación que controla las imágenes de Timmy.
@onready var anim = $AnimatedSprite2D
# Área de detección (no necesaria para lógica principal, solo para depuración).
@onready var detection_area = $DetectionArea

# Estado del enemigo
var player_nearby = false  # true cuando Ricky está dentro de la distancia de ataque.
var can_attack = true      # true cuando Timmy puede iniciar un nuevo ataque.
var health = 15            # Vida de Timmy.

# Escena del murciélago que Timmy lanza.
const BAT_SCENE = preload("res://Scene/Bat.tscn")
# Ajusta esto según cómo esté dibujado el sprite de Timmy por defecto.
# true = el sprite original mira a la derecha.
# false = el sprite original mira a la izquierda.
const SPRITE_DEFAULT_FACING_RIGHT = false
# Distancia máxima a la que Timmy intentará atacar a Ricky.
const ATTACK_DISTANCE = 120
# Tiempo de espera entre ataques en segundos.
const ATTACK_COOLDOWN = 2.0
# Distancia horizontal a la que aparece el murciélago respecto a Ricky.
const BAT_OFFSET_X = 24
# Desplazamiento vertical del murciélago para alinear el bat con Ricky.
const BAT_OFFSET_Y = 0

func _ready():
	# Se ejecuta una vez al inicio del juego.
	print("Timmy listo")
	anim.play("idle")
	player_nearby = false

func _physics_process(delta):
	# Esto se ejecuta cada frame mientras el juego corre.
	var player = get_node_or_null("/root/Game/Ricky")
	if player:
		# Usa la posición del nodo principal de Timmy para detectar mejor a Ricky.
		var timmy_pos = global_position
		var dx = player.global_position.x - timmy_pos.x
		var face_right = dx > 0

		# Ajusta el sprite de Timmy para que mire hacia Ricky.
		# Si el sprite original mira a la izquierda, flip_h debe ser true solo cuando Ricky está a la derecha.
		anim.flip_h = face_right if not SPRITE_DEFAULT_FACING_RIGHT else not face_right

		# Si Ricky está dentro de ATTACK_DISTANCE, Timmy puede atacar.
		player_nearby = player.global_position.distance_to(timmy_pos) <= ATTACK_DISTANCE
	else:
		player_nearby = false

	if player_nearby and can_attack and anim.animation != "attack":
		# Inicia la animación de ataque si puede atacar.
		can_attack = false
		anim.play("attack")

func _on_animated_sprite_2d_animation_finished():
	# Se ejecuta cuando termina cualquier animación de AnimatedSprite2D.
	print("animacion terminó: ", anim.animation)
	if anim.animation == "attack":
		# Cuando termina el ataque, busca posición para usar el bate, lo crea tras 1s y vuelve a idle.
		await spawn_bat()
		anim.play("idle")
		await get_tree().create_timer(ATTACK_COOLDOWN).timeout
		can_attack = true

func get_player_spawn_position(player):
	# Usa una posición de referencia de Ricky para que el bat aparezca en frente del jugador.
	var gun_hitbox = player.get_node_or_null("Gun Hitbox")
	if gun_hitbox:
		return gun_hitbox.global_position
	var target = player.get_node_or_null("AnimatedSprite2D")
	if target:
		return target.global_position
	var hitbox = player.get_node_or_null("Hitbox")
	if hitbox:
		return hitbox.global_position
	return player.global_position

func spawn_bat():
	# Calcula una posición para usar el bate, espera 1 segundo y luego crea el bate allí.
	print("Timmy buscando posición para usar el bate")
	var player = get_node_or_null("/root/Game/Ricky")
	var facing_left = false
	var spawn_position = anim.global_position
	if player:
		facing_left = player.global_position.x < global_position.x
		var direction = -1 if facing_left else 1
		spawn_position = get_player_spawn_position(player)
		spawn_position += Vector2(BAT_OFFSET_X * direction, BAT_OFFSET_Y)
	else:
		var direction = -1 if anim.flip_h else 1
		spawn_position = spawn_position + Vector2(BAT_OFFSET_X * direction, BAT_OFFSET_Y)

	# Espera 0.3 segundos antes de crear y activar el bate (la animación del bate se iniciará al entrar al árbol de escenas).
	await get_tree().create_timer(0.3).timeout
	print("spawneando bate en ", spawn_position)
	var bat = BAT_SCENE.instantiate()
	bat.global_position = spawn_position
	# Compensa el offset interno del prefab del bate para que aparezca en la posición correcta.
	if bat.has_node("AnimatedSprite2D"):
		bat.global_position += -bat.get_node("AnimatedSprite2D").position
	bat.facing_left = facing_left
	get_parent().add_child(bat)

func _on_detection_area_body_entered(body):
	# Aquí solo mostramos un mensaje cuando algo entra en el área.
	print("entró al area: ", body.name)
	if body.name == "Ricky":
		print("Ricky detectado")

func _on_detection_area_body_exited(body):
	# Aquí solo mostramos un mensaje cuando algo sale del área.
	if body.name == "Ricky":
		print("Ricky salió del área")

func take_damage(amount):
	# Recibe daño y muere si se queda sin vida.
	health -= amount
	print("Vida de Timmy: ", health)
	if health <= 0:
		die()

func die():
	print("Timmy murió")
	queue_free()
