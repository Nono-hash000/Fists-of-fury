class_name Player
extends Character

const REVIVE_HEIGHT := 80

@export var max_duration_between_successful_hits : int

@onready var enemy_slots : Array = $EnemySlots.get_children()

var time_since_last_successful_attack := Time.get_ticks_msec()
var hit_flash_tween: Tween = null
var consecutive_hits_taken = 0
var companion_cooldown_ms := 10000
var time_since_last_summon := -10000
var is_super_strength_active := false
var super_strength_timer := 0.0
var armor_level := 0

var armor_colors := [
	Color(1.0, 1.0, 1.0),
	Color(0.2, 0.8, 0.2),
	Color(0.2, 0.4, 0.9),
	Color(0.7, 0.2, 0.8),
	Color(0.9, 0.6, 0.1),
	Color(0.2, 0.2, 0.2)
]

func _ready() -> void:
	super._ready()
	companion_cooldown_ms = OptionsManager.get_companion_cooldown()
	anim_attacks = ["punch", "punch_alt", "kick", "roundkick"]
	DamageManager.player_revive.connect(on_player_revive.bind())
	DamageManager.weapon_changed.emit(has_knife, ammo_left, has_gun)
	ComboManager.register_hit.connect(on_successful_hit.bind())

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	process_time_between_combos()
	if is_super_strength_active:
		super_strength_timer -= delta
		if super_strength_timer <= 0:
			is_super_strength_active = false
			@warning_ignore("integer_division")
			damage = int(damage / 2)
			character_sprite.modulate = Color.WHITE

func process_time_between_combos() -> void:
	if Time.get_ticks_msec() - time_since_last_successful_attack > max_duration_between_successful_hits:
		attack_combo_index = 0

func on_player_revive() -> void:
	current_health = max_health
	DamageManager.health_change.emit(type, current_health, max_health)
	state = State.JUMP
	height = REVIVE_HEIGHT

func handle_input() -> void:
	if can_move():
		var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		velocity = direction * speed
		if Input.is_physical_key_pressed(KEY_V):
			if Time.get_ticks_msec() - time_since_last_summon >= companion_cooldown_ms:
				time_since_last_summon = Time.get_ticks_msec()
				EntityManager.spawn_companion.emit(global_position + Vector2(-20, 0))
				EntityManager.companion_cooldown_started.emit(companion_cooldown_ms)
				
				if has_node("/root/SoundPlayer"):
					SoundPlayer.play(SoundManager.Sound.GOGOGO)
	if can_attack() and Input.is_action_just_pressed("attack"):
		velocity = Vector2.ZERO
		perform_attack_action()
	if can_jump() and Input.is_action_just_pressed("jump"):
		state = State.TAKEOFF
		attack_combo_index = 0
	if can_jumpkick() and Input.is_action_just_pressed("attack"):
		state = State.JUMPKICK
		SoundPlayer.play(SoundManager.Sound.SWOOSH)

func perform_attack_action() -> void:
	if has_knife:
		state = State.THROW
		return
	if has_gun:
		if ammo_left > 0:
			shoot_gun()
			ammo_left -= 1
			DamageManager.weapon_changed.emit(has_knife, ammo_left, has_gun)
		else:
			state = State.THROW
		return
	if can_pickup_collectible():
		state = State.PICKUP
		return
	perform_melee_combo_hit()

func perform_melee_combo_hit() -> void:
	state = State.ATTACK
	SoundPlayer.play(SoundManager.Sound.SWOOSH)
	if is_last_hit_successful:
		time_since_last_successful_attack = Time.get_ticks_msec()
		attack_combo_index = (attack_combo_index + 1) % anim_attacks.size()
		is_last_hit_successful = false
	else:
		attack_combo_index = 0

func set_heading() -> void:
	if can_move():
		if velocity.x > 0:
			heading = Vector2.RIGHT
		elif velocity.x < 0:
			heading = Vector2.LEFT
		
func reserve_slot(enemy: BasicEnemy) -> EnemySlot:
	var available_slots := enemy_slots.filter(
		func(slot): return slot.is_free()
	)
	if available_slots.size() == 0:
		return null
	available_slots.sort_custom(
		func(a: EnemySlot, b: EnemySlot):
			var dist_a := (enemy.global_position - a.global_position).length()
			var dist_b := (enemy.global_position - b.global_position).length()
			return dist_a < dist_b
	)
	available_slots[0].occupy(enemy)
	return available_slots[0]

func free_slot(enemy: BasicEnemy) -> void:
	var target_slots := enemy_slots.filter(
		func(slot: EnemySlot): return slot.occupant == enemy
	)
	if target_slots.size() == 1:
		target_slots[0].free_up()

func on_throw_complete() -> void:
	super.on_throw_complete()
	DamageManager.weapon_changed.emit(has_knife, ammo_left, has_gun)

func on_pickup_complete() -> void:
	super.on_pickup_complete()
	DamageManager.weapon_changed.emit(has_knife, ammo_left, has_gun)

func on_receive_damage(amount: int, direction: Vector2, hit_type: DamageReceiver.HitType) -> void:
	var final_amount = amount
	
	if amount > 0 and armor_level > 0:
		var reduction_multipler = float(armor_level) * 0.15
		final_amount = maxi(1 , int(float(amount) * (1.0 - reduction_multipler)))

	super.on_receive_damage(final_amount, direction, hit_type)
	
	if final_amount > 0:
		DamageManager.player_took_damage.emit(final_amount)
		consecutive_hits_taken += 1
		if consecutive_hits_taken >= 3:
			EntityManager.trigger_audience_attack.emit(global_position.y, height)
			consecutive_hits_taken = 0
	
	DamageManager.weapon_changed.emit(has_knife, ammo_left, has_gun)
	trigger_hit_flash()

func trigger_hit_flash() -> void:
	if hit_flash_tween and hit_flash_tween.is_running():
		hit_flash_tween.kill()
	
	hit_flash_tween = create_tween()
	
	var flash_color = Color(1.5, 0.3, 0.3, 0.6)
	var normal_color = Color.WHITE
	
	for i in range(3):
		hit_flash_tween.tween_property(self, "modulate", flash_color, 0.05)
		hit_flash_tween.tween_property(self, "modulate", normal_color, 0.05)

func apply_difficulty() -> void:
	super.apply_difficulty()
	damage_gunshot = int(damage_gunshot * OptionsManager.get_player_multipler())
	damage_power = int(damage_power * OptionsManager.get_player_multipler())

func on_successful_hit() -> void:
	consecutive_hits_taken = 0
	if current_health > 0 and current_health < max_health:
		if randf() <= 0.20:
			set_health(current_health + 2)
			if has_node("/root/SoundPlayer"):
				SoundPlayer.play(SoundManager.Sound.FOOD)

func apply_super_strength() -> void:
	if not is_super_strength_active:
		damage = int(damage * 2)
	
	is_super_strength_active = true
	super_strength_timer = OptionsManager.get_super_food_duration()
	damage = int(damage * 2)
	character_sprite.modulate = Color(1.0, 0.85, 0.2)

func upgrade_armor() -> void:
	if armor_level < 5:
		armor_level += 1
		if character_sprite.material:
			character_sprite.material.set_shader_parameter("new_color", armor_colors[armor_level])

func upgrade_ally_cooldown() -> void:
	companion_cooldown_ms = maxi(2000, companion_cooldown_ms - 2000)
