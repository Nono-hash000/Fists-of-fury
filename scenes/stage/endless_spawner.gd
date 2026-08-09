class_name EndlessSpawner
extends Node

const ENEMY_MAP := {
	Character.Type.PUNK: preload("res://scenes/characters/basic_enemy.tscn"),
	Character.Type.GOON: preload("res://scenes/characters/goon_enemy.tscn"),
	Character.Type.THUG: preload("res://scenes/characters/thug_enemy.tscn"),
	Character.Type.BOUNCER: preload("res://scenes/characters/igor_boss.tscn"),
}

var spawn_timer := 0.0
var last_boss_kill_threshold := 0
var active_enemies := 0
var time_survived := 0
var cycle_index := 0
var food_timer := 15.0
var current_level := 1
var next_level_kills := 10
var enemy_cycle := [Character.Type.PUNK, Character.Type.THUG, Character.Type.GOON]

@onready var actors_container = get_parent().get_node("ActorsContainer")
@onready var ui: UI = $"../UI"

func _ready() -> void:
	EntityManager.death_enemy.connect(on_enemy_death.bind())

func _process(delta: float) -> void:
	spawn_timer -= delta
	@warning_ignore("narrowing_conversion")
	time_survived += delta
	if StageManager.kills >= last_boss_kill_threshold + 50:
		spawn_boss()
		last_boss_kill_threshold += 50
	
	if spawn_timer <= 0:
		var current_speed = max(1.5, 3.0 - (time_survived / 60.0))
		spawn_timer = randf_range(current_speed, current_speed + 1.0)
		spawn_wave()
		
	food_timer -= delta
	if food_timer <= 0:
		food_timer = randf_range(20.0, 35.0)
		spawn_food()

func spawn_wave() -> void:
	if active_enemies > 6:
		return
	var min_spawns = clampi(1 + int(time_survived / 60.0), 1, 3)
	var max_spawns = clampi(2 + int(time_survived/ 40.0), 2 ,6)
	var num_to_spawn =randi_range(min_spawns, max_spawns)
	
	var camera = get_viewport().get_camera_2d()
	var distance_travelled = max(0, camera.position.x)
	var weapon_chance = min(0.75, distance_travelled / 4000.0)
	
	for i in range(num_to_spawn):
		var chosen_type = enemy_cycle[cycle_index]
		cycle_index = (cycle_index + 1) % enemy_cycle.size()
		spawn_enemy(chosen_type, weapon_chance)

func spawn_enemy(type: Character.Type, weapon_chance: float) -> void:
	var enemy = ENEMY_MAP[type].instantiate()
	enemy.has_knife = false
	enemy.has_gun = false
	var camera = get_viewport().get_camera_2d()
	var screen_width = get_viewport().get_visible_rect().size.x
	var spawn_x = camera.position.x + (screen_width / 2.0) + 20
	if randf() > 0.8:
		spawn_x = camera.position.x - (screen_width / 2.0) - 20
	enemy.global_position = Vector2(spawn_x, randf_range(40, 60))
	enemy.player = actors_container.player
	
	var health_multipler = 1.0 + (current_level - 1) * 0.5
	enemy.max_health = int(enemy.max_health * health_multipler)
	enemy.damage = enemy.damage + (current_level - 1)
	
	if randf() < weapon_chance:
		if randf() > 0.5:
			enemy.has_knife = true
		else:
			enemy.has_gun = true
	actors_container.add_child(enemy)
	active_enemies += 1

func spawn_boss()-> void:
	var boss = ENEMY_MAP[Character.Type.BOUNCER].instantiate()
	var camera = get_viewport().get_camera_2d()
	var screen_width = get_viewport().get_visible_rect().size.x
	boss.global_position = Vector2(camera.position.x + (screen_width /2.0) + 30, 60)
	boss.player = actors_container.player
	actors_container.add_child(boss)
	active_enemies += 1

func spawn_food() -> void:
	var item_type = Collectible.Type.FOOD
	
	if randf() < 0.15:
		item_type = Collectible.Type.SUPER_FOOD
	
	var camera = get_viewport().get_camera_2d()
	var screen_width = camera.get_viewport_rect().size.x
	var drop_x = camera.position.x + randf_range(-screen_width / 2.0 + 20, screen_width / 2.0 - 20)
	var drop_y = randf_range(40, 60)
	var drop_position = Vector2(drop_x, drop_y)
	
	EntityManager.spawn_collectible.emit(item_type, Collectible.State.FALL, drop_position, Vector2.ZERO, 150.0, false)

func on_enemy_death(_enemy: Character) -> void:
	active_enemies -= 1
	if StageManager.kills >= next_level_kills:
		current_level += 1
		next_level_kills += 10 + (current_level * 5)
		if ui != null and ui.level_label != null:
			ui.level_label.text = "LVL " + str(current_level)
		var player = actors_container.player
		if player != null:
			player.max_health += 5
			player.damage += 1
			player.damage_power += 2
			player.damage_gunshot += 2
			player.set_health(player.max_health)
			SoundPlayer.play(SoundManager.Sound.GOGOGO)
			var tween = create_tween()
			tween.tween_property(player.character_sprite, "modulate", Color(0.2, 1.0, 0.2), 0.15)
			tween.tween_property(player.character_sprite, "modulate", Color.WHITE, 0.15)
			tween.set_loops(3)
