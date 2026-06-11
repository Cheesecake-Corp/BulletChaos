extends Enemy

# ─── Signals ───────────────────────────────────────────────────────────────────
signal health_changed(current: float, maximum: float)   # wire to boss health bar
signal phase_changed(new_phase: int)                    # 1 / 2 / 3


# ─── Node refs ─────────────────────────────────────────────────────────────────
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


# ─── Tunable stats (Phase 1 baseline) ─────────────────────────────────────────


@export var LIGHTNING_RANGE  : float = 130.0   # AoE radius when attack lands
@export var LIGHTNING_DAMAGE : float = 5.0
@export var ATTACK_COOLDOWN  : float = 2.4     # seconds between attacks

# Phase multipliers applied on top of the base values
const PHASE2_SPEED_MULT    := 1.30
const PHASE2_DAMAGE_MULT   := 1.25
const PHASE2_COOLDOWN_MULT := 0.75   # shorter = more frequent attacks

const PHASE3_SPEED_MULT    := 1.60
const PHASE3_DAMAGE_MULT   := 1.60
const PHASE3_COOLDOWN_MULT := 0.50

# HP thresholds
const PHASE2_THRESHOLD := 0.66
const PHASE3_THRESHOLD := 0.33


# ─── State machine ─────────────────────────────────────────────────────────────
enum State { IDLE, CHASE, ATTACK, HURT, DEAD }
var state : State = State.IDLE


# ─── Runtime vars ──────────────────────────────────────────────────────────────
var player        : Node2D = null
var current_phase : int    = 1
var attack_timer  : float  = 0.0
var hurt_timer    : float  = 0.0

# live stats — modified as phases change
var _speed            : float
var _lightning_damage : float
var _lightning_range  : float
var _attack_cooldown  : float

const HURT_STUN : float = 0.22


# ═══════════════════════════════════════════════════════════════════════════════
func _ready() -> void:
	MAX_HEALTH = 800.0
	SPEED = 110.0
	

	# initialise live stats from Phase 1 baseline
	_speed            = SPEED
	_lightning_damage = LIGHTNING_DAMAGE
	_lightning_range  = LIGHTNING_RANGE
	_attack_cooldown  = ATTACK_COOLDOWN

	anim.animation_finished.connect(_on_animation_finished)
	_set_state(State.IDLE)
	anim.play("born")
	super()


# ═══════════════════════════════════════════════════════════════════════════════
func _physics_process(delta: float) -> void:
	if not alive:
		return

	if attack_timer > 0.0:
		attack_timer -= delta

	match state:
		State.IDLE:
			_tick_idle()
		State.CHASE:
			_tick_chase()
		State.ATTACK:
			pass   # animation-driven; see _on_animation_finished
		State.HURT:
			_tick_hurt(delta)
		State.DEAD:
			pass


# ─── IDLE ──────────────────────────────────────────────────────────────────────
func _tick_idle() -> void:
	linear_velocity = Vector2.ZERO
	player = _find_player()
	if player and not anim.animation.contains("born"):
		_set_state(State.CHASE)


# ─── CHASE ─────────────────────────────────────────────────────────────────────
func _tick_chase() -> void:
	if not _player_valid():
		_set_state(State.IDLE)
		return

	var dist := global_position.distance_to(player.global_position)

	# Phase 3 closes in more aggressively before firing
	var trigger_range := _lightning_range * (0.85 if current_phase == 3 else 0.70)

	if dist <= trigger_range and attack_timer <= 0.0:
		_set_state(State.ATTACK)
		return

	# Navigate toward the player
	nav.target_position = player.global_position
	var dir := (nav.get_next_path_position() - global_position).normalized()
	linear_velocity = dir * _speed

	if dir.x != 0.0:
		anim.flip_h = dir.x < 0.0

	if anim.animation != "run" or not anim.is_playing():
		anim.play("run")


# ─── HURT ──────────────────────────────────────────────────────────────────────
func _tick_hurt(delta: float) -> void:
	linear_velocity = Vector2.ZERO
	hurt_timer -= delta
	if hurt_timer <= 0.0:
		_set_state(State.CHASE)


# ─── STATE TRANSITIONS ─────────────────────────────────────────────────────────
func _set_state(new_state: State) -> void:
	state = new_state
	match new_state:

		State.IDLE:
			linear_velocity = Vector2.ZERO
			anim.play("idle")

		State.CHASE:
			anim.play("run")

		State.ATTACK:
			movement = false
			linear_velocity = Vector2.ZERO
			# Phase 3 plays the attack animation noticeably faster
			anim.speed_scale = 1.5 if current_phase == 3 else 1.0
			anim.play("attack")
			_do_lightning_burst()

		State.HURT:
			movement = false
			linear_velocity = Vector2.ZERO
			hurt_timer = HURT_STUN
			anim.speed_scale = 1.0
			anim.play("damaged")

		State.DEAD:
			movement = false
			alive = false
			linear_velocity = Vector2.ZERO
			anim.speed_scale = 1.0
			anim.play("death")


# ─── ANIMATION CALLBACKS ───────────────────────────────────────────────────────
func _on_animation_finished() -> void:
	
	if anim.animation.contains("born"):
		anim.play("idle")
	
	match state:

		State.ATTACK:
			attack_timer  = _attack_cooldown
			anim.speed_scale = 1.0
			movement = true
			_set_state(State.CHASE)

		State.HURT:
			pass   # hurt_timer handles the exit

		State.DEAD:
			queue_free()


# ─── LIGHTNING BURST ───────────────────────────────────────────────────────────
# Deals damage when the attack animation finishes.
# Attach a visual effect (particles / shader) on the AnimatedSprite2D for the
# actual lightning flash — trigger it from _set_state(State.ATTACK) if needed.
func _do_lightning_burst() -> void:
	if not _player_valid():
		return
	if global_position.distance_to(player.global_position) <= _lightning_range:
		var dmg_mult : float = GAME.enemies_stats_set.get("damage_multiplier", 1.0)
		player.take_damage(_lightning_damage * dmg_mult)


# ─── OVERRIDE: take_damage ────────────────────────────────────────────────────
func take_damage(damage: float) -> void:
	if not alive or state == State.DEAD:
		return

	health -= damage
	health  = maxf(health, 0.0)

	var max_hp : float = MAX_HEALTH * GAME.enemies_stats_set["health_multiplier"]
	emit_signal("health_changed", health, max_hp)

	_check_phase_transition()

	if health <= 0.0:
		death()
		return

	_set_state(State.HURT)


# ─── PHASE TRANSITIONS ─────────────────────────────────────────────────────────
func _check_phase_transition() -> void:
	var max_hp  : float = MAX_HEALTH * GAME.enemies_stats_set["health_multiplier"]
	var ratio   : float = health / max_hp

	if current_phase == 1 and ratio <= PHASE2_THRESHOLD:
		_enter_phase(2)
	elif current_phase == 2 and ratio <= PHASE3_THRESHOLD:
		_enter_phase(3)


func _enter_phase(phase: int) -> void:
	current_phase = phase
	emit_signal("phase_changed", phase)

	match phase:
		2:
			_speed            = SPEED            * PHASE2_SPEED_MULT
			_lightning_damage = LIGHTNING_DAMAGE * PHASE2_DAMAGE_MULT
			_attack_cooldown  = ATTACK_COOLDOWN  * PHASE2_COOLDOWN_MULT
			# range unchanged in phase 2 — add multiplier here if desired

		3:
			# Phase 3 is calculated from the base, not stacked on phase 2
			_speed            = SPEED            * PHASE3_SPEED_MULT
			_lightning_damage = LIGHTNING_DAMAGE * PHASE3_DAMAGE_MULT
			_attack_cooldown  = ATTACK_COOLDOWN  * PHASE3_COOLDOWN_MULT


# ─── OVERRIDE: death ──────────────────────────────────────────────────────────
func death() -> void:
	if state == State.DEAD:
		return
	_set_state(State.DEAD)
	room_manager.enemy_dead += 1

	var rand := GAME.RANDOM_LOOT.randf()

	if rand > GAME.drop_chance_set["heal"]:
		var canister : Node2D = load("res://InteractObjects/HealthContainer/Health_container.tscn").instantiate()
		room_manager.room.call_deferred("add_child", canister)
		call_deferred("set_canister_pos", canister)

	elif rand > 1.0 - GAME.drop_chance_set["heal"] - GAME.drop_chance_set["upgrade"]:
		var upgrade = upgrade_resources.upgrades[
			GAME.RANDOM_LOOT.randi_range(0, upgrade_resources.upgrades.size() - 1)
		]
		var upgrade_item : Node2D
		if not upgrade.name in GAME.player.upgrade_resources:
			upgrade_item = load("res://Upgrades/Upgrade_item.tscn").instantiate()
			upgrade_item.upgrade = upgrade
		else:
			upgrade_item = load("res://Upgrades/processor_item.tscn").instantiate()
			upgrade_item.amount = GAME.RANDOM_LOOT.randi_range(10, 115) * GAME.currency_set["multiplier"]
		room_manager.room.call_deferred("add_child", upgrade_item)
		call_deferred("set_canister_pos", upgrade_item)


# ─── UTILITIES ────────────────────────────────────────────────────────────────
func _find_player() -> Player:
	return GAME.player


func _player_valid() -> bool:
	return player != null and is_instance_valid(player)
