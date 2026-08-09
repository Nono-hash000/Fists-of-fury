class_name GameOverScreen
extends Control

@onready var score_indicator: ScoreIndicator = $Background/MarginContainer/VBoxContainer/HBoxContainer/ScoreIndicator
@onready var kills_label: ScoreIndicator = $Background/MarginContainer/VBoxContainer/HBoxContainer2/KillsLabel
@onready var stage_reached: ScoreIndicator = $Background/MarginContainer/VBoxContainer/HBoxContainer3/StageReached
@onready var time: ScoreIndicator = $Background/MarginContainer/VBoxContainer/HBoxContainer4/TIME

@onready var timer: Timer = $Timer

var total_score := 0

func _ready() -> void:	
	timer.timeout.connect(on_timer_timeout.bind())
	
	if time:
		time.set_process(false)
		time.text = ""

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().paused = false
		StageManager.reset_stats()
		get_tree().reload_current_scene()

func set_score(score: int) -> void:
	total_score = score
	SaveManager.save_high_score(score)

func on_timer_timeout() -> void:
	if score_indicator:
		score_indicator.add_points(total_score)
		
	if kills_label:
		kills_label.add_points(StageManager.kills)
		
	if stage_reached:
		stage_reached.add_points(StageManager.stage_reached)
		
	if time:
		time.text = StageManager.get_time_played_string()
