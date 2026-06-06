class_name OptionsScreen
extends Control

@onready var music_volume: ActivableControl = $BackGround/MarginContainer/VBoxContainer/MusicVolume
@onready var sound_volume: ActivableControl = $BackGround/MarginContainer/VBoxContainer/SoundVolume
@onready var shake_toggle: ActivableControl = $BackGround/MarginContainer/VBoxContainer/ShakeToggle
@onready var return_button: ActivableControl = $BackGround/MarginContainer/VBoxContainer/ReturnButton
@onready var activables : Array[ActivableControl] = [music_volume, sound_volume, shake_toggle, return_button]

var current_selection_index := 0

func _ready() -> void:
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
	if Input.is_action_just_pressed("ui_up"):
		current_selection_index = clampi(current_selection_index - 1, 0, activables.size() - 1)
		refresh()
