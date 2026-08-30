extends Node

const PATH := "user://high_scores.json"
const MAX_ENTRIES := 10

var entries: Array = [] ## [{score, lines, level, date}]


func _ready() -> void:
	load_from_disk()


func load_from_disk() -> void:
	entries = []
	if not FileAccess.file_exists(PATH):
		return
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) == TYPE_ARRAY:
		entries = parsed


func save_to_disk() -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(entries, "\t"))


func consider(score: int, lines: int, level: int) -> int:
	var row := {
		score = score,
		lines = lines,
		level = level,
		date = Time.get_datetime_string_from_system(false, true),
	}
	entries.append(row)
	entries.sort_custom(func(a, b): return int(a.score) > int(b.score))
	if entries.size() > MAX_ENTRIES:
		entries.resize(MAX_ENTRIES)
	save_to_disk()
	for i in entries.size():
		if entries[i] == row:
			return i
	return -1
