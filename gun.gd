extends RigidBody2D
class_name Gun

@onready var ray = $FireDirection
@onready var spr = $Sprite2D

var clone_l
var clone_r
var wrap_l := 0.0
var wrap_r := 0.0
var death_y := 0.0
var scrn_w := 0.0

@export var grav := 81000.0/6
@export var recoil := 180000.0*1.5
@export var maxspd := 14000.0*1.5
@export var maxrot := 400.0*1.5
@export_range(0.0, 1.0) var hbias := 0.9
@export var cooldown := 200
@export var maxammo := 100

var ammo := 100
var lastfire := 0

signal died
signal ammo_upd

func _ready():
	ammo = maxammo
	gravity_scale = 0.0
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	
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

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		fire()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		fire()

func fire():
	var t = Time.get_ticks_msec()
	if t - lastfire < cooldown or ammo <= 0:
		return
	
	ammo -= 1
	lastfire = t
	ammo_upd.emit(ammo)
	
	var tip = ray.position
	var trig = ray.target_position
	var dlocal = (tip - trig).normalized()
	var dglobal = global_transform.basis_xform(dlocal).normalized()
	
	var ang = dglobal.angle()
	var hfac = abs(cos(ang))
	var fmul = lerp(1.0, hfac, hbias)
	var fscale = recoil * fmul
	
	var rdir = -dglobal
	apply_impulse(rdir * fscale, tip)

func _physics_process(_delta):
	apply_central_force(Vector2.DOWN * grav * mass)
	
	if linear_velocity.length() > maxspd:
		linear_velocity = linear_velocity.normalized() * maxspd
	
	var maxang = deg_to_rad(maxrot)
	angular_velocity = clamp(angular_velocity, -maxang, maxang)
	
	var px = global_position.x
	if px < wrap_l:
		global_position.x = wrap_r
	elif px > wrap_r:
		global_position.x = wrap_l
	
	if clone_l and clone_r:
		if px < wrap_l + 200:
			clone_l.visible = true
			clone_l.position.x = scrn_w
			clone_l.position.y = 0
			clone_l.rotation = spr.rotation
		else:
			clone_l.visible = false
		
		if px > wrap_r - 200:
			clone_r.visible = true
			clone_r.position.x = -scrn_w
			clone_r.position.y = 0
			clone_r.rotation = spr.rotation
		else:
			clone_r.visible = false
	
	if global_position.y > death_y:
		died.emit()

func bounds(l: float, r: float, _t: float, b: float):
	wrap_l = l
	wrap_r = r
	death_y = b
	scrn_w = r - l

func addammo(amt: int):
	ammo = min(ammo + amt, maxammo)
	ammo_upd.emit(ammo)

func getammo() -> int:
	return ammo
