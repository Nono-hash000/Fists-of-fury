class_name StartScreen
extends Control

@onready var options_screen: OptionsScreen = $OptionsScreen
@onready var difficulty_screen: DifficultyScreen = $DifficultyScreen
@onready var menu_container: VBoxContainer = $MenuContainer

const WORLD_SCENE_PATH := "res://world.tscn"
const MODE_SELECTION_SCENE_PATH := "res://scenes/ui/mode_selection_screen.tscn"

var activables: Array[ActivableControl] = []
var current_selection_index := 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	options_screen.visible = false
	difficulty_screen.visible = false
	_setup_menu_buttons()
	if has_node("/root/MusicPlayer"):
		MusicPlayer.play(MusicManager.Music.MENU)
	refresh()

func _setup_menu_buttons() -> void:
	var start_button = menu_container.get_node("StartButton")
	var difficulty_button = menu_container.get_node("DifficultyButton")
	var options_button = menu_container.get_node("OptionsButton")
	var quit_button = menu_container.get_node("QuitButton")
	
	activables = [start_button, difficulty_button, options_button, quit_button]
	
	start_button.press.connect(func():
		get_tree().change_scene_to_file(MODE_SELECTION_SCENE_PATH)
	)
	
	difficulty_button.press.connect(func():
		menu_container.visible = false
		await get_tree().process_frame
		difficulty_screen.visible = true
		difficulty_screen.set_process(true)
	)
	
	options_button.press.connect(func():
		menu_container.visible = false
		options_screen.visible = true
		options_screen.set_process(true)
	)
	
	quit_button.press.connect(func():
		get_tree().quit()
	)
	
	options_screen.exit.connect(func():
		options_screen.visible = false
		menu_container.visible = true
		refresh()
	)
	
	difficulty_screen.exit.connect(func():
		difficulty_screen.visible = false
		await get_tree().process_frame
		menu_container.visible = true
		refresh()
	)

func refresh() -> void:
	for i in range(activables.size()):
		activables[i].set_activable(current_selection_index == i)

func _process(_delta: float) -> void:
	if not menu_container.visible:
		return
	
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
