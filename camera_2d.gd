extends Camera2D

@export var zoomlvl := 0.1

var startx: float

func _ready():
	enabled = true
	make_current()
	zoom = Vector2(zoomlvl, zoomlvl)
	position_smoothing_enabled = false
	
	global_position = get_parent().get_node("Gun").global_position
	startx = global_position.x

func _process(_delta):
	var g = get_parent().get_node("Gun")
	global_position.y = lerp(global_position.y, g.global_position.y, 10.0 * _delta)
	global_position.x = startx

func deathline() -> float:
	var vh = (get_viewport().get_visible_rect().size.y / zoomlvl) / 2
	return global_position.y + vh

func screenbnds() -> Dictionary:
	var vsz = get_viewport().get_visible_rect().size / zoomlvl
	
	return {
		"left": global_position.x - vsz.x / 2,
		"right": global_position.x + vsz.x / 2,
		"top": global_position.y - vsz.y / 2,
		"bottom": global_position.y + vsz.y / 2,
		"death_y": deathline()
	}
