extends Camera2D

@export var zm := 0.1

var start_x: float
var active := false
var top_y: float = 0.0

func deathline() -> float:
	return global_position.y + (get_viewport().get_visible_rect().size.y / zm) * 0.5

func screenbnds() -> Dictionary:
	var sz = get_viewport().get_visible_rect().size / zm
	var half_w = sz.x * 0.5
	var half_h = sz.y * 0.5
	
	return {
		"left": global_position.x - half_w,
		"right": global_position.x + half_w,
		"top": global_position.y - half_h,
		"bottom": global_position.y + half_h,
		"death_y": deathline()
	}

func _ready():
	enabled = true
	make_current()
	zoom = Vector2(zm, zm)
	position_smoothing_enabled = false
	
	var g = get_parent().get_node("Gun")
	global_position = g.global_position
	start_x = global_position.x
	top_y = global_position.y
	
	g.game_start.connect(func(): active = true)

func _process(_delta):
	if not active:
		return
	
	var gy = get_parent().get_node("Gun").global_position.y
	
	if gy < top_y:
		top_y = gy
		global_position.y += (gy - global_position.y) * 10.0 * _delta
	
	global_position.x = start_x
