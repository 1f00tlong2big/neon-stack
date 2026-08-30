class_name Gravity
extends RefCounted


static func seconds_per_cell(level: int) -> float:
	var lv := maxi(level, 1)
	var base := 0.8 - float(lv - 1) * 0.007
	if base < 0.001:
		base = 0.001
	return pow(base, lv - 1)


static func cells_this_frame(level: int, delta: float, soft_drop: bool) -> float:
	var spc := seconds_per_cell(level)
	if soft_drop:
		spc /= GameConstants.SOFT_DROP_FACTOR
	if spc <= 0.00001:
		return 20.0
	return delta / spc
