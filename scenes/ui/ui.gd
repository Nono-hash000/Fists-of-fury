class_name UI
extends CanvasLayer

const OPTIONS_SCREEN_PREFAB := preload("res://scenes/ui/options_screen.tscn")

const DEATH_SCREEN_PREFAB := preload("res://scenes/ui/death_screen.tscn")

var game_over_scene := preload("res://scenes/ui/game_over_screen.tscn")

@onready var combo_indicator : ComboIndicator = $UIContainer/ComboIndicator
@onready var enemy_avatar : TextureRect = $UIContainer/EnemyAvatar
@onready var enemy_healthbar : Healthbar = $UIContainer/EnemyHealthbar
@onready var go_indicator : FlickeringTextureRect = $UIContainer/GoIndicator
@onready var player_healthbar : Healthbar = $UIContainer/PlayerHealthbar
@onready var score_indicator : ScoreIndicator = $UIContainer/ScoreIndicator
@onready var stage_transition: StageTransition = $UIContainer/StageTransition
@onready var bullet_counter : BulletCounter = $UIContainer/BulletCounter
@onready var player_health_label: Label = $UIContainer/PlayerHealthLabel
@onready var stage_label: Label = $UIContainer/StageLabel
@onready var level_label: Label = $UIContainer/LevelLabel

@export var duration_healthbar_visible : int

var death_screen : DeathScreen = null
var game_over_screen : GameOverScreen = null
var options_screen : OptionsScreen = null
var time_start_healthbar_visible := Time.get_ticks_msec()
var lives := 3

const avatar_map : Dictionary = {
	Character.Type.GOON: preload("res://assets/art/ui/avatars/avatar-goon.png"),
	Character.Type.PUNK: preload("res://assets/art/ui/avatars/avatar-punk.png"),
	Character.Type.THUG: preload("res://assets/art/ui/avatars/avatar-thug.png"),
	Character.Type.BOUNCER: preload("res://assets/art/ui/avatars/avatar-boss.png"),
}

func _init() -> void:
	DamageManager.health_change.connect(on_character_health_change.bind())
	StageManager.checkpoint_complete.connect(on_checkpoint_complete.bind())
	StageManager.stage_complete.connect(on_stage_complete.bind())
	DamageManager.weapon_changed.connect(func(has_knife, ammo, has_gun): bullet_counter.on_weapon_changed(has_knife, ammo, has_gun))
	StageManager.stage_started.connect(on_stage_started.bind())

func _ready() -> void:
	enemy_avatar.visible = false
	enemy_healthbar.visible = false
	combo_indicator.combo_reset.connect(on_combo_reset.bind())
	level_label.visible = false
	player_health_label.visible  =false
	player_healthbar.visible = true

func _process(_delta: float) -> void:
	if enemy_healthbar.visible and (Time.get_ticks_msec() - time_start_healthbar_visible > duration_healthbar_visible):
		enemy_avatar.visible = false
		enemy_healthbar.visible = false
	handle_input()

func handle_input() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if options_screen == null:
			options_screen = OPTIONS_SCREEN_PREFAB.instantiate()
			options_screen.exit.connect(unpause)
			add_child(options_screen)
			get_tree().paused = true
		else:
			unpause()

func unpause() -> void:
	options_screen.queue_free()
	get_tree().paused = false

func on_combo_reset(points: int) -> void:
	score_indicator.add_combo(points)

func on_character_health_change(type: Character.Type, current_health: int, max_health: int) -> void:
	if type == Character.Type.PLAYER:
		player_healthbar.refresh(current_health, max_health)
		player_health_label.text = "%d/%d" % [current_health, max_health]
		if current_health == 0 and death_screen == null:
			lives -= 1
			death_screen = DEATH_SCREEN_PREFAB.instantiate()
			death_screen.game_over.connect(on_game_over.bind())
			add_child(death_screen)
			if death_screen.has_method("set_lives"):
				death_screen.set_lives(lives)
	else:
		time_start_healthbar_visible = Time.get_ticks_msec()
		enemy_avatar.texture = avatar_map[type]
		enemy_healthbar.refresh(current_health, max_health)
		enemy_avatar.visible = true
		enemy_healthbar.visible = true

func on_game_over() -> void:
	if game_over_screen == null:
		game_over_screen = game_over_scene.instantiate()
		var final_score = score_indicator.traditional_score if score_indicator.is_endless_mode else score_indicator.real_score
		game_over_screen.set_score(final_score)
		if score_indicator.is_endless_mode:
			var viewers_label = game_over_screen.get_node_or_null("Background/MarginContainer/VBoxContainer/HBoxContainer/Label")
			if viewers_label:
				viewers_label.text = "SCORE :"
		add_child(game_over_screen)

func on_checkpoint_complete(_checkpoint: Checkpoint) -> void:
	go_indicator.start_flickering()

func on_stage_complete() -> void:
	stage_transition.start_transition()

func on_stage_started(stage_num: int) -> void:
	show_stage_label("STAGE %d" % stage_num)

func show_stage_label(text_to_show: String) -> void:
	stage_label.text = text_to_show
	stage_label.modulate.a = 1.0
	stage_label.show()
	
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_property(stage_label, "modulate:a", 0.0, 0.5)
	
	tween.tween_callback(stage_label.hide)
