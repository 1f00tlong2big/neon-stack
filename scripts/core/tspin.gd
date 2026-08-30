class_name TSpin
extends RefCounted

## 3-corner T-spin with pointing-side Mini. Corners are the 4 diagonals
## around the T center, which is cell (1, 1) in the 4x4 box in every state.


static func detect(board: Board, piece: Piece, kicked: bool, kick_index: int, rotated: bool) -> String:
	if piece.kind != GameConstants.Kind.T or not rotated:
		return ""
	var cx := piece.x + 1
	var cy := piece.y + 1
	var corners := [
		Vector2i(cx - 1, cy - 1),
		Vector2i(cx + 1, cy - 1),
		Vector2i(cx - 1, cy + 1),
		Vector2i(cx + 1, cy + 1),
	]
	var filled := 0
	var bits: Array[bool] = []
	for p in corners:
		var occ := board.occupied(p.x, p.y)
		bits.append(occ)
		if occ:
			filled += 1
	if filled < 3:
		return ""

	## Front (pointing-side) corners by rotation: 0 up, 1 right, 2 down, 3 left.
	var front_a := 0
	var front_b := 0
	match piece.rotation:
		0:
			front_a = 0
			front_b = 1
		1:
			front_a = 1
			front_b = 3
		2:
			front_a = 2
			front_b = 3
		3:
			front_a = 0
			front_b = 2

	var both_front: bool = bits[front_a] and bits[front_b]
	## Kick test 5 (index 4) is the T-spin triple kick — always a full T-spin.
	if kick_index >= 4 and kicked:
		return "full"
	if filled == 4 or both_front:
		return "full"
	return "mini"
