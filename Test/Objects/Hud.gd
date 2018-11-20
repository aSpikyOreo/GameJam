extends CanvasLayer

var blueKeyTotal
var blueKeyCount
var redKeyTotal
var redKeyCount
var gameOver = false
var levelComplete = false
var level = ""

func _process(delta):
	if (Input.is_action_just_pressed("interact")):
		if (gameOver):
			gameOver = false
			get_tree().reload_current_scene()
		if (levelComplete):
			levelComplete = false
			get_tree().change_scene("res://Objects/" + level + ".tscn")
		get_tree().paused = false
	if (Input.is_action_just_released("interact")):
		get_tree().paused = false
	if (get_tree().paused && Input.is_action_just_pressed("ui_cancel")):
		get_tree().quit()

func setTotal(value, path):
	var i = 0
	if (value > 10):
		value = 10
	while (i < value):
		get_node(path + str(i)).visible = true
		i += 1
	while (i < 10):
		get_node(path + str(i)).visible = false
		i += 1

func setBlueKeysTotal(value):
	setTotal(value, "Keys/BlueKeysTotal")
func setBlueKeys(value):
	setTotal(value, "Keys/BlueKeys")
func setRedKeysTotal(value):
	setTotal(value, "Keys/RedKeysTotal")
func setRedKeys(value):
	setTotal(value, "Keys/RedKeys")
func setCollectablesTotal(value):
	setTotal(value, "Collectables/Total")
func setCollectables(value):
	setTotal(value, "Collectables/")

func setScore(value):
	$Score.text = "Score: " + str(value)

func gameOver():
	gameOver = true
	$GameOverRect.visible = true
	$GameOverText.visible = true
	$GameOverMessage.visible = true
func levelComplete(score, nextLevel):
	levelComplete = true
	level = nextLevel
	$LevelCompleteMessage.visible = true
	$LevelCompleteText.visible = true
	$LevelCompleteRect.visible = true
	$LevelCompleteScore.visible = true
	$LevelCompleteScore.text = "Score: " + str(score)
	
