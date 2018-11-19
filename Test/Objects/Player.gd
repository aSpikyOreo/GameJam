extends Area2D

export (int) var tileSize = 32
export (float) var zoomChange = 0.1
export (float) var speed = 400
var pos = Vector2(0, 0)

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	var canMove = move_player(delta)
	if (canMove && Input.is_action_just_pressed("up") && get_parent().get_child(0).get_cell(pos.x, pos.y - 1) == -1):
		pos += Vector2(0, -1)
	if (canMove && Input.is_action_just_pressed("down") && get_parent().get_child(0).get_cell(pos.x, pos.y + 1) == -1):
		pos += Vector2(0, 1)
	if (canMove && Input.is_action_just_pressed("left") && get_parent().get_child(0).get_cell(pos.x - 1, pos.y) == -1):
		pos += Vector2(-1, 0)
	if (canMove && Input.is_action_just_pressed("right") && get_parent().get_child(0).get_cell(pos.x + 1, pos.y) == -1):
		pos += Vector2(1, 0)
	
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
