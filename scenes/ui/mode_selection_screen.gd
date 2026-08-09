class_name  ModeSelectionScreen
extends Control

@onready var btn_stages: LabelPicker = $VBoxContainer/BtnStages
@onready var btn_endless: LabelPicker = $VBoxContainer/BtnEndless

@onready var activables: Array[ActivableControl] = [btn_stages, btn_endless]
var current_selection_index := 0

func _ready() -> void:
	btn_stages.press.connect(on_stages_pressed)
	btn_endless.press.connect(on_endless_pressed)
	refresh()

func on_stages_pressed() -> void:
	if has_node("/root/SoundPlayer"):
		SoundPlayer.play(SoundManager.Sound.CLICK)
	get_tree().change_scene_to_file("res://world.tscn")

func on_endless_pressed() -> void:
	if has_node("/root/SoundPlayer"):
		SoundPlayer.play(SoundManager.Sound.CLICK)
	get_tree().change_scene_to_file("res://endless_world.tscn")

func refresh() -> void:
	for i in range(activables.size()):
		activables[i].set_activable(current_selection_index == i)

func _process(_delta: float) -> void:
	handle_input()

func handle_input() -> void:
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
