class_name Compainion
extends  Character

var target_enemy: Character = null
var time_since_last_attack := Time.get_ticks_msec()
var time_spawned := Time.get_ticks_msec()
var lifespan := 0
var is_despawning := false

@export var attack_cooldown := 800
@export var attack_range := 30.0

func _ready() -> void:
	remove_from_group("player")
	add_to_group("companion")
	can_respawn = false
	max_health = 30
	damage = 4
	speed = 35.0
	lifespan = OptionsManager.get_companion_lifespan()
	super._ready()
	anim_attacks = ["punch", "punch_alt", "kick", "roundkick"]
	character_sprite.modulate = Color(0.25, 0.25, 0.25, 1.0)
	knife_sprite.modulate = Color(0.25, 0.25, 0.25, 1.0)
	gun_sprite.modulate = Color(0.25, 0.25, 0.25, 1.0)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if not is_despawning and Time.get_ticks_msec() - time_spawned > lifespan:
		is_despawning = true
		state = State.IDLE
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.5)
		tween.tween_callback(queue_free)

func set_health(health: int, _is_emitting_signal: bool = true) -> void:
	super.set_health(health, false)

func handle_input() -> void:
	if can_move():
		target_enemy = find_closest_enemy()
		
		if target_enemy != null and is_instance_valid(target_enemy) and target_enemy.current_health > 0:
			var distance = global_position.distance_to(target_enemy.global_position)
			
			if distance <= attack_range:
				velocity = Vector2.ZERO
				if can_attack():
					state = State.ATTACK
					time_since_last_attack = Time.get_ticks_msec()
					attack_combo_index = randi() % anim_attacks.size()
					if has_node("/root/SoundPlayer"):
						SoundPlayer.play(SoundManager.Sound.SWOOSH)
			else:
				var direction = global_position.direction_to(target_enemy.global_position)
				velocity = direction * speed
				state = State.WALK
		else:
			var player_node = get_tree().get_first_node_in_group("player")
			if player_node and global_position.distance_to(player_node.global_position) > 40:
				var direction = global_position.direction_to(player_node.global_position)
				velocity = direction * speed
				state = State.WALK
			else:
				velocity = Vector2.ZERO
				state = State.IDLE

func  find_closest_enemy() -> Character:
	var closest: Character = null
	var min_dist = INF
	
	if get_parent() == null:
		return null
	
	for child in get_parent().get_children():
		if child is Character and child != self and child.type != Type.PLAYER:
			if child.current_health > 0:
				var dist = global_position.distance_to(child.global_position)
				if dist < min_dist:
					min_dist = dist
					closest = child
	return closest

func can_attack() -> bool:
	if Time.get_ticks_msec() - time_since_last_attack < attack_cooldown:
		return false
	return super.can_attack()

func set_heading() -> void:
	if target_enemy != null and is_instance_valid(target_enemy):
		if target_enemy.global_position.x > global_position.x:
			heading = Vector2.RIGHT
		else:
			heading = Vector2.LEFT
	elif can_move():
		if velocity.x > 0:
			heading = Vector2.RIGHT
		elif velocity.x < 0:
			heading = Vector2.LEFT
