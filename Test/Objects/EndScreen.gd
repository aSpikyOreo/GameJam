extends CanvasLayer

export (PoolStringArray) var level

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	if (Input.is_key_pressed(KEY_0)):
		get_tree().change_scene("res://Objects/" + level[0] +".tscn")
	elif (Input.is_key_pressed(KEY_1)):
		get_tree().change_scene("res://Objects/" + level[1] +".tscn")
	elif (Input.is_key_pressed(KEY_2)):
		get_tree().change_scene("res://Objects/" + level[2] +".tscn")
	elif (Input.is_key_pressed(KEY_3)):
		get_tree().change_scene("res://Objects/" + level[3] +".tscn")
	elif (Input.is_key_pressed(KEY_4)):
		get_tree().change_scene("res://Objects/" + level[4] +".tscn")
	elif (Input.is_key_pressed(KEY_5)):
		get_tree().change_scene("res://Objects/" + level[5] +".tscn")
	pass
