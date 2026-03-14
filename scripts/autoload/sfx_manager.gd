extends Node

## Procedural SFX manager. Generates simple sound effects using AudioStreamGenerator.
## Placeholder system that can be hooked up to real audio files later.

var audio_players: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_create_player("cannon_fire")
	_create_player("explosion")
	_create_player("hit")
	_create_player("level_up")
	_create_player("button_click")
	_create_player("skill_use")
	_create_player("dash")
	_create_player("shield")
	_create_player("heal")
	_create_player("stage_clear")


func _create_player(id: String) -> void:
	var player := AudioStreamPlayer.new()
	player.bus = "Master"
	player.volume_db = -10.0
	add_child(player)
	audio_players[id] = player


func play_cannon_fire() -> void:
	_play_generated("cannon_fire", 80.0, 0.15, 0.8)


func play_explosion() -> void:
	_play_generated("explosion", 60.0, 0.3, 0.6)


func play_hit() -> void:
	_play_generated("hit", 120.0, 0.1, 0.7)


func play_level_up() -> void:
	_play_generated("level_up", 440.0, 0.4, 0.5)


func play_button_click() -> void:
	_play_generated("button_click", 600.0, 0.05, 0.3)


func play_skill_use() -> void:
	_play_generated("skill_use", 330.0, 0.2, 0.6)


func play_dash() -> void:
	_play_generated("dash", 200.0, 0.15, 0.5)


func play_shield() -> void:
	_play_generated("shield", 260.0, 0.3, 0.4)


func play_heal() -> void:
	_play_generated("heal", 520.0, 0.25, 0.4)


func play_stage_clear() -> void:
	_play_generated("stage_clear", 440.0, 0.5, 0.5)


func _play_generated(id: String, base_freq: float, duration: float, volume: float) -> void:
	var player: AudioStreamPlayer = audio_players.get(id)
	if not player:
		return

	var sample_rate := 22050.0
	var samples := int(sample_rate * duration)

	var stream := AudioStreamWAV.new()
	stream.mix_rate = int(sample_rate)
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.stereo = false

	var data := PackedByteArray()
	data.resize(samples)

	# Add pitch variation
	var freq := base_freq * randf_range(0.9, 1.1)

	for i in range(samples):
		var t := float(i) / sample_rate
		var envelope := clampf(1.0 - t / duration, 0.0, 1.0)
		# Square-ish wave with harmonics
		var sample := sin(t * freq * TAU) * 0.6
		sample += sin(t * freq * 2.0 * TAU) * 0.25
		sample += sin(t * freq * 0.5 * TAU) * 0.15
		sample *= envelope * volume
		# Convert to 8-bit unsigned (0-255, center at 128)
		data[i] = int(clampf(sample * 127.0 + 128.0, 0.0, 255.0))

	stream.data = data
	player.stream = stream
	player.play()
