class_name ComboIndicator
extends Label

signal combo_reset(points: int)

@export var duration_combo_timeout : int

var current_combo := 0
var time_since_register_hit := Time.get_ticks_msec()

@onready var timer_bar: ColorRect = $TimerBar

func _init() -> void:
	ComboManager.register_hit.connect(on_register_hit.bind())

func _ready() -> void:
	refresh()

func on_register_hit() -> void:
	current_combo += 1
	time_since_register_hit = Time.get_ticks_msec()
	refresh()

func _process(_delta: float) -> void:
	if current_combo > 0:
		var elapsed = Time.get_ticks_msec() - time_since_register_hit
		if elapsed > duration_combo_timeout:
			combo_reset.emit(current_combo)
			current_combo = 0
			refresh()
		elif is_instance_valid(timer_bar):
			var time_left_ratio = 1.0 - (float(elapsed) / float(duration_combo_timeout))
			timer_bar.scale.x = max(0.0, time_left_ratio)
	
func refresh() -> void:
	var rank_text := ""
	
	if current_combo >= 15:
		rank_text = " BRUTAL"
	elif current_combo >= 10:
		rank_text = " GREAT"
	elif current_combo >= 5:
		rank_text = " NICE"
	
	text = "x" + str(current_combo) + rank_text
	visible = current_combo > 0
	
	if is_instance_valid(timer_bar):
		timer_bar.visible  =  visible
