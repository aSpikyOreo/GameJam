extends CanvasLayer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	if (Input.is_action_just_pressed("interact")):
		get_tree().change_scene("res://Objects/Level0.tscn")
	if (Input.is_action_just_pressed("ui_cancel")):
		get_tree().quit()
