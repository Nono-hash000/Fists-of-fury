class_name BulletCounter
extends Control

const FONT := preload("res://assets/fonts/my 3x5 tiny mono pixel font.ttf")
const C_YELLOW :=  Color(0.816, 0.816, 0.0, 1.0)
const C_GREY := Color(0.35,  0.35,  0.35, 1.0)

const MAX_ICONS := 6

const ICON_W := 3
const ICON_H := 4
const ICON_GAP := 2

var _icons : Array[ColorRect] = []
var _label : Label
var _ammo := 0
var _has_gun := false
var _has_knife := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()
	_refresh()

func _build() -> void:
	_label = Label.new()
	_label.add_theme_font_override("font", FONT)
	_label.add_theme_font_size_override("font_size", 6)
	_label.add_theme_color_override("font_color", C_YELLOW)
	_label.position = Vector2(0, 5)
	_label.size = Vector2((ICON_W + ICON_GAP) * MAX_ICONS, 6)
	add_child(_label)
	
	for i in MAX_ICONS:
		var icon : = ColorRect.new()
		icon.size = Vector2(ICON_W, ICON_H)
		icon.position = Vector2(i * (ICON_W + ICON_GAP), 11)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(icon)
		_icons.append(icon)

func on_weapon_changed(has_knife: bool, ammo: int, has_gun: bool) -> void:
	_has_knife = has_knife
	_ammo = ammo
	_has_gun = has_gun
	_refresh()

func _refresh() -> void:
	if _has_knife:
		visible = true
		_label.text = "KNIFE"
		for icon in _icons:
			icon.visible = false
	elif _has_gun:
		visible = true
		_label.text = "GUNX%d" % _ammo
		for i in _icons.size():
			_icons[i].visible = true
			_icons[i].color = C_YELLOW if i < _ammo else C_GREY
	else:
		visible = false
