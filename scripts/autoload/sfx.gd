extends Node

var _player: AudioStreamPlayer
var _streams: Dictionary = {}


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.bus = "SFX"
	add_child(_player)
	for name in ["move", "rotate", "lock", "drop", "line", "tetris", "hold", "game_over"]:
		var path := "res://assets/sfx/%s.wav" % name
		if ResourceLoader.exists(path):
			_streams[name] = load(path)


func play(name: String) -> void:
	if not _streams.has(name):
		return
	var p := AudioStreamPlayer.new()
	p.bus = "SFX"
	p.stream = _streams[name]
	p.finished.connect(p.queue_free)
	add_child(p)
	p.play()
