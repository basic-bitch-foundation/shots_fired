extends Node2D

var cam
var gun
var tiles = []
var tile_h
var tmpl_tex
var tmpl_scale
var tmpl_centered
var tmpl_x

func _ready():
	cam = get_parent().get_node("Camera2D")
	gun = get_parent().get_node("Gun")
	
	var base = get_child(0)
	if not base:
		return
	
	tmpl_tex = base.texture
	tmpl_scale = base.scale
	tmpl_centered = base.centered
	tmpl_x = base.global_position.x
	tile_h = tmpl_tex.get_height() * tmpl_scale.y
	tiles.append(base)

func _process(_delta):
	if not gun or tiles.size() == 0:
		return
	
	var top = tiles[0]
	for t in tiles:
		if is_instance_valid(t) and t.global_position.y < top.global_position.y:
			top = t
	
	if gun.global_position.y < top.global_position.y + tile_h * 0.5:
		var spr = Sprite2D.new()
		spr.texture = tmpl_tex
		spr.scale = tmpl_scale
		spr.centered = tmpl_centered
		spr.global_position.x = tmpl_x
		spr.global_position.y = top.global_position.y - tile_h + 90
		
		add_child(spr)
		tiles.append(spr)
	
	var cull_y = cam.global_position.y + tile_h * 3
	var cleanup = []
	for t in tiles:
		if is_instance_valid(t) and t.global_position.y > cull_y:
			cleanup.append(t)
	
	for t in cleanup:
		tiles.erase(t)
		t.queue_free()
