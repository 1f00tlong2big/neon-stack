extends SceneTree

func _init() -> void:
	var fails := 0
	fails += _test_bag()
	fails += _test_board()
	fails += _test_srs()
	fails += _test_scoring()
	if fails == 0:
		print("ALL TESTS PASSED")
		quit(0)
	else:
		print("FAILED %d CHECK(S)" % fails)
		quit(1)


func _ok(cond: bool, name: String) -> int:
	if cond:
		print("  PASS  ", name)
		return 0
	print("  FAIL  ", name)
	return 1


func _test_bag() -> int:
	print("bag")
	var fails := 0
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var bag := SevenBag.new(rng)
	var seen: Dictionary = {}
	for i in 7:
		seen[bag.next_kind()] = true
	for k in GameConstants.KIND_ORDER:
		fails += _ok(seen.has(k), "bag contains %s" % GameConstants.KIND_NAMES[k])
	fails += _ok(seen.size() == 7, "bag size 7")
	for _n in 100:
		var bag2 := SevenBag.new()
		var kinds: Array[int] = []
		for i in 7:
			kinds.append(bag2.next_kind())
		kinds.sort()
		var expected: Array[int] = GameConstants.KIND_ORDER.duplicate()
		expected.sort()
		if kinds != expected:
			fails += _ok(false, "100 random bags")
			return fails
	fails += _ok(true, "100 random bags each contain IOTSZJL once")
	return fails


func _test_board() -> int:
	print("board")
	var fails := 0
	var b := Board.new()
	var p := Piece.new(GameConstants.Kind.O, 0, 4, 36)
	fails += _ok(not b.collides(p), "O fits in empty well")
	var wall := Piece.new(GameConstants.Kind.O, 0, -2, 36)
	fails += _ok(b.collides(wall), "O collides with left wall")
	b.lock_piece(p)
	fails += _ok(b.collides(p), "O collides with itself after lock")
	var empty := Board.new()
	for x in GameConstants.WIDTH:
		empty.cells[38][x] = GameConstants.Kind.I
		empty.cells[39][x] = GameConstants.Kind.I
	var rows := empty.full_rows()
	fails += _ok(rows.size() == 2, "two full rows detected")
	empty.clear_rows(rows)
	fails += _ok(empty.full_rows().is_empty(), "rows cleared")
	fails += _ok(empty.is_perfect_clear(), "perfect clear after wiping filled rows from otherwise empty stack")
	return fails


func _test_srs() -> int:
	print("srs")
	var fails := 0
	var b := Board.new()
	var i := Piece.new(GameConstants.Kind.I, 0, 3, 20)
	var r := SRS.try_rotate(b, i, 1)
	fails += _ok(r.ok, "I rotates CW on empty board")
	fails += _ok(i.rotation == 1, "I rotation is R")
	## JLSTZ left-wall kick: T spawn against left wall, rotate CCW (0->L).
	var t := Piece.new(GameConstants.Kind.T, 0, 0, 20)
	var r2 := SRS.try_rotate(b, t, -1)
	fails += _ok(r2.ok, "T 0->L against left wall kicks")
	fails += _ok(int(r2.kick_index) >= 0, "T kick index recorded")
	## I floor kick: vertical I sitting on the floor.
	var floor := Piece.new(GameConstants.Kind.I, 1, 3, 36)
	while true:
		var n := floor.duplicate_piece()
		n.y += 1
		if b.collides(n):
			break
		floor.y += 1
	var r3 := SRS.try_rotate(b, floor, -1)
	fails += _ok(r3.ok, "I vertical on floor can rotate")
	return fails


func _test_scoring() -> int:
	print("scoring")
	var fails := 0
	var s := ScoreState.new()
	s.reset(2)
	var tetris: Dictionary = s.award_lock(4, "", false)
	fails += _ok(int(tetris.points) == 1600, "Tetris at level 2 = 1600 (got %s)" % str(tetris.points))
	fails += _ok(bool(s.back_to_back), "B2B armed after Tetris")
	s.award_lock(0, "", false)
	var b2b: Dictionary = s.award_lock(4, "", false)
	fails += _ok(int(b2b.points) == 2400, "B2B Tetris at level 2 = 2400 (got %s)" % str(b2b.points))
	s.award_lock(0, "", false)
	var single: Dictionary = s.award_lock(1, "", false)
	fails += _ok(not bool(s.back_to_back), "plain single breaks B2B")
	fails += _ok(int(single.points) == 200, "single at level 2 = 200 (got %s)" % str(single.points))
	return fails
