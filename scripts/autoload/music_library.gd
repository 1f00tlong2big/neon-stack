extends Node

## Custom music lives in user://music/. Players add tracks with the in-game
## file picker or by dropping .ogg / .mp3 / .wav files into that folder.

const LIB := "user://music/"
const README_NAME := "HOW_TO_ADD_MUSIC.txt"
const EXTENSIONS: Array[String] = ["ogg", "mp3", "wav"]

signal library_changed

var _player: AudioStreamPlayer


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.bus = "Music"
	add_child(_player)
	ensure_library()
	play_selected()


func ensure_library() -> String:
	DirAccess.make_dir_recursive_absolute(_abs_lib())
	var readme := LIB + README_NAME
	if not FileAccess.file_exists(readme):
		var f := FileAccess.open(readme, FileAccess.WRITE)
		if f:
			f.store_string(
				"NEON STACK — custom music\n"
				+ "=========================\n\n"
				+ "Drop .ogg, .mp3, or .wav files in this folder, then pick them in Settings.\n"
				+ "You can also use Add Music… inside the game — that copies a file here.\n\n"
				+ "This folder path:\n"
				+ _abs_lib()
				+ "\n"
			)
	return _abs_lib()


func _abs_lib() -> String:
	return ProjectSettings.globalize_path(LIB)


func open_folder() -> void:
	ensure_library()
	OS.shell_open(_abs_lib())


func list_tracks() -> Array[Dictionary]:
	ensure_library()
	var out: Array[Dictionary] = []
	var dir := DirAccess.open(LIB)
	if dir == null:
		return out
	dir.list_dir_begin()
	var fname := dir.get_next()
	while fname != "":
		if not dir.current_is_dir():
			var ext := fname.get_extension().to_lower()
			if ext in EXTENSIONS:
				out.append({
					filename = fname,
					path = LIB + fname,
					display = fname.get_basename(),
				})
		fname = dir.get_next()
	dir.list_dir_end()
	out.sort_custom(func(a, b): return str(a.display).nocasecmp_to(str(b.display)) < 0)
	return out


func import_file(src_path: String) -> String:
	ensure_library()
	if src_path.is_empty():
		return ""
	var ext := src_path.get_extension().to_lower()
	if ext not in EXTENSIONS:
		return ""
	var dest_name := src_path.get_file()
	var dest := LIB + dest_name
	var abs_src := src_path
	if abs_src.begins_with("user://") or abs_src.begins_with("res://"):
		abs_src = ProjectSettings.globalize_path(abs_src)
	var abs_dest := ProjectSettings.globalize_path(dest)
	var err := DirAccess.copy_absolute(abs_src, abs_dest)
	if err != OK:
		push_warning("Could not copy music file: %s (%s)" % [src_path, err])
		return ""
	SettingsStore.selected_music = dest_name
	SettingsStore.save_to_disk()
	library_changed.emit()
	play_selected()
	return dest_name


func play_selected() -> void:
	var name: String = SettingsStore.selected_music
	if name.is_empty():
		stop()
		return
	var path := LIB + name
	if not FileAccess.file_exists(path):
		stop()
		return
	var stream := load_user_audio(path)
	if stream == null:
		stop()
		return
	_player.stream = stream
	_player.play()


func stop() -> void:
	_player.stop()
	_player.stream = null


func is_playing() -> bool:
	return _player.playing


func load_user_audio(path: String) -> AudioStream:
	var abs_path := path
	if path.begins_with("user://") or path.begins_with("res://"):
		abs_path = ProjectSettings.globalize_path(path)
	var ext := path.get_extension().to_lower()
	match ext:
		"ogg":
			var ogg := AudioStreamOggVorbis.load_from_file(abs_path)
			if ogg:
				ogg.loop = true
			return ogg
		"mp3":
			var f := FileAccess.open(path, FileAccess.READ)
			if f == null:
				return null
			var mp3 := AudioStreamMP3.new()
			mp3.data = f.get_buffer(f.get_length())
			mp3.loop = true
			return mp3
		"wav":
			var wav := AudioStreamWAV.load_from_file(abs_path)
			if wav:
				wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
				return wav
			return _load_wav_pcm(path)
		_:
			return null


func _load_wav_pcm(path: String) -> AudioStreamWAV:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return null
	var data := f.get_buffer(f.get_length())
	if data.size() < 44:
		return null
	## Skip RIFF header; find "data" chunk. Minimal PCM 16-bit stereo/mono.
	var i := 12
	var pcm := PackedByteArray()
	var format_code := 1
	var channels := 2
	var rate := 44100
	var bits := 16
	while i + 8 <= data.size():
		var chunk := String.chr(data[i]) + String.chr(data[i + 1]) + String.chr(data[i + 2]) + String.chr(data[i + 3])
		var size := data[i + 4] | (data[i + 5] << 8) | (data[i + 6] << 16) | (data[i + 7] << 24)
		i += 8
		if chunk == "fmt ":
			if i + 16 <= data.size():
				format_code = data[i] | (data[i + 1] << 8)
				channels = data[i + 2] | (data[i + 3] << 8)
				rate = data[i + 4] | (data[i + 5] << 8) | (data[i + 6] << 16) | (data[i + 7] << 24)
				bits = data[i + 14] | (data[i + 15] << 8)
		elif chunk == "data":
			pcm = data.slice(i, i + size)
			break
		i += size
	if pcm.is_empty() or format_code != 1:
		return null
	var wav := AudioStreamWAV.new()
	wav.data = pcm
	wav.mix_rate = rate
	wav.stereo = channels == 2
	wav.format = AudioStreamWAV.FORMAT_16_BITS if bits == 16 else AudioStreamWAV.FORMAT_8_BITS
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_end = pcm.size()
	return wav
