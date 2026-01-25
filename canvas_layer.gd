extends CanvasLayer

@onready var  flash_rect
var gun

func _ready():
	
	flash_rect = $Flash
	
	
	
	
	
	
	
	gun = get_parent().get_node("Gun")
	if gun:
		gun.ammo_upd.connect(_on_gun_fire)
		

func _on_gun_fire(_ammo):
	if not flash_rect:
		return
	
	
	flash_rect.visible = true
	flash_rect.modulate.a = 1.0  
	
	
	var tween = create_tween()
	tween.tween_property(flash_rect, "modulate:a", 0.0, 0.35)  
	tween.tween_callback(func(): flash_rect.visible = false)  
