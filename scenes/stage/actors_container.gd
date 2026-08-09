extends Node2D

const SHOT_PREFAB := preload("res://scenes/props/shot.tscn")
const SPARK_PREFAB := preload("res://scenes/props/spark.tscn")
const DAMAGE_INDICATOR_PREFAB := preload("res://scenes/ui/damage_indicator.tscn")
const COMPANION_PREFAB := preload("res://scenes/characters/companion.tscn")
const PREFAB_MAP := {
	Collectible.Type.KNIFE: preload("res://scenes/props/knife.tscn"),
	Collectible.Type.GUN: preload("res://scenes/props/gun.tscn"),
	Collectible.Type.FOOD: preload("res://scenes/props/food.tscn"),
	Collectible.Type.SUPER_FOOD: preload("res://scenes/props/super_food.tscn"),
}
const ENEMY_MAP := {
	Character.Type.PUNK: preload("res://scenes/characters/basic_enemy.tscn"),
	Character.Type.GOON: preload("res://scenes/characters/goon_enemy.tscn"),
	Character.Type.THUG: preload("res://scenes/characters/thug_enemy.tscn"),
	Character.Type.BOUNCER: preload("res://scenes/characters/igor_boss.tscn"),
}

@export var player : Player

var doors : Array[Door]

func _init() -> void:
	EntityManager.orphan_actor.connect(on_orphan_actor.bind())
	EntityManager.spawn_collectible.connect(on_spawn_collectible.bind())
	EntityManager.spawn_shot.connect(on_spawn_shot.bind())
	EntityManager.spawn_enemy.connect(on_spawn_enemy.bind())
	EntityManager.spawn_spark.connect(on_spawn_spark.bind())
	DamageManager.player_revive.connect(on_player_revive.bind())
	EntityManager.spawn_damage_indicator.connect(on_spawn_damage_indicator.bind())
	EntityManager.trigger_audience_drop.connect(on_trigger_audience_drop.bind())
	EntityManager.trigger_audience_attack.connect(on_trigger_audience_attack.bind())
	EntityManager.spawn_companion.connect(on_spawn_companion.bind())

func on_spawn_collectible(type: Collectible.Type, initial_state: Collectible.State, collectible_global_position: Vector2, collectible_direction: Vector2, initial_height: float, autodestroy: bool) -> void:
	var collectible : Collectible = PREFAB_MAP[type].instantiate()
	collectible.state = initial_state
	collectible.height = initial_height
	collectible.global_position = collectible_global_position
	collectible.direction = collectible_direction
	collectible.autodestroy = autodestroy
	call_deferred("add_child", collectible)

func on_spawn_shot(gun_root_position: Vector2, distance_traveled: float, height: float):
	var shot : Shot = SHOT_PREFAB.instantiate()
	add_child(shot)
	shot.position = gun_root_position
	shot.initialize(distance_traveled, height)

func on_spawn_enemy(enemy_data: EnemyData) -> void:
	var enemy : Character = ENEMY_MAP[enemy_data.type].instantiate()
	enemy.global_position = enemy_data.global_position
	enemy.player = player
	enemy.height = enemy_data.height
	enemy.state = enemy_data.state
	if enemy_data.door_index > -1:
		enemy.assign_door(doors[enemy_data.door_index])
	add_child(enemy)

func on_spawn_spark(spark_position: Vector2) -> void:
	var spark_instance := SPARK_PREFAB.instantiate()
	spark_instance.position = spark_position
	add_child(spark_instance)

func on_orphan_actor(orphan: Node2D) -> void:
	if orphan is Door:
		doors.append(orphan)
	orphan.reparent(self)

func on_player_revive() -> void:
	for child in get_children():
		if child is Character:
			var character : Character = child as Character
			if character.type != Character.Type.PLAYER:
				character.on_receive_damage(0, Vector2.ZERO, DamageReceiver.HitType.KNOCKDOWN)

func on_spawn_damage_indicator(amount: int, indicator_position: Vector2) -> void:
	var indicator = DAMAGE_INDICATOR_PREFAB.instantiate()
	indicator.amount = amount
	indicator.position = indicator_position
	indicator.z_index = 100
	add_child(indicator)

func on_trigger_audience_drop() -> void:
	if player == null: return
	var item_type = Collectible.Type.FOOD
	var roll = randf()
	if roll < 0.10:
		item_type = Collectible.Type.SUPER_FOOD
	elif roll > 0.55:
		item_type = Collectible.Type.FOOD
	var drop_position = player.global_position + Vector2(randf_range(-40, 40), 0)
	on_spawn_collectible(item_type, Collectible.State.FALL, drop_position, Vector2.ZERO, 150.0, false)

func on_trigger_audience_attack(_target_y_position: float, _target_height:float) -> void:
	var valid_enemies: Array[Character] = []
	for child in get_children():
		if child is Character and child.type != Character.Type.PLAYER and child.current_health > 0:
			valid_enemies.append(child)
	
	if valid_enemies.size() == 0:
		return
	
	var target_enemy = valid_enemies.pick_random()
	
	var tween = create_tween()
	tween.tween_property(target_enemy.character_sprite, "modulate", Color.RED, 0.5)
	tween.tween_property(target_enemy.character_sprite, "modulate", Color.WHITE, 0.15)
	tween.set_loops(3)
	
	await tween.finished
	
	if not is_instance_valid(target_enemy) or target_enemy.current_health <= 0:
		return
	
	var camera := get_viewport().get_camera_2d()
	var screen_width := get_viewport_rect().size.x
	
	var throw_from_left = randf() > 0.5
	var spawn_x = camera.position.x + (screen_width / 2.0) - 20
	var throw_direction := Vector2.RIGHT
	
	if not throw_from_left:
		spawn_x = camera.position.x + (screen_width / 2.0) + 20
		throw_direction = Vector2.LEFT
	
	var spawn_position = Vector2(spawn_x, target_enemy.global_position.y)
	
	on_spawn_collectible(Collectible.Type.KNIFE, Collectible.State.FLY, spawn_position, throw_direction, target_enemy.height + 10.0, true)
	
	if has_node("/root/SoundPlayer"):
		SoundPlayer.play(SoundManager.Sound.SWOOSH)

func on_spawn_companion(spawn_position: Vector2) -> void:
	var companion = COMPANION_PREFAB.instantiate()
	companion.global_position = spawn_position
	add_child(companion)
