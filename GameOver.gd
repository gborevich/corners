extends Node2D

func _ready():
	$Label.text = get_node("/root/Global").win_text  
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
#	pass


func _on_Button_pressed():
	get_tree().change_scene("res://Main.tscn")
