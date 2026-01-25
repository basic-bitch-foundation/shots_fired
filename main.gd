extends Node2D

@onready var cam = $Camera2D
@onready var gun = $Gun
@onready var spawn = $GunSpawn

func respawn():
	await get_tree().create_timer(0.5).timeout
	get_tree().reload_current_scene()

func _ready():
	gun.global_position = spawn.global_position
	await get_tree().process_frame
	
	var b = cam.screenbnds()
	gun.bounds(b.left, b.right, b.top, b.bottom)
	gun.died.connect(respawn)

func _process(_delta):
	gun.death_line = cam.deathline()
