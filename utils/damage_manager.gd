extends Node

signal health_change(character_type: Character.Type, current_health: int, max_health: int)
signal heavy_blow_received()
signal player_revive()
signal weapon_changed(has_kniufe: bool, ammo: int, has_gun: bool)
signal player_took_damage(amount: int)
