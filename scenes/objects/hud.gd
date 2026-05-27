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

# Confetti
@onready var confetti_cian = $SubViewportContainer/SubViewport/UILayer/EndPanel/Confetti/Cian
@onready var confetti_magenta = $SubViewportContainer/SubViewport/UILayer/EndPanel/Confetti/Magenta
@onready var confetti_yellow = $SubViewportContainer/SubViewport/UILayer/EndPanel/Confetti/Yellow

# Valores constantes
const MAX_LIVES := 6
const HEART_FULL = preload("res://assets/splash/pixel-art-heart.png")
const HEART_BROKEN = preload("res://assets/splash/broken-pixel-art-heart.png")
const WIN_AUDIO = preload("res://assets/audio/applause-cheer.ogg")
const LOSE_AUDIO = preload("res://assets/audio/fail-trumpet.ogg")

var elapsed_time: float = 0.0		# Tiempo transcurrido desde el inicio del nivel
var timer_running: bool = false		# Indica si el cronometro esta activo
var current_lives := MAX_LIVES				# Vidas restantes del jugador

# Inicializa los paneles como invisibles al cargar la escena.
func _ready() -> void:
	fail_panel.visible = false
	end_panel.visible = false

# Actualiza el cronometro en cada frame mientras este activo.
func _process(delta: float) -> void:
	if timer_running:
		elapsed_time += delta
		timer_label.text = _format_time(elapsed_time)

# Convierte segundos en formato legible "MM:SS.ms".
func _format_time(seconds: float) -> String:
	var mins = int(seconds) / 60
	var secs = int(seconds) % 60
	var ms = int((seconds - int(seconds)) * 100)
	return "%02d:%02d.%02d" % [mins, secs, ms]

# Actualiza la visualizacion de los corazones segun las vidas restantes.
# Si un corazon pasa de lleno a roto, lanza la animacion de rotura.
func update_lives_display() -> void:
	for i in range(MAX_LIVES):
		if i < current_lives:
			hearts[i].texture = HEART_FULL
			hearts[i].modulate = Color(1, 1, 1, 1)
		else:
			if hearts[i].texture == HEART_FULL:
				# Este corazon acaba de perderse, lanzar animacion
				_animate_heart_break(hearts[i])
			else:
				hearts[i].texture = HEART_BROKEN
				hearts[i].modulate = Color(0.3, 0.3, 0.3, 1)

# Anima el corazon con un crecimiento y temblor antes de cambiar a la textura rota.
func _animate_heart_break(heart: TextureRect) -> void:
	var tween = create_tween()
	# 1. Crece
	tween.tween_property(heart, "scale", Vector2(1.4, 1.4), 0.15)
	# 2. Tiembla (izquierda-derecha)
	tween.tween_property(heart, "position:x", heart.position.x - 8, 0.05)
	tween.tween_property(heart, "position:x", heart.position.x + 8, 0.05)
	tween.tween_property(heart, "position:x", heart.position.x - 8, 0.05)
	tween.tween_property(heart, "position:x", heart.position.x, 0.05)
	# 3. Vuelve a tamaño normal y cambia textura
	tween.tween_property(heart, "scale", Vector2(1.0, 1.0), 0.1)
	tween.tween_callback(func():
		heart.texture = HEART_BROKEN
		heart.modulate = Color(0.3, 0.3, 0.3, 1)
	)

# Muestra la cuenta atras 3-2-1-GO!, reinicia vidas y cronometro,
# y emite countdown_finished cuando el jugador puede empezar a moverse.
func start_countdown() -> void:
	# Reiniciar vidas al empezar partida
	current_lives = MAX_LIVES
	update_lives_display()
	
	elapsed_time = 0.0
	timer_label.text = "00:00.00"
	
	# Iniciar Countdown
	coundown_sound.play()
	for i in [3, 2, 1]:
		countdown_label.text = str(i)
		await get_tree().create_timer(1.0).timeout
	countdown_label.text = "GO!"
	await get_tree().create_timer(0.8).timeout
	countdown_label.text = ""
	timer_running = true
	emit_signal("countdown_finished")
	
	# Esperar un poco a que empiece la musica
	await get_tree().create_timer(0.8).timeout
	game_audio.play()
	
# Muestra brevemente el mensaje "Checkpoint saved" en el label del countdown
# usando un tamaño de fuente reducido para no interferir con el countdown principal.
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


func play_checkpoint_effect():
	var mat = light_wave.material
	mat.set_shader_parameter("wave_pos", -0.2)  # empieza abajo

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(
		func(v): mat.set_shader_parameter("wave_pos", v),
		1.2, # empieza
		-0.2, #acaba
		1.2 # duración
	)
# Gestiona la perdida de una vida: respawnea al jugador, actualiza los corazones
# y muestra el panel de fallo con fade out. Si no quedan vidas, llama a show_gameover.
func show_fail(respawn_callable: Callable, duration: float = 1.0) -> void:
	# Respawn
	respawn_callable.call()
	
	# Actualizar contador de vidas
	current_lives -= 1
	update_lives_display()
	print(current_lives)
	
	if current_lives < 1:
		show_gameover() # Si no quedan -> Game Over
	else:
		fail_panel.modulate.a = 1.0
		fail_panel.visible = true
		fail_sound.play()

		await get_tree().create_timer(duration).timeout
		
		var tween = create_tween()
		tween.tween_property(fail_panel, "modulate:a", 0.0, 0.5)
		await tween.finished
		
		fail_panel.visible = false
		fail_panel.modulate.a = 1.0
		timer_running = true

func play_confetti():
	confetti_cian.emitting = true
	confetti_magenta.emitting = true
	confetti_yellow.emitting = true
	
# Muestra el panel de victoria con el tiempo final y audio de aplausos.
# Oculta el cronometro y los corazones, y emite game_finished.
func show_win() -> void:
	# Notificar que el nivel ha acabado
	emit_signal("game_finished")
	
	# Ocular lo que no queremos que se va
	timer_running = false
	timer_label.visible = false
	hearts_container.visible = false
	
	# Ajustar texto de los labels
	end_time_label.text = timer_label.text
	end_label.text = "YOU WIN!"
	end_panel.modulate.a = 0.0
	end_panel.visible = true
	
	# Audio de victoria
	end_sound.stream = WIN_AUDIO
	end_sound.play()
	
	# Animacion para fade in
	var tween = create_tween()
	tween.tween_property(end_panel, "modulate:a", 1.0, 0.5)
	
	# Mostrar confetis de victoria
	play_confetti()

# Muestra el panel de game over sin tiempo final y con audio de derrota.
# Oculta el cronometro y los corazones, y emite game_finished.
func show_gameover() -> void:
	# Notificar que el nivel ha acabado
	emit_signal("game_finished")
	# Ocular lo que no queremos que se va
	timer_running = false
	timer_label.visible = false
	end_time_label.visible = false
	hearts_container.visible = false
	
	# Ajustar texto de los labels
	end_label.text = "GAME OVER"
	end_panel.modulate.a = 0.0
	end_panel.visible = true
	
	# Audio de game over
	end_sound.stream = LOSE_AUDIO
	end_sound.play()
	# Fade in
	var tween = create_tween()
	tween.tween_property(end_panel, "modulate:a", 1.0, 0.5)

# Reanuda el cronometro, usado tras un respawn o pausa temporal.
func resume_timer() -> void:
	timer_running = true
