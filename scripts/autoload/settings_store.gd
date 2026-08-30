extends Node

const PATH := "user://settings.json"

var start_level: int = 1
var master_volume: float = 1.0
var music_volume: float = 0.7
var sfx_volume: float = 0.8
var ghost_enabled: bool = true
var selected_music: String = "" ## filename inside the music library, or "" for silence


func _ready() -> void:
	load_from_disk()
	apply_volumes()


func load_from_disk() -> void:
	if not FileAccess.file_exists(PATH):
		return
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var d: Dictionary = parsed
	start_level = clampi(int(d.get("start_level", 1)), 1, GameConstants.MAX_START_LEVEL)
	master_volume = clampf(float(d.get("master_volume", 1.0)), 0.0, 1.0)
	music_volume = clampf(float(d.get("music_volume", 0.7)), 0.0, 1.0)
	sfx_volume = clampf(float(d.get("sfx_volume", 0.8)), 0.0, 1.0)
	ghost_enabled = bool(d.get("ghost_enabled", true))
	selected_music = str(d.get("selected_music", ""))


func save_to_disk() -> void:
	var d := {
		start_level = start_level,
		master_volume = master_volume,
		music_volume = music_volume,
		sfx_volume = sfx_volume,
		ghost_enabled = ghost_enabled,
		selected_music = selected_music,
	}
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(d, "\t"))


func apply_volumes() -> void:
	var master_idx := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_idx, linear_to_db(maxf(master_volume, 0.0001)))
	var music_idx := AudioServer.get_bus_index("Music")
	if music_idx >= 0:
		AudioServer.set_bus_volume_db(music_idx, linear_to_db(maxf(music_volume, 0.0001)))
		AudioServer.set_bus_mute(music_idx, music_volume <= 0.001)
	var sfx_idx := AudioServer.get_bus_index("SFX")
	if sfx_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_idx, linear_to_db(maxf(sfx_volume, 0.0001)))
		AudioServer.set_bus_mute(sfx_idx, sfx_volume <= 0.001)
