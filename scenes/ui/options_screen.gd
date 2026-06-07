class_name OptionsScreen
extends Control

signal exit

@onready var music_volume: RangePicker = $BackGround/MarginContainer/VBoxContainer/MusicVolume
@onready var sound_volume: RangePicker = $BackGround/MarginContainer/VBoxContainer/SoundVolume
@onready var shake_toggle: TogglePicker = $BackGround/MarginContainer/VBoxContainer/ShakeToggle
@onready var return_button: LabelPicker = $BackGround/MarginContainer/VBoxContainer/ReturnButton
@onready var activables : Array[ActivableControl] = [music_volume, sound_volume, shake_toggle, return_button]

var current_selection_index := 0

func _ready() -> void:
	music_volume.set_value(OptionsManager.music_volume)
	sound_volume.set_value(OptionsManager.sfx_volume)
	shake_toggle.set_value(OptionsManager.is_screenshake_enabled as int)
	music_volume.value_change.connect(on_music_volume_change.bind())
	sound_volume.value_change.connect(on_sfx_volume_change.bind())
	shake_toggle.value_change.connect(on_shake_value_change.bind())
	return_button.press.connect(on_return_pressed.bind())
	refresh()

func refresh() -> void:
	for i in range(0, activables.size()):
		activables[i].set_activable(current_selection_index == i)

func _process(_delta: float) -> void:
	handle_input()

func handle_input() -> void:
	if Input.is_action_just_pressed("ui_down"):
		current_selection_index = clampi(current_selection_index + 1, 0, activables.size() - 1)
		refresh()
		SoundPlayer.play(SoundManager.Sound.CLICK)
	if Input.is_action_just_pressed("ui_up"):
		current_selection_index = clampi(current_selection_index - 1, 0, activables.size() - 1)
		refresh()
		SoundPlayer.play(SoundManager.Sound.CLICK)

func on_music_volume_change(value: int) -> void:
	OptionsManager.set_music_volume(value)

func on_sfx_volume_change(value: int) -> void:
	OptionsManager.set_sfx_volume(value)
	SoundPlayer.play(SoundManager.Sound.HIT1)

func on_shake_value_change(value: int) -> void:
	OptionsManager.set_screenshake(value == 1)

func on_return_pressed() -> void:
	exit.emit()
