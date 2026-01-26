extends Node2D

@export var spawndst := 30000.0
@export var vspace := 6000.0
@export var coloff := 2000.0

var gun
var cam
var cnt := 0
var lbl
var tmpl
var folder
var lasty := 0.0
var active = []

func updui():
	lbl.text = str(cnt)

func hit(body, coin):
	if not body is Gun:
		return
	
	var idx = active.find(coin)
	if idx == -1:
		return
	
	active.remove_at(idx)
	cnt += 1
	updui()
	
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(30)
	
	coin.queue_free()

func make(x: float, y: float):
	var c = tmpl.duplicate()
	c.visible = true
	c.global_position = Vector2(x, y)
	
	folder.add_child(c)
	active.append(c)
	
	if not c.body_entered.is_connected(hit):
		c.body_entered.connect(hit.bind(c))

func spawn():
	lasty -= vspace
	var cx = cam.global_position.x
	var pat = randi() % 5
	
	match pat:
		0:
			make(cx - coloff, lasty)
			make(cx, lasty)
			make(cx + coloff, lasty)
		1:
			make(cx - coloff, lasty)
			make(cx + coloff, lasty)
		2:
			make(cx, lasty)
		3:
			make(cx - coloff, lasty)
			make(cx, lasty)
		4:
			make(cx, lasty)
			make(cx + coloff, lasty)

func cleanup():
	var thresh = cam.global_position.y + 3000.0
	var i = active.size() - 1
	
	while i >= 0:
		var c = active[i]
		if c.global_position.y > thresh:
			active.remove_at(i)
			c.queue_free()
		i -= 1

func _process(delta):
	while gun.global_position.y < lasty + spawndst:
		spawn()
	
	var rotspd = 180 * delta
	for c in active:
		c.rotation_degrees += rotspd
	
	cleanup()

func _ready():
	gun = get_parent().get_node("Gun")
	cam = get_parent().get_node("Camera2D")
	lbl = get_parent().get_node("UI/count")
	folder = get_node("coins")
	tmpl = folder.get_node("coin1")
	
	tmpl.visible = false
	lasty = gun.global_position.y
	
	if not tmpl.body_entered.is_connected(hit):
		tmpl.body_entered.connect(hit.bind(tmpl))
	
	updui()
