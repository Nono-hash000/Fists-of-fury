extends Node2D

const PLAYER_PREFAB := preload("res://scenes/characters/player.tscn")
const SHOP_SCENE := preload("res://scenes/ui/shop_screen.tscn")

@onready var camera: Camera = $Camera
@onready var actors_container: Node2D = $ActorsContainer
@onready var ui: UI = $UI

var player: Player = null
var shop_instance = null

func _ready() -> void:
	StageManager.reset_stats()
	ui.game_over_scene = preload("res://scenes/ui/the_end_screen.tscn")
	player = PLAYER_PREFAB.instantiate()
	actors_container.add_child(player)
	player.position = Vector2(20, 50)
	actors_container.player = player
	var right_wall = camera.get_node_or_null("InvisibleWalls/RightWall")
	if right_wall:
		right_wall.queue_free()
	ui.stage_transition.end_transition()
	ui.show_stage_label("ENDLESS SURV")
	ui.level_label.visible = true
	ui.level_label.text = "LVL 1"
	ui.score_indicator.is_endless_mode = true
	ui.player_health_label.visible = true
	ui.player_healthbar.visible = false

func _process(_delta: float) -> void:
	if player != null and player.position.x > camera.position.x:
		camera.position.x = player.position.x
	
	if is_instance_valid(actors_container):
		var left_bound = camera.position.x - 70.0
		for child in actors_container.get_children():
			if child is Character and child.type != Character.Type.PLAYER:
				if child.position.x < left_bound:
					child.position.x = left_bound
	
	if Input.is_physical_key_pressed(KEY_P) and shop_instance == null and is_instance_valid(player):
		open_shop()

func open_shop() -> void:
	var shop = SHOP_SCENE.instantiate()
	shop.player = player
	
	shop.score_indicator = ui.score_indicator
	
	shop_instance = shop
	ui.add_child(shop_instance)
	get_tree().paused = true
	
	shop_instance.tree_exited.connect(func(): get_tree().paused = false)
