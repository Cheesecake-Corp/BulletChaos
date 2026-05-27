extends CanvasLayer

@onready var shield_bar: TextureProgressBar = $ShieldBar
@onready var health_bar: TextureProgressBar = $HealthBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_player_health_change(health: float) -> void:
	health_bar.max_value = GAME.player.max_health
	health_bar.value = health

func _on_player_shield_change(shield: float) -> void:
	shield_bar.max_value = GAME.player.max_shield
	shield_bar.value = shield
