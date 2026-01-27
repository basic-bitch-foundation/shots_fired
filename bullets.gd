extends Node2D

@export var spawndst := 2500.0
@export var vspace := 1200.0
@export var coloff := 400.0
@export var ammopick := 3

var gun
var cam 
var tmpl
var folder
var lasty := 0.0
var active = []

func _ready():
	gun = get_parent().get_node("Gun")
	cam = get_parent().get_node("Camera2D")
	folder = get_node("bullets")
	tmpl = folder.get_node("Area2D")
	
	tmpl.visible = false
	lasty = gun.global_position.y

func setup(bul: Area2D):
	if not bul.body_entered.is_connected(hit):
		bul.body_entered.connect(hit.bind(bul))

func hit(body, bul):
	if not body is Gun or not bul in active:
		return
	
	active.erase(bul)
	gun.addammo(ammopick)
	
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(50)
	
	bul.queue_free()

func makebul(x: float, y: float):
	var b = tmpl.duplicate()
	b.visible = true
	b.global_position = Vector2(x, y)
	folder.add_child(b)
	active.append(b)
	setup(b)

func spawn():
	lasty -= vspace
	var cx = cam.global_position.x
	var pat = randi() % 3
	
	match pat:
		0: makebul(cx, lasty)
		1: makebul(cx - coloff, lasty)
		2: makebul(cx + coloff, lasty)

func _process(_delta):
	if not gun or not tmpl:
		return
	
	while gun.global_position.y < lasty + spawndst:
		spawn()
	
	cleanup()

func cleanup():
	var thresh = cam.global_position.y +10500.0
	var rmv = []
	
	for b in active:
		if is_instance_valid(b) and b.global_position.y > thresh:
			rmv.append(b)
	
	for b in rmv:
		active.erase(b)
		b.queue_free()
