extends Node3D

## Señal emitida cuando el countdown inicial termina y el jugador puede moverse.
signal countdown_finished
## Señal emitida cuando el nivel termina, ya sea por victoria o game over.
signal game_finished

# Paneles
@onready var fail_panel: ColorRect = $SubViewportContainer/SubViewport/UILayer/FailPanel
@onready var end_panel: ColorRect = $SubViewportContainer/SubViewport/UILayer/EndPanel
@onready var light_wave = $SubViewportContainer/SubViewport/UILayer/LightWave

# Labels
@onready var countdown_label: Label = $SubViewportContainer/SubViewport/UILayer/CountdownPanel/CountdownLabel
@onready var timer_label: Label = $SubViewportContainer/SubViewport/UILayer/TimerLabel
@onready var end_time_label: Label = $SubViewportContainer/SubViewport/UILayer/EndPanel/VBoxContainer/TimeLabel
@onready var end_label: Label = $SubViewportContainer/SubViewport/UILayer/EndPanel/VBoxContainer/EndLabel

# Audios
@onready var coundown_sound = $SubViewportContainer/SubViewport/UILayer/CountdownPanel/CountdownAudio
@onready var end_sound = $SubViewportContainer/SubViewport/UILayer/EndPanel/EndAudio
@onready var fail_sound = $SubViewportContainer/SubViewport/UILayer/FailPanel/FailAudio
@onready var game_audio = $SubViewportContainer/SubViewport/GameAudio

# Nodos de los corazones (vidas)
@onready var hearts_container = $SubViewportContainer/SubViewport/UILayer/LivesContainer
@onready var hearts = [
	$SubViewportContainer/SubViewport/UILayer/LivesContainer/Heart1,
	$SubViewportContainer/SubViewport/UILayer/LivesContainer/Heart2,
	$SubViewportContainer/SubViewport/UILayer/LivesContainer/Heart3,
	$SubViewportContainer/SubViewport/UILayer/LivesContainer/Heart4,
	$SubViewportContainer/SubViewport/UILayer/LivesContainer/Heart5,
	$SubViewportContainer/SubViewport/UILayer/LivesContainer/Heart6
]

# Confetis
@onready var confetti_cian = $SubViewportContainer/SubViewport/UILayer/EndPanel/Confetti/Cian
@onready var confetti_magenta = $SubViewportContainer/SubViewport/UILayer/EndPanel/Confetti/Magenta
@onready var confetti_yellow = $SubViewportContainer/SubViewport/UILayer/EndPanel/Confetti/Yellow

const MAX_LIVES := 6
const HEART_FULL = preload("res://assets/splash/pixel-art-heart.png")
const HEART_BROKEN = preload("res://assets/splash/broken-pixel-art-heart.png")
const WIN_AUDIO = preload("res://assets/audio/applause-cheer.ogg")
const LOSE_AUDIO = preload("res://assets/audio/fail-trumpet.ogg")

var elapsed_time: float = 0.0    # Tiempo transcurrido desde el inicio del nivel
var timer_running: bool = false  # Indica si el cronometro esta activo
var current_lives := MAX_LIVES   # Vidas restantes del jugador

## Inicializa los paneles como invisibles al cargar la escena.
func _ready() -> void:
	fail_panel.visible = false
	end_panel.visible = false

## Actualiza el cronometro en cada frame mientras este activo.
func _process(delta: float) -> void:
	if timer_running:
		elapsed_time += delta
		timer_label.text = _format_time(elapsed_time)

## Convierte segundos en formato legible "MM:SS.ms".
func _format_time(seconds: float) -> String:
	var mins = int(seconds) / 60
	var secs = int(seconds) % 60
	var ms = int((seconds - int(seconds)) * 100)
	return "%02d:%02d.%02d" % [mins, secs, ms]

## Actualiza la visualizacion de los corazones segun las vidas restantes.
## Si un corazon pasa de lleno a roto, lanza la animacion de rotura.
func update_lives_display() -> void:
	for i in range(MAX_LIVES):
		if i < current_lives:
			hearts[i].texture = HEART_FULL
			hearts[i].modulate = Color(1, 1, 1, 1)
		else:
			if hearts[i].texture == HEART_FULL:
				# Este corazon acaba de perderse: lanzar animacion de rotura
				_animate_heart_break(hearts[i])
			else:
				hearts[i].texture = HEART_BROKEN
				hearts[i].modulate = Color(0.3, 0.3, 0.3, 1)

## Anima el corazon con un crecimiento y temblor antes de cambiar a la textura rota.
func _animate_heart_break(heart: TextureRect) -> void:
	var tween = create_tween()
	tween.tween_property(heart, "scale", Vector2(1.4, 1.4), 0.15)          # Crece
	tween.tween_property(heart, "position:x", heart.position.x - 8, 0.05)  # Tiembla izquierda
	tween.tween_property(heart, "position:x", heart.position.x + 8, 0.05)  # Tiembla derecha
	tween.tween_property(heart, "position:x", heart.position.x - 8, 0.05)
	tween.tween_property(heart, "position:x", heart.position.x, 0.05)      # Vuelve al centro
	tween.tween_property(heart, "scale", Vector2(1.0, 1.0), 0.1)           # Vuelve a tamaño normal
	tween.tween_callback(func():
		heart.texture = HEART_BROKEN
		heart.modulate = Color(0.3, 0.3, 0.3, 1)
	)

## Muestra la cuenta atras 3-2-1-GO!, reinicia vidas y cronometro,
## y emite countdown_finished cuando el jugador puede empezar a moverse.
func start_countdown() -> void:
	current_lives = MAX_LIVES
	update_lives_display()

	elapsed_time = 0.0
	timer_label.text = "00:00.00"

	coundown_sound.play()
	for i in [3, 2, 1]:
		countdown_label.text = str(i)
		await get_tree().create_timer(1.0).timeout
	countdown_label.text = "GO!"
	await get_tree().create_timer(0.8).timeout
	countdown_label.text = ""
	timer_running = true
	emit_signal("countdown_finished")

	# Breve pausa antes de arrancar la musica del nivel
	await get_tree().create_timer(0.8).timeout
	game_audio.play()

## Muestra brevemente el mensaje "Checkpoint saved" en el CountdownLabel
## con un tamaño de fuente reducido para no interferir visualmente con el timer y las vidas.
func show_sheckpoint_saved() -> void:
	play_checkpoint_effect()

	countdown_label.add_theme_font_size_override("font_size", 100)
	countdown_label.add_theme_color_override("font_outline_color", Color.BLACK)
	countdown_label.add_theme_constant_override("outline_size", 8)
	countdown_label.text = "Checkpoint\nsaved"

	await get_tree().create_timer(0.8).timeout

	countdown_label.text = ""
	countdown_label.remove_theme_font_size_override("font_size")
	countdown_label.remove_theme_color_override("font_outline_color")
	countdown_label.remove_theme_constant_override("outline_size")

## Lanza el efecto de onda de luz del shader de LightWave:
## anima el parametro wave_pos del shader para que la onda recorra
## la pantalla de arriba hacia abajo al activar un checkpoint.
func play_checkpoint_effect():
	var mat = light_wave.material
	mat.set_shader_parameter("wave_pos", -0.2)

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(
		func(v): mat.set_shader_parameter("wave_pos", v),
		1.2,   # posicion inicial (arriba)
		-0.2,  # posicion final (abajo, fuera de pantalla)
		1.2    # duracion en segundos
	)

## Gestiona la perdida de una vida: llama al callable de respawn recibido como parametro,
## actualiza el display de corazones y muestra el panel de fallo con fade out.
## El cronometro se detiene durante la animacion del panel y se reanuda al terminar.
## Si no quedan vidas, llama a show_gameover en lugar de mostrar el panel de fallo.
func show_fail(respawn_callable: Callable, duration: float = 1.0) -> void:
	respawn_callable.call()

	current_lives -= 1
	update_lives_display()

	if current_lives < 1:
		show_gameover()
	else:
		fail_panel.modulate.a = 1.0
		fail_panel.visible = true
		fail_sound.play()
		timer_running = false  # El cronometro se detiene mientras se muestra el panel

		await get_tree().create_timer(duration).timeout

		var tween = create_tween()
		tween.tween_property(fail_panel, "modulate:a", 0.0, 0.5)
		await tween.finished

		fail_panel.visible = false
		fail_panel.modulate.a = 1.0
		timer_running = true  # El cronometro se reanuda tras el fade out

## Activa las tres particulas de confeti del EndPanel.
func play_confetti():
	confetti_cian.emitting = true
	confetti_magenta.emitting = true
	confetti_yellow.emitting = true

## Muestra el panel de victoria con el tiempo final y audio de aplausos.
## Oculta el cronometro y los corazones, y emite game_finished.
func show_win() -> void:
	emit_signal("game_finished")

	timer_running = false
	timer_label.visible = false
	hearts_container.visible = false

	end_time_label.text = timer_label.text
	end_label.text = "YOU WIN!"
	end_panel.modulate.a = 0.0
	end_panel.visible = true

	end_sound.stream = WIN_AUDIO
	end_sound.play()

	var tween = create_tween()
	tween.tween_property(end_panel, "modulate:a", 1.0, 0.5)

	play_confetti()

## Muestra el panel de game over sin tiempo final y con audio de derrota.
## Oculta el cronometro y los corazones, y emite game_finished.
func show_gameover() -> void:
	emit_signal("game_finished")

	timer_running = false
	timer_label.visible = false
	end_time_label.visible = false  # No se muestra el tiempo en game over
	hearts_container.visible = false

	end_label.text = "GAME OVER"
	end_panel.modulate.a = 0.0
	end_panel.visible = true

	end_sound.stream = LOSE_AUDIO
	end_sound.play()

	var tween = create_tween()
	tween.tween_property(end_panel, "modulate:a", 1.0, 0.5)

## Reanuda el cronometro, usado tras un respawn o pausa temporal.
func resume_timer() -> void:
	timer_running = true
