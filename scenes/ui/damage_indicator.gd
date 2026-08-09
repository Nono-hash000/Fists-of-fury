class_name DamageIndicator
extends Node2D

var amount := 0
var velocity := Vector2.ZERO
var gravity := 400.0

@onready var label: Label = $Label

func _ready() -> void:
	label.text = str(amount)
	velocity = Vector2(randf_range(-30, 30), -150)
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.8).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free)

func _process(delta: float) -> void:
	velocity.y += gravity * delta
	position += velocity * delta
