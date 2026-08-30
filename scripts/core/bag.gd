class_name SevenBag
extends RefCounted

var _queue: Array[int] = []
var rng: RandomNumberGenerator


func _init(p_rng: RandomNumberGenerator = null) -> void:
	rng = p_rng if p_rng != null else RandomNumberGenerator.new()
	rng.randomize()


func next_kind() -> int:
	if _queue.is_empty():
		_fill()
	return _queue.pop_front()


func peek(count: int) -> Array[int]:
	while _queue.size() < count:
		_fill()
	var out: Array[int] = []
	for i in count:
		out.append(_queue[i])
	return out


func _fill() -> void:
	var bag: Array[int] = GameConstants.KIND_ORDER.duplicate()
	for i in range(bag.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp := bag[i]
		bag[i] = bag[j]
		bag[j] = tmp
	for k in bag:
		_queue.append(k)
