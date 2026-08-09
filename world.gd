extends Node2D

const PLAYER_PREFAB := preload("res://scenes/characters/player.tscn")
const THE_END_SCREEN := preload("res://scenes/ui/the_end_screen.tscn")

const STAGE_PREFABS := [
	preload("res://scenes/stage/stage_01_streets.tscn"),
	preload("res://scenes/stage/stage_02_bar.tscn"),
	preload("res://scenes/stage/stage_03_streets.tscn"),
]

@onready var camera := $Camera
@onready var stage_container: Node2D = $StageContainer
@onready var actors_container: Node2D = $ActorsContainer
@onready var stage_transition: StageTransition = $UI/UIContainer/StageTransition

var camera_initial_position := Vector2.ZERO
var current_stage_index = -1
var is_camera_locked := false
var is_stage_ready_for_loading := false
var player : Player = null

func _ready() -> void:
	camera_initial_position = camera.position
	
	StageManager.checkpoint_start.connect(on_checkpoint_start)
	StageManager.checkpoint_complete.connect(on_checkpoint_complete)
	StageManager.stage_interim.connect(load_next_stage)
	
	StageManager.reset_stats()
	load_next_stage()

func _process(_delta: float) -> void:
	if is_stage_ready_for_loading:
		is_stage_ready_for_loading = false
		var stage : Stage = STAGE_PREFABS[current_stage_index].instantiate()
		stage_container.add_child(stage)
		
		player = PLAYER_PREFAB.instantiate()
		actors_container.add_child(player)
		player.position = stage.get_player_spawn_location()
		actors_container.player = player
		
		camera.position = camera_initial_position
		camera.reset_smoothing()
		stage_transition.end_transition()
		StageManager.stage_started.emit(current_stage_index + 1)

	if player != null and not is_camera_locked and player.position.x > camera.position.x:
		camera.position.x = player.position.x

func load_next_stage() -> void:
	current_stage_index += 1
	if current_stage_index < STAGE_PREFABS.size():
		print("Loading stage index: ", current_stage_index)
		
		for child_stage: Node2D in stage_container.get_children():
			child_stage.queue_free()
			
		for actor: Node2D in actors_container.get_children():
			actor.queue_free()
			
		is_stage_ready_for_loading = true
		stage_transition.start_transition()
	else:
		var game_over = THE_END_SCREEN.instantiate()
		game_over.process_mode = Node.PROCESS_MODE_ALWAYS
		$UI.add_child(game_over)
		game_over.set_score(StageManager.score)
		get_tree().paused = true

func on_checkpoint_start() -> void:
	is_camera_locked = true

func on_checkpoint_complete(_checkpoint: Checkpoint) -> void:
	is_camera_locked = false
