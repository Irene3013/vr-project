extends Node3D

signal countdown_finished

@onready var fail_panel: ColorRect = $SubViewportContainer/SubViewport/FailPanel
@onready var win_panel: ColorRect = $SubViewportContainer/SubViewport/WinPanel
@onready var countdown_label: Label = $SubViewportContainer/SubViewport/CountdownPanel/CountdownLabel
@onready var timer_label: Label = $SubViewportContainer/SubViewport/TimerLabel
@onready var win_time_label: Label = $SubViewportContainer/SubViewport/WinPanel/VBoxContainer/TimeLabel

var elapsed_time: float = 0.0
var timer_running: bool = false

func _ready() -> void:
	_setup_ui()
	fail_panel.visible = false
	win_panel.visible = false

func _process(delta: float) -> void:
	if timer_running:
		elapsed_time += delta
		timer_label.text = _format_time(elapsed_time)

func _format_time(seconds: float) -> String:
	var mins = int(seconds) / 60
	var secs = int(seconds) % 60
	var ms = int((seconds - int(seconds)) * 100)
	return "%02d:%02d.%02d" % [mins, secs, ms]

func start_countdown() -> void:
	elapsed_time = 0.0
	timer_label.text = "00:00.00"
	for i in [3, 2, 1]:
		countdown_label.text = str(i)
		await get_tree().create_timer(1.0).timeout
	countdown_label.text = "GO!"
	await get_tree().create_timer(0.8).timeout
	countdown_label.text = ""
	timer_running = true
	emit_signal("countdown_finished")


## Muestra YOU FAILED, respawnea inmediatamente, luego fade out
func show_fail(respawn_callable: Callable, duration: float = 1.0) -> void:
	timer_running = false
	fail_panel.modulate.a = 1.0
	fail_panel.visible = true
	
	respawn_callable.call()
	
	await get_tree().create_timer(duration).timeout
	
	var tween = create_tween()
	tween.tween_property(fail_panel, "modulate:a", 0.0, 0.5)
	await tween.finished
	
	fail_panel.visible = false
	fail_panel.modulate.a = 1.0
	timer_running = true

func show_win() -> void:
	timer_running = false
	win_time_label.text = timer_label.text
	win_panel.modulate.a = 0.0
	win_panel.visible = true
	timer_label.visible = false
	# Fade in
	var tween = create_tween()
	tween.tween_property(win_panel, "modulate:a", 1.0, 0.5)

func resume_timer() -> void:
	timer_running = true
	
# Setup HUD
func _setup_ui() -> void:
	# FailPanel - pantalla completa
	fail_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	fail_panel.color = Color(0, 0, 0, 0.85)
	fail_panel.visible = false

	# VBoxContainer dentro de FailPanel - centrado
	var fail_vbox = fail_panel.get_node("VBoxContainer")
	fail_vbox.set_anchors_preset(Control.PRESET_CENTER)
	fail_vbox.add_theme_constant_override("separation", 20)
	fail_vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	fail_vbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	# WinPanel - pantalla completa
	win_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	win_panel.color = Color(0, 0, 0, 0.9)
	win_panel.visible = false

	# VBoxContainer dentro de WinPanel - centrado
	var win_vbox = win_panel.get_node("VBoxContainer")
	win_vbox.set_anchors_preset(Control.PRESET_CENTER)
	win_vbox.add_theme_constant_override("separation", 20)
	win_vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	win_vbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	# CountdownPanel - pantalla completa
	var countdown_panel = $SubViewportContainer/SubViewport/CountdownPanel
	countdown_panel.set_anchors_preset(Control.PRESET_FULL_RECT)

	# CountdownLabel - centrado
	countdown_label.set_anchors_preset(Control.PRESET_CENTER)
	countdown_label.add_theme_font_size_override("font_size", 200)
	countdown_label.add_theme_color_override("font_color", Color.WHITE)
	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# TimerLabel - esquina superior derecha
	timer_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	timer_label.add_theme_font_size_override("font_size", 100)
	timer_label.add_theme_color_override("font_color", Color.WHITE)
	timer_label.add_theme_constant_override("outline_size", 4)
	timer_label.add_theme_color_override("font_outline_color", Color.BLACK)
	timer_label.offset_left = -500
	timer_label.offset_top = 10
	
	# FailLabel - centrado
	var fail_label = fail_panel.get_node("VBoxContainer/FailLabel")
	fail_label.add_theme_font_size_override("font_size", 140)
	
	# WinLabel - centrado
	var win_label = win_panel.get_node("VBoxContainer/WinLabel")
	win_label.add_theme_font_size_override("font_size", 140)
	
	var time_win_label = win_panel.get_node("VBoxContainer/TimeLabel")
	time_win_label.add_theme_font_size_override("font_size", 100)

	# Add initial texts on labels
	fail_panel.get_node("VBoxContainer/FailLabel").text = "YOU FAILED"
	win_panel.get_node("VBoxContainer/WinLabel").text = "YOU WIN!"
	win_panel.get_node("VBoxContainer/TimeLabel").text = "00:00.00"
	timer_label.text = "00:00.00"
	countdown_label.text = ""
