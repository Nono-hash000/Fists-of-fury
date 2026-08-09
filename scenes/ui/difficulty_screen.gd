class_name DifficultyScreen 
extends Control
signal exit

@onready var easy_button: LabelPicker = $BackGround/MarginContainer/VBoxContainer/EasyButton
@onready var normal_button: LabelPicker = $BackGround/MarginContainer/VBoxContainer/NormalButton
@onready var hard_button: LabelPicker = $BackGround/MarginContainer/VBoxContainer/HardButton
@onready var return_button: LabelPicker = $BackGround/MarginContainer/VBoxContainer/ReturnButton

@onready var activables : Array[ActivableControl] = [easy_button, normal_button, hard_button, return_button]
var current_selection_index := 0

func _ready() -> void:
	easy_button.press.connect(func(): _set_difficulty_and_exit(OptionsManager.Difficulty.EASY))
	normal_button.press.connect(func(): _set_difficulty_and_exit(OptionsManager.Difficulty.NORMAL))
	hard_button.press.connect(func(): _set_difficulty_and_exit(OptionsManager.Difficulty.HARD))
	return_button.press.connect(func(): exit.emit())
	refresh()

func _set_difficulty_and_exit(level: OptionsManager.Difficulty) -> void:
	OptionsManager.set_difficulty(level)
	SaveManager.save_options()
	if has_node("/root/SoundPlayer"):
		SoundPlayer.play(SoundManager.Sound.HIT1)
	exit.emit()

func refresh() -> void:
	for i in range(0, activables.size()):
		activables[i].set_activable(current_selection_index == i)
		easy_button.label.text = "[ EASY ]" if OptionsManager.current_difficulty == OptionsManager.Difficulty.EASY else "EASY"
		normal_button.label.text = "[ NORMAL ]" if OptionsManager.current_difficulty == OptionsManager.Difficulty.NORMAL else "NORMAL"
		hard_button.label.text = "[ HARD ]" if OptionsManager.current_difficulty == OptionsManager.Difficulty.HARD else "HARD"

func _process(_delta: float) -> void:
	if not is_visible_in_tree(): return
	handle_input()

func handle_input()-> void:
	if Input.is_action_just_pressed("ui_down"):
		current_selection_index = clampi(current_selection_index + 1, 0, activables.size() - 1)
		refresh()
		if has_node("/root/SoundPlayer"):
			SoundPlayer.play(SoundManager.Sound.CLICK)
	if Input.is_action_just_pressed("ui_up"):
		current_selection_index = clampi(current_selection_index - 1, 0, activables.size() - 1)
		refresh()
		if has_node("/root/SoundPlayer"):
			SoundPlayer.play(SoundManager.Sound.CLICK)
