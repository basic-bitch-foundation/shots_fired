extends Control

var gun: RigidBody2D
var icons = []

func update(ammo: int):
	for i in icons.size():
		icons[i].visible = i < ammo

func ammochg(curr: int):
	update(curr)

func _ready():
	for i in range(1, 11):
		var ico = get_node_or_null("bul" + str(i))
		if ico:
			icons.append(ico)
	
	gun = get_tree().get_first_node_in_group("gun")
	if not gun:
		gun = get_parent().get_parent().get_node("Gun")
	
	if gun:
		gun.ammo_upd.connect(ammochg)
		update(gun.getammo())
