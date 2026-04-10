extends Label

func _ready() -> void:
	GAME.weapon_changed.connect(weapon_changed.bind())
	
func weapon_changed():
	GAME.current_weapon.change_bullets.connect(changed_bullets.bind())
	text = str(GAME.current_weapon.loaded_ammo)

func changed_bullets(bullets : int):
	text = str(bullets)
