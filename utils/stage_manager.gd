extends Node

signal checkpoint_start
signal checkpoint_complete(checkpoint: Checkpoint)
signal stage_complete
signal stage_interim
signal stage_started(stage_num: int)

var score := 0
var kills := 0
var stage_reached := 1
var start_time_msec := 0

func _ready() -> void:
	reset_stats()
	
	stage_started.connect(func(stage_num: int): stage_reached = stage_num)
	
	if has_node("/root/EntityManager"):
		EntityManager.death_enemy.connect(on_enemy_death)

func reset_stats() -> void:
	score = 0
	kills = 0
	stage_reached = 1
	start_time_msec = Time.get_ticks_msec()

func on_enemy_death(_enemy: Character) -> void:
	kills += 1

func get_time_played_string() -> String:
	@warning_ignore("integer_division")
	var elapsed_seconds := (Time.get_ticks_msec() - start_time_msec) / 1000
	@warning_ignore("integer_division")
	var mins := elapsed_seconds / 60
	var sec := elapsed_seconds % 60
	return "%02d:%02d" % [mins, sec]
