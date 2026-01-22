extends RigidBody2D
class_name Gun


@export var recoil_force := 1200.0
@export var recoil_torque := 500.0
@export var max_ammo := 100
@export var gravity_strength := 980.0


var current_ammo := 10
var screen_size: Vector2


func _ready():
	screen_size = get_viewport_rect().size
	current_ammo = max_ammo
	
	
	gravity_scale = 0.0


func _physics_process(delta): #error is here
	
	apply_central_force(Vector2.DOWN * gravity_strength * mass)
	
	
	_handle_screen_wrap()


func _input(event):
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		_fire()
	
	
	if event is InputEventScreenTouch and event.pressed:
		_fire()
	

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_fire()


func _fire():
	
	if current_ammo <= 0:
		print("Out of ammo!")
		return
	
	
	current_ammo -= 1
	print("BANG! Ammo left: ", current_ammo)
	
	
	var recoil_direction = Vector2.UP.rotated(rotation)
	
	# Apply upward impulse
	apply_central_impulse(recoil_direction * recoil_force)
	
	
	apply_torque_impulse(recoil_torque)


func _handle_screen_wrap():
	var pos = global_position
	var wrapped = false
	
	
	if pos.x < 0:
		pos.x = screen_size.x
		wrapped = true
	elif pos.x > screen_size.x:
		
		
		pos.x = 0
		wrapped = true
	
	
	if wrapped:
		
		angular_velocity *= -1
	
	global_position = pos


func get_ammo() -> int:
	
	return current_ammo

func add_ammo(amount: int):
	
	
	current_ammo = min(current_ammo + amount, max_ammo)
	print("Ammo added! Total: ", current_ammo)   
