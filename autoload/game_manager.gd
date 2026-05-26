# game_manager.gd
extends Node

const SAVE_PATH := "user://leaderboard.json"

# Informacion sobre jugador
var player_name: String = ""
var is_registered: bool = false

# Variables que controlara el manager
var run_start_time: float = 0.0
var current_deaths: int = 0
var run_active: bool = false

# Lista de partidas ordenadas de menor tiempo a mayor
var leaderboard: Array[RunData] = [] # Cada elemento guarda los datos de una partida

func _ready() -> void:
	load_leaderboard()

# Registro del jugador
func register_player(name: String) -> void:
	player_name = name.strip_edges()
	is_registered = player_name.length() > 0

# Control de la carrera
func start_run() -> void:
	if not is_registered:
		return
	run_start_time = Time.get_unix_time_from_system()
	current_deaths = 0
	run_active = true

func register_death() -> void:
	if run_active:
		current_deaths += 1

func finish_run() -> void:
	if not run_active or not is_registered:
		return
	var elapsed := Time.get_unix_time_from_system() - run_start_time
	var entry := RunData.new()
	entry.player_name = player_name
	entry.time_seconds = elapsed
	entry.deaths = current_deaths
	entry.date = Time.get_date_string_from_system()
	leaderboard.append(entry)
	leaderboard.sort_custom(func(a, b): return a.time_seconds < b.time_seconds)
	save_leaderboard()
	run_active = false

func cancel_run() -> void:
	# Game over o salida sin completar
	run_active = false

# --- Persistencia ---

func save_leaderboard() -> void:
	var data := []
	for entry in leaderboard:
		data.append({
			"player_name": entry.player_name,
			"time_seconds": entry.time_seconds,
			"deaths": entry.deaths,
			"date": entry.date
		})
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

func load_leaderboard() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var raw := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(raw)
	if parsed == null or not parsed is Array:
		return
	leaderboard.clear()
	for item in parsed:
		var entry := RunData.new()
		entry.player_name = item.get("player_name", "")
		entry.time_seconds = item.get("time_seconds", 0.0)
		entry.deaths = item.get("deaths", 0)
		entry.date = item.get("date", "")
		leaderboard.append(entry)
	leaderboard.sort_custom(func(a, b): 
		return a.time_seconds < b.time_seconds)
