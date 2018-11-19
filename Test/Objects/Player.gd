extends Area2D

export (int) var tileSize = 32
export (float) var zoomChange = 0.1
export (float) var speed = 400
export (Vector2) var pos = Vector2(0, 0)
enum TILE { WALL, DOOR, DOOROPEN, LOCKEDDOORRED, DOOROPENRED, LOCKEDDOORBLUE, DOOROPENBLUE, REDKEY, BLUEKEY, LEVELCOMPLETE,
            SENSOR, COLLECTABLE }
var blueKeyCount = 0
var redKeyCount = 0
var collectableCount = 0

func _ready():
	position = grid_to_pos(pos)
	pass

func _process(delta):
	var canMove = move_player(delta)
	if (canMove && Input.is_action_just_pressed("up")):
		if (valid_move(pos.x, pos.y - 1)):
			pos += Vector2(0, -1)
	if (canMove && Input.is_action_just_pressed("down")):
		if (valid_move(pos.x, pos.y + 1)):
			pos += Vector2(0, 1)
	if (canMove && Input.is_action_just_pressed("left")):
		if (valid_move(pos.x - 1, pos.y)):
			pos += Vector2(-1, 0)
	if (canMove && Input.is_action_just_pressed("right")):
		if (valid_move(pos.x + 1, pos.y)):
			pos += Vector2(1, 0)

	if (canMove && Input.is_action_just_pressed("interact")):
		try_interact(pos.x, pos.y - 1)
		try_interact(pos.x, pos.y + 1)
		try_interact(pos.x - 1, pos.y)
		try_interact(pos.x + 1, pos.y)
	if (canMove):
		try_pickup(pos.x, pos.y)
	pass

func _input(event):
	if event is InputEventMouseButton:
	    if event.is_pressed():
	        if event.button_index == BUTTON_WHEEL_UP:
	            $Camera2D.zoom -= Vector2(zoomChange, zoomChange)
	        if event.button_index == BUTTON_WHEEL_DOWN:
	            $Camera2D.zoom += Vector2(zoomChange, zoomChange)

func move_player(delta):
	var targetPos = (pos * tileSize) + Vector2(tileSize/2, tileSize/2)
	var moveVector = (targetPos - position).normalized()
	if (position.distance_to(targetPos) <= (moveVector * delta * speed).length()):
		position = targetPos
		return true
	else:
		position += moveVector * delta * speed
		return false

func valid_move(x, y):
	var cell = get_parent().get_child(0).get_cell(x, y)
	var canMove = false
	if (cell == -1):
		canMove = true
	elif (cell == DOOROPEN):
		canMove = true
	elif (cell == DOOROPENRED):
		canMove = true
	elif (cell == DOOROPENBLUE):
		canMove = true
	elif (cell == REDKEY):
		canMove = true
	elif (cell == BLUEKEY):
		canMove = true
	elif (cell == LEVELCOMPLETE):
		canMove = true
	elif (cell == SENSOR):
		canMove = true
	elif (cell == COLLECTABLE):
		canMove = true
	return canMove

func try_interact(x, y):
	var xFlip = get_parent().get_child(0).is_cell_x_flipped(x, y)
	var yFlip = get_parent().get_child(0).is_cell_y_flipped(x, y)
	var trans = get_parent().get_child(0).is_cell_transposed(x, y)
	var cell = get_parent().get_child(0).get_cell(x, y) 
	if (cell == DOOR):
		get_parent().get_child(0).set_cell(x, y, DOOROPEN, xFlip, yFlip, trans)
	elif (cell == DOOROPEN):
		get_parent().get_child(0).set_cell(x, y, DOOR, xFlip, yFlip, trans)
	elif (cell == LOCKEDDOORRED && redKeyCount > 0):
		get_parent().get_child(0).set_cell(x, y, DOOROPENRED, xFlip, yFlip, trans)
		redKeyCount -= 1
	elif (cell == LOCKEDDOORBLUE && blueKeyCount > 0):
		get_parent().get_child(0).set_cell(x, y, DOOROPENBLUE, xFlip, yFlip, trans)
		blueKeyCount -= 1
	elif (cell == REDKEY):
		get_parent().get_child(0).set_cell(x, y, -1)
		redKeyCount += 1
	elif (cell == BLUEKEY):
		get_parent().get_child(0).set_cell(x, y, -1)
		blueKeyCount += 1

func try_pickup(x, y):
	var cell = get_parent().get_child(0).get_cell(x, y) 
	if (cell == REDKEY):
		get_parent().get_child(0).set_cell(x, y, -1)
		redKeyCount += 1
	elif (cell == BLUEKEY):
		get_parent().get_child(0).set_cell(x, y, -1)
		blueKeyCount += 1
	elif (cell == COLLECTABLE):
		get_parent().get_child(0).set_cell(x, y, -1)
		collectableCount += 1
	elif (cell == LEVELCOMPLETE):
		print("LevelCompelete")

func grid_to_pos(grid):
	return grid * 32 + Vector2(tileSize/2, tileSize/2)

func pos_to_grid(pos):
	var grid = (pos - Vector2(tileSize/2, tileSize/2)) / 32
	return Vector2(int(grid.x), int(grid.y))