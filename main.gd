extends Node2D

@onready var cam: Camera2D = $Camera2D
@onready var gun: RigidBody2D = $Gun
@onready var spawn: Marker2D = $GunSpawn

func _ready():
	gun.global_position = spawn.global_position
	await get_tree().process_frame
	
	var b = cam.screenbnds()
	gun.bounds(b.left, b.right, b.top, b.bottom)
	gun.died.connect(respawn)

func _process(_delta):
	gun.death_y = cam.deathline()

func respawn():
	await get_tree().create_timer(0.5).timeout
	get_tree().reload_current_scene()
	

	
	
	
	
