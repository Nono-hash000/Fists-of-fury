class_name ScoreIndicator
extends Label

@export var duration_score_update : float
@export var reacts_to_player_revive : bool = true

var displayed_score := 0
var prior_score := 0
var real_score := 0
var traditional_score := 0
var is_endless_mode := false

var time_start_update := Time.get_ticks_msec()
var next_reward_milestone := 0
var reward_step := 2000

func _ready() -> void:
	reward_step = OptionsManager.get_audience_multipler()
	next_reward_milestone = reward_step
	if reacts_to_player_revive:
		DamageManager.player_revive.connect(on_player_revive.bind())
		DamageManager.player_took_damage.connect(on_player_took_damage.bind())
	refresh()

func on_player_took_damage(amount: int) -> void:
	var penalty = amount * 2
	penalty = int(penalty * OptionsManager.get_penalty_multipler())
	add_points(-penalty)

func add_combo(points: int) -> void:
	add_points(int((points * (points + 1)) / 2.0) * 10)

func start_update() -> void:
	prior_score = displayed_score
	time_start_update = Time.get_ticks_msec()
	refresh()

func on_player_revive() -> void:
	add_points(-1000)

func add_points(points: int) -> void:
	var final_points = points
	if points > 0:
		final_points = int(points * OptionsManager.get_score_multipler())
	
	real_score = max(0, real_score + final_points)
	
	if real_score >= next_reward_milestone:
		EntityManager.trigger_audience_drop.emit()
		next_reward_milestone += reward_step
	
	if final_points > 0:
		traditional_score += final_points
	elif final_points < 0:
		traditional_score = max(0, traditional_score + final_points)
	
	StageManager.score = traditional_score if is_endless_mode else real_score
	
	start_update()

func _process(_delta: float) -> void:
	var target_score = traditional_score if is_endless_mode else real_score
	if target_score != displayed_score:
		var progress := (Time.get_ticks_msec() - time_start_update) / duration_score_update
		if progress < 1:
			displayed_score = lerp(prior_score, target_score, progress)
		else:
			displayed_score = target_score
		refresh()

func refresh() -> void:
	text = str(displayed_score)
