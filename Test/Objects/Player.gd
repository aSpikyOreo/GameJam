extends Area2D

export (int) var tileSize = 32
export (int) var levelTime = 50.0
export (float) var zoomChange = 0.1
export (Vector2) var zoomInit = Vector2(0.55, 0.55)
export (float) var speed = 200
export (Vector2) var pos = Vector2(0, 0)
export (String) var nextLevel
export (AudioStreamSample) var music
enum TILE { WALL, DOOR, DOOROPEN, LOCKEDDOORRED, DOOROPENRED, LOCKEDDOORBLUE, DOOROPENBLUE, REDKEY, BLUEKEY, LEVELCOMPLETE,
            SENSOR, COLLECTABLE, BOX }
enum ANIM { DOWN, RIGHT = 2, UP = 4, LEFT = 6 }
var blueKeyCount = 0
var redKeyCount = 0
var score = 0
export (int) var blueKeysTotal = 0
export (int) var redKeysTotal = 0
export (int) var collectablesTotal = 0
var collectableCount = 0
var hasBox = false
var canMove
var currentFrame = 0
var prevDir = Vector2(0, 0)
var dir = Vector2(0, 0)
var sound_begin_level
var sound_success
var sound_unlock
var sound_keys
var sound_door
var sound_loss
var sound_coin

func _ready():
	position = grid_to_pos(pos)
	$ScoreTimer.wait_time = levelTime
	$Camera2D.zoom = zoomInit
	$Camera2D/Hud.setScore(0)
	$Camera2D/Hud.setRedKeys(0)
	$Camera2D/Hud.setBlueKeys(0)
	$Camera2D/Hud.setRedKeysTotal(redKeysTotal)
	$Camera2D/Hud.setBlueKeysTotal(blueKeysTotal)
	$Camera2D/Hud.setCollectablesTotal(collectablesTotal)
	sound_begin_level = load("res://Assets/Sounds/begin_level.wav")
	sound_success = load("res://Assets/Sounds/success.wav")
	sound_unlock = load("res://Assets/Sounds/unlock.wav")
	sound_keys = load("res://Assets/Sounds/keys.wav")
	sound_loss = load("res://Assets/Sounds/loss.wav")
	sound_door = load("res://Assets/Sounds/door.wav")
	sound_coin = load("res://Assets/Sounds/coin.wav")
	$MusicStreamPlayer.stream = music
	$MusicStreamPlayer.play()
	$AudioStreamPlayer.stream = sound_begin_level
	$AudioStreamPlayer.play()
	pass

func _process(delta):
	canMove = move_player(delta)
	if (canMove):
		if (Input.is_action_pressed("up")):
			if (valid_move(pos.x + dir.x, pos.y - 1 + dir.x)):
				dir += Vector2(0, -1)
		if (Input.is_action_pressed("down")):
			if (valid_move(pos.x + dir.x, pos.y + 1 + dir.y)):
				dir += Vector2(0, 1)
		if (Input.is_action_pressed("left")):
			if (valid_move(pos.x - 1 + dir.x, pos.y + dir.y)):
				dir += Vector2(-1, 0)
		if (Input.is_action_pressed("right")):
			if (valid_move(pos.x + 1 + dir.x, pos.y + dir.y)):
				dir += Vector2(1, 0)
		if (prevDir != dir):
			if (dir == Vector2(0, 0)):
				$Sprite.frame = DOWN
				currentFrame = DOWN
				pos = rpos_to_grid(position)
			elif (dir == Vector2(0, -1)):
				$Sprite.frame = UP
				currentFrame = UP
			elif (dir == Vector2(0, 1)):
				$Sprite.frame = DOWN
				currentFrame = DOWN
			elif (dir.x == -1):
				$Sprite.frame = LEFT
				currentFrame = LEFT
			elif (dir.x == 1):
				$Sprite.frame = RIGHT
				currentFrame = RIGHT
			if (hasBox):
				if (dir != Vector2(0, 0)):
					$Sprite.frame += 8
					currentFrame += 8
				else:
					$Sprite.frame = 16
					currentFrame = 16
		pos += dir
		
		if (Input.is_action_just_pressed("interact")):
			try_interact(pos.x, pos.y - 1)
			try_interact(pos.x, pos.y + 1)
			try_interact(pos.x - 1, pos.y)
			try_interact(pos.x + 1, pos.y)
		try_pickup(pos.x, pos.y)
		prevDir = dir
		dir = Vector2(0, 0)
	pass

func _input(event):
	if event is InputEventMouseButton:
	    if event.is_pressed():
	        if event.button_index == BUTTON_WHEEL_UP && $Camera2D.zoom.x > 0.1:
	            $Camera2D.zoom -= Vector2(zoomChange, zoomChange)
	        if event.button_index == BUTTON_WHEEL_DOWN && $Camera2D.zoom.x < 1.8:
	            $Camera2D.zoom += Vector2(zoomChange, zoomChange)

func move_player(delta):
	var targetPos = (pos * tileSize) + Vector2(tileSize/2, tileSize/2)
	var moveVector = (targetPos - position).normalized()
	if (position.distance_to(targetPos) > tileSize/2):
		$Sprite.frame = currentFrame + 1
	else:
		$Sprite.frame = currentFrame
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
	elif (cell == BOX && !hasBox):
		canMove = true
	return canMove

func try_interact(x, y):
	var xFlip = get_parent().get_child(0).is_cell_x_flipped(x, y)
	var yFlip = get_parent().get_child(0).is_cell_y_flipped(x, y)
	var trans = get_parent().get_child(0).is_cell_transposed(x, y)
	var cell = get_parent().get_child(0).get_cell(x, y) 
	if (cell == DOOR):
		get_parent().get_child(0).set_cell(x, y, DOOROPEN, xFlip, yFlip, trans)
		$AudioStreamPlayer.stream = sound_door
		$AudioStreamPlayer.play()
	elif (cell == DOOROPEN):
		get_parent().get_child(0).set_cell(x, y, DOOR, xFlip, yFlip, trans)
		$AudioStreamPlayer.stream = sound_door
		$AudioStreamPlayer.play()
	elif (cell == LOCKEDDOORRED && redKeyCount > 0):
		get_parent().get_child(0).set_cell(x, y, DOOROPENRED, xFlip, yFlip, trans)
		redKeyCount -= 1
		redKeysTotal -= 1
		score += 15
		$AudioStreamPlayer.stream = sound_unlock
		$AudioStreamPlayer.play()
		$Camera2D/Hud.setScore(score)
		$Camera2D/Hud.setRedKeys(redKeyCount)
		$Camera2D/Hud.setRedKeysTotal(redKeysTotal)
	elif (cell == LOCKEDDOORBLUE && blueKeyCount > 0):
		get_parent().get_child(0).set_cell(x, y, DOOROPENBLUE, xFlip, yFlip, trans)
		blueKeyCount -= 1
		blueKeysTotal -= 1
		score += 20
		$AudioStreamPlayer.stream = sound_unlock
		$AudioStreamPlayer.play()
		$Camera2D/Hud.setScore(score)
		$Camera2D/Hud.setBlueKeys(blueKeyCount)
		$Camera2D/Hud.setBlueKeysTotal(blueKeysTotal)
	elif (cell == REDKEY):
		get_parent().get_child(0).set_cell(x, y, -1)
		redKeyCount += 1
		score += 5
		$AudioStreamPlayer.stream = sound_keys
		$AudioStreamPlayer.play()
		$Camera2D/Hud.setScore(score)
		$Camera2D/Hud.setRedKeys(redKeyCount)
	elif (cell == BLUEKEY):
		get_parent().get_child(0).set_cell(x, y, -1)
		blueKeyCount += 1
		score += 10
		$AudioStreamPlayer.stream = sound_keys
		$AudioStreamPlayer.play()
		$Camera2D/Hud.setScore(score)
		$Camera2D/Hud.setBlueKeys(blueKeyCount)

func try_pickup(x, y):
	var cell = get_parent().get_child(0).get_cell(x, y) 
	if (cell == REDKEY):
		get_parent().get_child(0).set_cell(x, y, -1)
		redKeyCount += 1
		score += 5
		$AudioStreamPlayer.stream = sound_keys
		$AudioStreamPlayer.play()
		$Camera2D/Hud.setScore(score)
		$Camera2D/Hud.setRedKeys(redKeyCount)
	elif (cell == BLUEKEY):
		get_parent().get_child(0).set_cell(x, y, -1)
		blueKeyCount += 1
		score += 10
		$AudioStreamPlayer.stream = sound_keys
		$AudioStreamPlayer.play()
		$Camera2D/Hud.setScore(score)
		$Camera2D/Hud.setBlueKeys(blueKeyCount)
	elif (cell == COLLECTABLE):
		get_parent().get_child(0).set_cell(x, y, -1)
		collectableCount += 1
		score += 100
		$AudioStreamPlayer.stream = sound_coin
		$AudioStreamPlayer.play()
		$Camera2D/Hud.setScore(score)
		$Camera2D/Hud.setCollectables(collectableCount)
	elif (cell == BOX):
		get_parent().get_child(0).set_cell(x, y, -1)
		hasBox = true
	elif (cell == LEVELCOMPLETE):
		score += int($ScoreTimer.time_left) * 5
		if (collectableCount == collectablesTotal):
			score += 250
		$AudioStreamPlayer.stream = sound_success
		$AudioStreamPlayer.play()
		$Camera2D/Hud.setScore(score)
		$Camera2D/Hud.levelComplete(score, nextLevel)
		get_tree().paused = true

func cought():
	$AudioStreamPlayer.stream = sound_loss
	$AudioStreamPlayer.play()
	$Camera2D/Hud.gameOver()
	get_tree().paused = true

func grid_to_pos(grid):
	return grid * 32 + Vector2(tileSize/2, tileSize/2)

func pos_to_grid(pos):
	var grid = (pos - Vector2(tileSize/2, tileSize/2)) / 32
	return Vector2(int(grid.x), int(grid.y))
func rpos_to_grid(pos):
	var grid = (pos - Vector2(tileSize/2, tileSize/2)) / 32
	return Vector2(round(grid.x), round(grid.y))