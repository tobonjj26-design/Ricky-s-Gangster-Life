extends Area2D

# Script del murciélago que lanza Timmy.
# El murciélago aparece estático en frente de Timmy y solo se usa como efecto.

@onready var anim = $AnimatedSprite2D

# Dirección del murciélago: true = izquierda, false = derecha.
@export var facing_left = false

# Ajusta esto según cómo esté dibujado el sprite del murciélago por defecto.
# true = el sprite original mira a la derecha.
const SPRITE_DEFAULT_FACING_RIGHT = true
# Daño que hace el murciélago al impactar.
const BAT_DAMAGE = 10
# Frame en el que el bat puede hacer daño (0 = primer frame, 2 = tercer frame).
const DAMAGE_FRAME = 2
# Delay antes de que el golpe pueda hacerse efectivo.
# Se aumentó para dar al jugador más tiempo de esquivar.
const DAMAGE_ACTIVATION_DELAY = 0.9
# Tiempo extra que el bat dura después de finalizar la animación.
# Se usa adicionalmente para mantenerlo visible tras el Swing.
const BAT_LIFETIME_AFTER_SWING = 1.5

var overlapping_bodies = []
var damage_done = false
var damage_enabled = false

func _ready():
	# Se ejecuta cuando aparece el murciélago.
	update_sprite_direction()
	anim.play("Swing")
	anim.connect("animation_finished", Callable(self, "_on_animation_finished"))
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	await get_tree().create_timer(DAMAGE_ACTIVATION_DELAY).timeout
	damage_enabled = true

func update_sprite_direction():
	# Ajusta el flip del sprite de acuerdo a la dirección real.
	var sprite_should_face_left = facing_left
	anim.flip_h = sprite_should_face_left if SPRITE_DEFAULT_FACING_RIGHT else not sprite_should_face_left

func _on_body_entered(body):
	# Guarda los cuerpos que están dentro del área del bat.
	if body.name != "Timmy":
		overlapping_bodies.append(body)

func _on_body_exited(body):
	# Quita los cuerpos que ya no están en el área del bat.
	overlapping_bodies.erase(body)

func _process(delta):
	if damage_done or not damage_enabled:
		return
	if anim.animation == "Swing" and anim.frame == DAMAGE_FRAME and overlapping_bodies.size() > 0:
		for body in overlapping_bodies:
			if body.has_method("take_damage") and body.name != "Timmy":
				body.take_damage(BAT_DAMAGE)
				print("Bat golpeó a ", body.name, " por ", BAT_DAMAGE, " de daño")
				damage_done = true
				queue_free()
				return

func _on_animation_finished():
	# Después de terminar el Swing, espera un tiempo y desaparece.
	if anim.animation == "Swing":
		await get_tree().create_timer(BAT_LIFETIME_AFTER_SWING).timeout
		queue_free()
