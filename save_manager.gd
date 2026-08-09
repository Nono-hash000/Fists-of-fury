extends Node

const SAVE_PATH := "user://savegame.cfg"

const SECTION_OPTIONS := "options"
const SECTION_PROGRESS := "progress"

func _ready() -> void:
	load_options()

func has_save_file() -> bool: 
	return FileAccess.file_exists(SAVE_PATH)

func save_options() -> void:
	var config := _load_config()
	config.set_value(SECTION_OPTIONS, "music_volume", OptionsManager.music_volume)
	config.set_value(SECTION_OPTIONS, "sfx_volume", OptionsManager.sfx_volume)
	config.set_value(SECTION_OPTIONS, "is_screenshake_enabled", OptionsManager.is_screenshake_enabled)
	config.set_value(SECTION_OPTIONS, "difficulty", OptionsManager.current_difficulty)
	config.save(SAVE_PATH)

func load_options() -> void:
	var config := _load_config()
	OptionsManager.set_music_volume(config.get_value(SECTION_OPTIONS, "music_volume", OptionsManager.music_volume))
	OptionsManager.set_sfx_volume(config.get_value(SECTION_OPTIONS, "sfx_volume", OptionsManager.sfx_volume))
	OptionsManager.set_screenshake(config.get_value(SECTION_OPTIONS, "is_screenshake_enabled", OptionsManager.is_screenshake_enabled))
	OptionsManager.set_difficulty(config.get_value(SECTION_OPTIONS, "difficulty", OptionsManager.Difficulty.NORMAL))

func save_high_score(score: int) -> void:
	var config := _load_config()
	var current_high : int = config.get_value(SECTION_PROGRESS, "high_score", 0)
	if score > current_high:
		config.set_value(SECTION_PROGRESS, "high_score", score)
		config.save(SAVE_PATH)

func get_high_score() -> int:
	var config := _load_config()
	return config.get_value(SECTION_PROGRESS, "high_score", 0)

func _load_config() -> ConfigFile:
	var config := ConfigFile.new()
	config.load(SAVE_PATH)
	return config
