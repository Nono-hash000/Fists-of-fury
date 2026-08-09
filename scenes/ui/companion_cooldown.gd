class_name CompanionCooldown
extends Label

const C_YELLOW := Color(0.816, 0.816, 0.0, 1.0)
const C_GREY := Color(0.35, 0.35, 0.35, 1.0)

var time_summoned := -10000
var cooldown_duration := 0

func _ready() -> void:
	add_theme_font_override("font", preload("res://assets/fonts/my 3x5 tiny mono pixel font.ttf"))
	add_theme_font_size_override("font_size", 6)
	
	EntityManager.companion_cooldown_started.connect(on_cooldown_started.bind())
	refresh()

func on_cooldown_started(duration_ms: int) -> void:
	time_summoned = Time.get_ticks_msec()
	cooldown_duration = duration_ms

func _process(_delta: float) -> void:
	refresh()

func refresh() -> void:
	var elapsed = Time.get_ticks_msec() - time_summoned
	
	if elapsed >= cooldown_duration:
		text = "ALLY: READY"
		add_theme_color_override("font_color", C_YELLOW)
	else:
		var remaining = (cooldown_duration - elapsed) / 1000.0
		text = "ALLY: %.1fs" % remaining
		add_theme_color_override("font_color", C_GREY)
