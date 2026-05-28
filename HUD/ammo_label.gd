extends Label

func _ready() -> void:
	GAME.weapon_changed.connect(weapon_changed.bind())
	
func weapon_changed():
	GAME.current_weapon.change_bullets.connect(changed_bullets.bind())
	text = str(GAME.current_weapon.loaded_ammo) + "/" + str(GAME.current_weapon.magazine_size)

func changed_bullets(bullets : int):
	text = str(bullets) + "/" + str(GAME.current_weapon.magazine_size)
