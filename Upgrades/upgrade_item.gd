extends Node2D

var upgrade : Upgrade

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == GAME.player:
		if upgrade.name in GAME.player.upgrade_resources: #Checks if upgrades already exists
			queue_free()
			return
		if upgrade is PlayerUpgrade:
			var instance = PlayerModInstance.new() #Creates instance of script player_upgrade_instance
			instance.data = upgrade
			GAME.player.upgrades.append(instance)
		if upgrade is WeaponUpgrade:
			var instance = WeaponModInstance.new()
			instance.data = upgrade
			GAME.player.weapon_upgrades.append(instance)
		GAME.player.upgrade_resources.append(upgrade.name)
		queue_free()
