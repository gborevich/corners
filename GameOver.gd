extends Node2D

func _ready():
	$Label.text = get_node("/root/Global").win_text  
	

func _process(delta):
	pass


func _on_Button_pressed():
	get_tree().change_scene("res://Main.tscn")
