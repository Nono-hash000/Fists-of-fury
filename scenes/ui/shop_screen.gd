class_name ShopScreen
extends Control

var player: Player
var score_indicator: ScoreIndicator

const FOOD_COST := 250
const GUN_COST := 500
const ARMOR_BASE_COST := 750
const ALLY_COST := 25000

@onready var stats_label: Label = $BackGround/MarginContainer/VBoxContainer/StatsLabel
@onready var armor_btn: RangePicker = $BackGround/MarginContainer/VBoxContainer/ArmorBtn
@onready var food_btn: LabelPicker = $BackGround/MarginContainer/VBoxContainer/FoodBtn
@onready var gun_btn: LabelPicker = $BackGround/MarginContainer/VBoxContainer/GunBtn
@onready var ally_btn: LabelPicker = $BackGround/MarginContainer/VBoxContainer/AllyBtn
@onready var close_btn: LabelPicker = $BackGround/MarginContainer/VBoxContainer/CloseBtn

var activables: Array[ActivableControl] = []
var current_selection_index := 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	activables = [armor_btn, food_btn, gun_btn, ally_btn, close_btn]
	
	armor_btn.min_value = 0
	armor_btn.max_value = 5
	
	if is_instance_valid(player):
		armor_btn.set_value(player.armor_level)
	
	armor_btn.value_change.connect(_on_armor_value_changed)
	food_btn.press.connect(_on_food_pressed)
	gun_btn.press.connect(_on_gun_pressed)
	ally_btn.press.connect(_on_ally_pressed)
	close_btn.press.connect(func(): queue_free())
	
	refresh_ui()

func _process(_delta: float) -> void:
	if not is_visible_in_tree():
		return
	handle_input()

func handle_input()-> void:
	if Input.is_action_just_pressed("ui_down"):
		current_selection_index = clampi(current_selection_index + 1, 0, activables.size() - 1)
		refresh_ui()
		if has_node("/root/SoundPlayer"):
			SoundPlayer.play(SoundManager.Sound.CLICK)
	
	if Input.is_action_just_pressed("ui_up"):
		current_selection_index = clampi(current_selection_index - 1, 0, activables.size() - 1)
		refresh_ui()
		if has_node("/root/SoundPlayer"):
			SoundPlayer.play(SoundManager.Sound.CLICK)

func refresh_ui() -> void:
	for i in range(activables.size()):
		activables[i].set_activable(current_selection_index == i)
	
	if not is_instance_valid(player) or not is_instance_valid(score_indicator):
		return
	
	var score = StageManager.score
	stats_label.text = "SCORE: %d | ARMOR: %d" % [score, player.armor_level]
	
	var armor_cost = get_armor_cost()
	if player.armor_level >= 5:
		armor_btn.label.text = "ARMOR: MAXED"
	else:
		armor_btn.label.text = "ARMOR (" + str(armor_cost) + ")"
	
	food_btn.label.text = "FOOD (" + str(FOOD_COST) + ")"
	if score < FOOD_COST or player.current_health >= player.max_health:
		food_btn.modulate = Color(0.35, 0.35, 0.35)
	else:
		food_btn.modulate = Color.WHITE
	
	gun_btn.label.text = "GUN (" + str(GUN_COST) + ")"
	if score < GUN_COST or player.has_gun:
		food_btn.modulate = Color(0.35, 0.35, 0.35)
	else:
		food_btn.modulate = Color.WHITE
	
	if player.companion_cooldown_ms <= 2000:
		ally_btn.label.text = "ALLY: MAXED"
		ally_btn.modulate = Color(0.35, 0.35, 0.35)
	else:
		ally_btn.label.text = "ALLY (" + str(ALLY_COST) +  ")"
		if score < ALLY_COST:
			ally_btn.modulate = Color(0.35, 0.35, 0.35)
		else:
			ally_btn.modulate = Color.WHITE
	
	close_btn.label.text = "CLOSE"

func get_armor_cost() -> int:
	return ARMOR_BASE_COST * (player.armor_level + 1)

func _on_armor_value_changed(new_value: int) -> void:
	if new_value == player.armor_level:
		return
	
	if new_value > player.armor_level:
		var cost = get_armor_cost()
		if score_indicator.real_score >= cost and player.armor_level < 5:
			score_indicator.add_points(-cost)
			player.upgrade_armor()
			if has_node("/root/SoundPlayer"):
				SoundPlayer.play(SoundManager.Sound.GOGOGO)
	armor_btn.set_value(player.armor_level)
	refresh_ui()

func _on_food_pressed() -> void:
	if StageManager.score >= FOOD_COST and player.current_health < player.max_health:
		score_indicator.add_points(FOOD_COST)
		player.set_health(player.max_health)
		if has_node("/root/SoundPlayer"):
			SoundPlayer.play(SoundManager.Sound.GOGOGO)
		refresh_ui()
	
func _on_gun_pressed() -> void:
	if StageManager.score >= GUN_COST and not player.has_gun:
		score_indicator.add_points(-GUN_COST)
		player.has_gun = true
		player.ammo_left = player.max_ammo_per_gun
		DamageManager.weapon_changed.emit(player.has_knife, player.ammo_left, player.has_gun)
		if has_node("/root/SoundPlayer"):
			SoundPlayer.play(SoundManager.Sound.SWOOSH)
		refresh_ui()

func _on_ally_pressed() -> void:
	if StageManager.score >= ALLY_COST and player.companion_cooldown_ms > 2000:
		score_indicator.add_combo(-ALLY_COST)
		player.upgrade_ally_cooldown()
		if has_node("/root/SoundPlayer"):
			SoundPlayer.play(SoundManager.Sound.SWOOSH)
		refresh_ui()
