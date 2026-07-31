class_name AudioFeedback
extends Node

const SAMPLE_RATE: int = 22050

@export var weapon_controller_path: NodePath

var _weapon_controller: WeaponController
var _players: Dictionary = {}

func _ready() -> void:
	_weapon_controller = get_node_or_null(weapon_controller_path) as WeaponController
	if _weapon_controller == null:
		push_error("AudioFeedback requires a WeaponController.")
		return
	_add_cue(&"shot", 105.0, 0.055, 0.90)
	_add_cue(&"hit", 780.0, 0.060, 0.48)
	_add_cue(&"empty", 180.0, 0.075, 0.35)
	_add_cue(&"reload_start", 310.0, 0.095, 0.28)
	_add_cue(&"reload_complete", 520.0, 0.110, 0.32)
	_add_cue(&"knockdown", 72.0, 0.180, 0.62)
	_weapon_controller.shot_fired.connect(_on_shot_fired)
	_weapon_controller.hit_confirmed.connect(_on_hit_confirmed)
	_weapon_controller.empty_triggered.connect(_on_empty_triggered)
	_weapon_controller.reload_started.connect(_on_reload_started)
	_weapon_controller.reload_ended.connect(_on_reload_ended)

func _exit_tree() -> void:
	for player_value: Variant in _players.values():
		var player: AudioStreamPlayer = player_value as AudioStreamPlayer
		if player != null:
			player.stop()
			player.stream = null

func _add_cue(cue_name: StringName, frequency_hz: float, duration_seconds: float, amplitude: float) -> void:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.name = String(cue_name).to_pascal_case()
	player.stream = _create_wave(frequency_hz, duration_seconds, amplitude)
	add_child(player)
	_players[cue_name] = player

func _create_wave(frequency_hz: float, duration_seconds: float, amplitude: float) -> AudioStreamWAV:
	var sample_count: int = maxi(1, roundi(duration_seconds * float(SAMPLE_RATE)))
	var data: PackedByteArray = PackedByteArray()
	data.resize(sample_count * 2)
	for sample_index: int in range(sample_count):
		var time_seconds: float = float(sample_index) / float(SAMPLE_RATE)
		var lifetime_ratio: float = float(sample_index) / float(sample_count)
		var envelope: float = (1.0 - lifetime_ratio) * (1.0 - lifetime_ratio)
		var fundamental: float = sin(TAU * frequency_hz * time_seconds)
		var harmonic: float = sin(TAU * frequency_hz * 2.03 * time_seconds) * 0.28
		var signed_sample: int = clampi(
			roundi((fundamental + harmonic) * envelope * amplitude * 24000.0),
			-32768,
			32767
		)
		data.encode_s16(sample_index * 2, signed_sample)
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = data
	return stream

func _play_cue(cue_name: StringName) -> void:
	var player: AudioStreamPlayer = _players.get(cue_name) as AudioStreamPlayer
	if player != null:
		player.play()

func _on_shot_fired(_origin: Vector2, _end_position: Vector2, _did_hit: bool) -> void:
	_play_cue(&"shot")

func _on_hit_confirmed(target: Node, _damage: int, _hit_position: Vector2) -> void:
	var knocked_down: bool = target != null and target.has_method("get_is_knocked_down") and bool(target.call("get_is_knocked_down"))
	_play_cue(&"knockdown" if knocked_down else &"hit")

func _on_empty_triggered() -> void:
	_play_cue(&"empty")

func _on_reload_started(_duration_seconds: float, _is_automatic: bool) -> void:
	_play_cue(&"reload_start")

func _on_reload_ended(completed: bool, _was_automatic: bool) -> void:
	if completed:
		_play_cue(&"reload_complete")
