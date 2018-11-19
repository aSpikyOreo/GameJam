extends Area2D

export (int) var tileSize = 32
export (float) var zoomChange = 0.1
export (float) var speed = 400
var pos = Vector2(0, 0)
enum TILE { WALL, DOOR, DOOROPEN }

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
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
	elif (cell == DOOR):
		canMove = false
	return canMove

func try_interact(x, y):
	var xFlip = get_parent().get_child(0).is_cell_x_flipped(x, y)
	var yFlip = get_parent().get_child(0).is_cell_y_flipped(x, y)
	var trans = get_parent().get_child(0).is_cell_transposed(x, y)
	if (get_parent().get_child(0).get_cell(x, y) == DOOR):
		get_parent().get_child(0).set_cell(x, y, DOOROPEN, xFlip, yFlip, trans)
	elif (get_parent().get_child(0).get_cell(x, y) == DOOROPEN):
		get_parent().get_child(0).set_cell(x, y, DOOR, xFlip, yFlip, trans)
		
