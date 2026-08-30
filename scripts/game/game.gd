extends Node2D

enum State { SPAWN, FALLING, LOCKING, LINE_CLEAR, ARE, GAME_OVER, PAUSED }

signal stats_changed
signal line_cleared(rows: Array, name: String, tetris: bool)
signal topped_out
signal paused_changed(paused: bool)

var board: Board = Board.new()
var bag: SevenBag = SevenBag.new()
var current: Piece
var hold_kind: int = -1
var can_hold: bool = true
var next_queue: Array[int] = []

var state: int = State.SPAWN
var _resume_state: int = State.FALLING
var gravity_accum: float = 0.0
var lock_timer: float = 0.0
var lock_resets: int = 0
var lowest_row: int = -999
var are_timer: float = 0.0
var line_timer: float = 0.0
var pending_rows: Array[int] = []
var das: InputRepeat = InputRepeat.new()
var scores: ScoreState = ScoreState.new()
var last_kick_index: int = -1
var last_rotated: bool = false
var last_kicked: bool = false
var flash_rows: Array[int] = []
var toast: String = ""
var toast_timer: float = 0.0
var shake: float = 0.0

@onready var playfield: Node2D = $PlayfieldView
@onready var hud: CanvasLayer = $HUD


func _ready() -> void:
	scores.reset(SettingsStore.start_level)
	_fill_next()
	add_to_group("neon_game")
	state = State.SPAWN
	stats_changed.emit()
	MusicLibrary.play_selected()


func _fill_next() -> void:
	while next_queue.size() < GameConstants.NEXT_COUNT:
		next_queue.append(bag.next_kind())


func _take_next() -> int:
	_fill_next()
	var k: int = next_queue.pop_front()
	_fill_next()
	return k


func _process(delta: float) -> void:
	if toast_timer > 0.0:
		toast_timer -= delta
		if toast_timer <= 0.0:
			toast = ""
	if shake > 0.0:
		shake = maxf(shake - delta * 8.0, 0.0)

	if state == State.GAME_OVER:
		return
	if state == State.PAUSED:
		if Input.is_action_just_pressed("pause"):
			_set_paused(false)
		return
	if Input.is_action_just_pressed("pause"):
		_set_paused(true)
		return

	match state:
		State.SPAWN:
			_spawn()
		State.FALLING, State.LOCKING:
			_tick_play(delta)
		State.LINE_CLEAR:
			line_timer -= delta
			if line_timer <= 0.0:
				board.clear_rows(pending_rows)
				pending_rows.clear()
				flash_rows.clear()
				are_timer = GameConstants.ARE_TIME
				state = State.ARE
				stats_changed.emit()
		State.ARE:
			are_timer -= delta
			if are_timer <= 0.0:
				state = State.SPAWN


func _set_paused(p: bool) -> void:
	if p:
		if state == State.GAME_OVER:
			return
		_resume_state = state
		state = State.PAUSED
	else:
		state = _resume_state
	paused_changed.emit(p)


func request_unpause() -> void:
	if state == State.PAUSED:
		_set_paused(false)


func request_restart() -> void:
	get_tree().reload_current_scene()


func request_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _spawn() -> void:
	var kind := _take_next()
	current = Piece.new(kind, 0, GameConstants.SPAWN_X, GameConstants.SPAWN_Y)
	if board.collides(current):
		_game_over()
		return
	var drop := current.duplicate_piece()
	drop.y += 1
	if not board.collides(drop):
		current.y += 1
	can_hold = true
	gravity_accum = 0.0
	lock_timer = GameConstants.LOCK_DELAY
	lock_resets = 0
	lowest_row = current.max_y()
	last_rotated = false
	last_kicked = false
	last_kick_index = -1
	state = State.FALLING
	stats_changed.emit()


func _on_ground() -> bool:
	var p := current.duplicate_piece()
	p.y += 1
	return board.collides(p)


func _tick_play(delta: float) -> void:
	_handle_actions()
	if state == State.GAME_OVER or current == null:
		return

	var steps := das.ticks(
		delta,
		Input.is_action_pressed("move_left"),
		Input.is_action_pressed("move_right"),
		Input.is_action_just_pressed("move_left"),
		Input.is_action_just_pressed("move_right")
	)
	if steps != 0:
		var sign_dir := signi(steps)
		for _i in abs(steps):
			if not _try_shift(sign_dir):
				break

	var soft := Input.is_action_pressed("soft_drop")
	gravity_accum += Gravity.cells_this_frame(scores.level, delta, soft)
	while gravity_accum >= 1.0:
		gravity_accum -= 1.0
		if _try_drop(soft):
			continue
		break

	if _on_ground():
		state = State.LOCKING
		lock_timer -= delta
		if lock_timer <= 0.0:
			_lock()
	else:
		state = State.FALLING
		lock_timer = GameConstants.LOCK_DELAY


func _handle_actions() -> void:
	if Input.is_action_just_pressed("rotate_cw"):
		_rotate(1)
	if Input.is_action_just_pressed("rotate_ccw"):
		_rotate(-1)
	if Input.is_action_just_pressed("rotate_180"):
		_rotate(2)
	if Input.is_action_just_pressed("hold"):
		_hold()
	if Input.is_action_just_pressed("hard_drop"):
		_hard_drop()


func _try_shift(dx: int) -> bool:
	var p := current.duplicate_piece()
	p.x += dx
	if board.collides(p):
		return false
	current.x = p.x
	last_rotated = false
	Sfx.play("move")
	_after_move()
	return true


func _try_drop(soft: bool) -> bool:
	var p := current.duplicate_piece()
	p.y += 1
	if board.collides(p):
		return false
	current.y = p.y
	last_rotated = false
	if soft:
		scores.award_drop(false, 1)
		stats_changed.emit()
	if current.max_y() > lowest_row:
		lowest_row = current.max_y()
		lock_resets = 0
		lock_timer = GameConstants.LOCK_DELAY
	return true


func _rotate(dir: int) -> void:
	var result: Dictionary = SRS.try_rotate(board, current, dir)
	if not result.ok:
		return
	last_rotated = true
	last_kick_index = int(result.kick_index)
	last_kicked = last_kick_index > 0
	Sfx.play("rotate")
	_after_move()


func _after_move() -> void:
	if not _on_ground():
		lock_timer = GameConstants.LOCK_DELAY
		return
	if lock_resets < GameConstants.LOCK_RESET_LIMIT:
		lock_resets += 1
		lock_timer = GameConstants.LOCK_DELAY
	state = State.LOCKING


func _hold() -> void:
	if not can_hold:
		return
	can_hold = false
	var prev := hold_kind
	hold_kind = current.kind
	Sfx.play("hold")
	if prev < 0:
		state = State.SPAWN
	else:
		current = Piece.new(prev, 0, GameConstants.SPAWN_X, GameConstants.SPAWN_Y)
		if board.collides(current):
			_game_over()
			return
		var drop := current.duplicate_piece()
		drop.y += 1
		if not board.collides(drop):
			current.y += 1
		gravity_accum = 0.0
		lock_timer = GameConstants.LOCK_DELAY
		lock_resets = 0
		lowest_row = current.max_y()
		last_rotated = false
		state = State.FALLING
	stats_changed.emit()


func _hard_drop() -> void:
	var dist := 0
	while true:
		var p := current.duplicate_piece()
		p.y += 1
		if board.collides(p):
			break
		current.y += 1
		dist += 1
	scores.award_drop(true, dist)
	Sfx.play("drop")
	_lock()


func ghost_piece() -> Piece:
	if current == null:
		return null
	var g := current.duplicate_piece()
	while true:
		var p := g.duplicate_piece()
		p.y += 1
		if board.collides(p):
			break
		g.y += 1
	return g


func _lock() -> void:
	if current == null:
		return
	var tspin := TSpin.detect(board, current, last_kicked, last_kick_index, last_rotated)
	if board.locked_above_visible(current):
		board.lock_piece(current)
		_game_over()
		return
	board.lock_piece(current)
	Sfx.play("lock")
	var rows := board.full_rows()
	var perfect := false
	if not rows.is_empty():
		## Perfect clear is evaluated after the rows are removed.
		var snapshot := Board.new()
		snapshot.cells = []
		for row in board.cells:
			snapshot.cells.append(row.duplicate())
		snapshot.clear_rows(rows)
		perfect = snapshot.is_perfect_clear()
	var info: Dictionary = scores.award_lock(rows.size(), tspin, perfect)
	current = null
	if rows.is_empty():
		state = State.ARE
		are_timer = GameConstants.ARE_TIME
		stats_changed.emit()
		return
	pending_rows = rows
	flash_rows = rows.duplicate()
	line_timer = GameConstants.LINE_CLEAR_TIME
	state = State.LINE_CLEAR
	var is_tetris: bool = rows.size() >= 4
	if is_tetris:
		Sfx.play("tetris")
		shake = 1.0
	else:
		Sfx.play("line")
	if str(info.name) != "":
		toast = str(info.name)
		toast_timer = 1.2
	line_cleared.emit(rows, str(info.name), is_tetris)
	stats_changed.emit()


func _game_over() -> void:
	state = State.GAME_OVER
	Sfx.play("game_over")
	HighScores.consider(scores.score, scores.lines, scores.level)
	topped_out.emit()
	stats_changed.emit()
