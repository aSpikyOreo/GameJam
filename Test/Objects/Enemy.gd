extends Area2D

export (float) var speed = 200
var tileSize = 32
var pos
var player
var cought = false

func _ready():
	pos = Vector2(6, -6)
	player = get_node("/root/Main/Player")
	pass

func _process(delta):
	var canMove = false
	if (!cought):
		canMove = move_enemy(delta)
	if (canMove && pos == Vector2(6, -6)):
		pos = Vector2(6, 4)
	elif (canMove && pos == Vector2(6, 4)):
		pos = Vector2(6, -6)
	if (player.pos == pos_to_grid(position)):
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

func grid_to_pos(grid):
	return grid * 32 + Vector2(tileSize/2, tileSize/2)

func pos_to_grid(pos):
	var grid = (pos - Vector2(tileSize/2, tileSize/2)) / 32
	return Vector2(int(grid.x), int(grid.y))