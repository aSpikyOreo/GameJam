extends Area2D

export (float) var speed = 200
var tileSize = 32
var pos
var player
var tileMap
var visionMap
var cought = false
export (PoolVector2Array) var points
export (int) var vision = 2
var currentPoint = 0
var prevPos

func _ready():
	pos = points[0]
	position = grid_to_pos(pos)
	prevPos = pos
	player = get_node("/root/Main/Player")
	tileMap = get_node("/root/Main/Level")
	visionMap = get_node("/root/Main/Vision")
	pass

func _process(delta):
	var canMove = false
	prevPos = pos_to_grid(position)
	if (!cought):
		canMove = move_enemy(delta)
	if (canMove):
		var prevPoint = pos
		currentPoint += 1
		if (currentPoint >= points.size()):
			currentPoint = 0
		pos = points[currentPoint]
	if (prevPos != pos_to_grid(pos)):
		update_vision(prevPos)
	if (can_see_player()):
		cought = true
	pass

func move_enemy(delta):
	var targetPos = (pos * tileSize) + Vector2(tileSize/2, tileSize/2)
	var moveVector = (targetPos - position).normalized()
	if (position.distance_to(targetPos) <= (moveVector * delta * speed).length()):
		position = targetPos
		return true
	else:
		position += moveVector * delta * speed
		return false

func can_see_player():
	var currentPos = pos_to_grid(position)
	var see = false
	if (currentPos == player.pos):
		see = true
	var i = 1
	while (i <= vision && !see && player.valid_move(currentPos.x - i, currentPos.y)):
		currentPos + Vector2(-i, 0)
		see = currentPos + Vector2(-i, 0) == player.pos
		i += 1
	i = 1
	while (i <= vision && !see && player.valid_move(currentPos.x + i, currentPos.y)):
		see = currentPos + Vector2(i, 0) == player.pos
		i += 1
	i = 1
	while (i <= vision && !see && player.valid_move(currentPos.x, currentPos.y - i)):
		see = currentPos + Vector2(0, -i) == player.pos
		i += 1
	i = 1
	while (i <= vision && !see && player.valid_move(currentPos.x, currentPos.y + i)):
		see = currentPos + Vector2(0, i) == player.pos
		i += 1
	return see

func update_vision(prevPos):
	var currentPos = pos_to_grid(position)
	var i = 1
	while (i <= vision):
		visionMap.set_cellv(prevPos + Vector2(-i, 0), -1)
		visionMap.set_cellv(prevPos + Vector2(i, 0), -1)
		visionMap.set_cellv(prevPos + Vector2(0, -i), -1)
		visionMap.set_cellv(prevPos + Vector2(0, i), -1)
		i += 1
	i = 1
	visionMap.set_cellv(currentPos, 0)
	while (i <= vision && player.valid_move(currentPos.x - i, currentPos.y)):
		visionMap.set_cellv(currentPos + Vector2(-i, 0), 0)
		i += 1
	i = 1
	while (i <= vision && player.valid_move(currentPos.x + i, currentPos.y)):
		visionMap.set_cellv(currentPos + Vector2(i, 0), 0)
		i += 1
	i = 1
	while (i <= vision && player.valid_move(currentPos.x, currentPos.y - i)):
		visionMap.set_cellv(currentPos + Vector2(0, -i), 0)
		i += 1
	i = 1
	while (i <= vision && player.valid_move(currentPos.x, currentPos.y + i)):
		visionMap.set_cellv(currentPos + Vector2(0, i), 0)
		i += 1

func grid_to_pos(grid):
	return grid * 32 + Vector2(tileSize/2, tileSize/2)

func pos_to_grid(pos):
	var grid = (pos - Vector2(tileSize/2, tileSize/2)) / 32
	return Vector2(int(grid.x), int(grid.y))