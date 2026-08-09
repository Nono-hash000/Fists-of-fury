extends Node

enum Difficulty {EASY, NORMAL, HARD}
var current_difficulty: Difficulty = Difficulty.NORMAL

var is_screenshake_enabled := true
var music_volume := 5
var sfx_volume := 5

func set_difficulty(level: Difficulty) -> void:
	current_difficulty = level

func get_player_multipler() -> float:
	match current_difficulty:
		Difficulty.EASY: return 1.5
		Difficulty.NORMAL: return 1.0
		Difficulty.HARD: return 0.75
	return 1.0

func get_enemy_multipler() -> float:
	match current_difficulty:
		Difficulty.EASY: return 0.75
		Difficulty.NORMAL: return 1.0
		Difficulty.HARD: return 1.5
	return 1.0

func get_score_multipler() -> float:
	match current_difficulty:
		Difficulty.EASY: return 0.5
		Difficulty.NORMAL: return 1.0
		Difficulty.HARD: return 1.5
	return 1.0

func get_penalty_multipler() -> float:
	match current_difficulty:
		Difficulty.EASY: return 0.5
		Difficulty.NORMAL: return 1.0
		Difficulty.HARD: return 2.0
	return 1.0

func get_audience_multipler() -> int:
	match current_difficulty:
		Difficulty.EASY: return 500
		Difficulty.NORMAL: return 1000
		Difficulty.HARD: return 1500
	return 1000

func get_companion_lifespan()-> int:
	match current_difficulty:
		Difficulty.EASY: return 7000
		Difficulty.NORMAL: return 5000
		Difficulty.HARD: return 3000
	return 10000

func get_companion_cooldown() -> int:
	match current_difficulty:
		Difficulty.EASY: return 8000
		Difficulty.NORMAL: return 10000
		Difficulty.HARD: return 15000
	return 10000

func get_super_food_duration() -> float:
	match current_difficulty:
		Difficulty.EASY: return 8.0
		Difficulty.NORMAL: return 5.0
		Difficulty.HARD: return 3.0
	return 5.0

func set_music_volume(value: int) -> void:
	music_volume = value
	AudioServer.set_bus_volume_db(1, linear_to_db(value / 10.0))

func set_sfx_volume(value: int) -> void:
	sfx_volume = value
	AudioServer.set_bus_volume_db(2, linear_to_db(value / 10.0))

func set_screenshake(value: bool) -> void:
	is_screenshake_enabled = value
