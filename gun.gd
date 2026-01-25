extends RigidBody2D
class_name Gun

@onready var ray = $FireDirection
@onready var spr
@export var grav := 16200.0
@export var kick := 270000.0
@export var spd_cap := 21000.0
@export var rot_cap := 600.0
@export_range(0.0, 1.0) var hbias := 0.9
@export var cd := 200
@export var ammo_max := 10

var clip := 10
var last_t := 0
var started := false
var wrap_x := [0.0, 0.0]
var death_line := 0.0
var scrn_w := 0.0
var clone_l
var clone_r

signal died
signal ammo_upd
signal game_start

func bounds(l: float, r: float, _t: float, b: float):
	wrap_x = [l, r]
	death_line = b
	scrn_w = r - l

func addammo(n: int):
	clip = min(clip + n, ammo_max)
	ammo_upd.emit(clip)

func _input(event):
	var trig = false
	
	if event is InputEventScreenTouch and event.pressed:
		trig = true
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		trig = true
	elif event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		trig = true
	
	if trig:
		if not started:
			started = true
			freeze = false
			game_start.emit()
		shoot()

func _ready():
	clip = ammo_max
	gravity_scale = 0.0
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	freeze = true
	
	if spr:
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		
		clone_l = Sprite2D.new()
		clone_l.texture = spr.texture
		clone_l.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		clone_l.visible = false
		add_child(clone_l)
		
		clone_r = Sprite2D.new()
		clone_r.texture = spr.texture
		clone_r.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		clone_r.visible = false
		add_child(clone_r)

func shoot():
	if not started:
		return
	
	var t = Time.get_ticks_msec()
	if t - last_t < cd or clip <= 0:
		return
	
	clip -= 1
	last_t = t
	ammo_upd.emit(clip)
	
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(50)
	
	var dir_local = (ray.position - ray.target_position).normalized()
	var dir_world = global_transform.basis_xform(dir_local).normalized()
	var force = kick * lerp(1.0, abs(cos(dir_world.angle())), hbias)
	
	apply_impulse(-dir_world * force, ray.position)

func _physics_process(_delta):
	if not started:
		return
	
	apply_central_force(Vector2.DOWN * grav * mass)
	
	var spd = linear_velocity.length()
	if spd > spd_cap:
		linear_velocity = linear_velocity * (spd_cap / spd)
	
	angular_velocity = clamp(angular_velocity, -deg_to_rad(rot_cap), deg_to_rad(rot_cap))
	
	var px = global_position.x
	if px < wrap_x[0]:
		global_position.x = wrap_x[1]
	elif px > wrap_x[1]:
		global_position.x = wrap_x[0]
	
	if clone_l and clone_r:
		var edge_zone = 200
		clone_l.visible = px < wrap_x[0] + edge_zone
		clone_r.visible = px > wrap_x[1] - edge_zone
		
		if clone_l.visible:
			clone_l.position = Vector2(scrn_w, 0)
			clone_l.rotation = spr.rotation
		if clone_r.visible:
			clone_r.position = Vector2(-scrn_w, 0)
			clone_r.rotation = spr.rotation
	
	if global_position.y > death_line:
		died.emit()

func getammo() -> int:
	return clip
