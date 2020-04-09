extends Node2D

var score = 0
var winners
var advance = 0

func _ready():
	score = get_node("/root/Global").score
	advance = get_node("/root/Global").advance
	if score != 0: # the game is over
		$MainMenu.visible = false
		$HallPanel.visible = true
		$NameInput.visible = true
		$NameInput/CongratulationPanel/Label.text = get_node("/root/Global").win_text + " Score: " + var2str(score) + " A: " + var2str(advance)
		winners = _load_winners()
	else: # appear as initial screen
		$MainMenu.visible = true
		$HallPanel.visible = false
		$NameInput.visible = false


func _on_NewGame_pressed():
	get_tree().change_scene("Main.tscn")


func _on_Quit_pressed():
	get_tree().quit() # Replace with function body.


func _on_TheHallOfGlory_pressed():
	$MainMenu.visible = false
	$HallPanel.visible = true
	$HallPanel/NameLabel.text = ""
	$HallPanel/ScoreLabel.text = ""
	$NameInput.visible = false
	_load_winners()
	
	
func _load():
	var content_array_parsed = []
	var content_array_temp = []
	var file = File.new()
	file.open("res://save_game.dat", File.READ)
	var content = file.get_as_text()
	file.close()
	var content_array = content.split ("\n", true, 0)
	for row in range(content_array.size()):
		content_array_temp.append(content_array[row].split(" : ", false, 0))
		content_array_parsed.append([content_array_temp[row][0], str2var(content_array_temp[row][1]), str2var(content_array_temp[row][2])])
	return content_array_parsed


func _on_Button_pressed():
	$MainMenu.visible = true
	$HallPanel.visible = false
	$NameInput.visible = false


func _on_TextEdit_mouse_entered():
	if $NameInput/TextEdit.text == "Enter your name":
		$NameInput/TextEdit.text = ""


func _correct_name(input): 
	while input.find("\n")!= -1:
		input.erase(input.find("\n"), 2)	
	while input.find(" : ") != -1:
		input.erase(input.find(" : "), 2)
	return input


func _on_SaveButton_pressed():
	var winner_name = $NameInput/TextEdit.text
	winner_name = _correct_name(winner_name)
	winners.append([winner_name, score, advance])
	winners = _sort_array(winners)
	_save_winners(winners)
	winners = _load_winners()
	$NameInput.visible = false


func _sort_array(input_array):
	var temp_array = [0]
	var sorted_array = []
	var size	
	if input_array.size() < 10: # limit output size if necessary
		size = input_array.size()
	else:
		size = 10
	temp_array.resize(input_array.size())
	for row in range(input_array.size()):
		temp_array[row] = input_array[row][2]	
	for i in range(input_array.size()):
		for row in range(temp_array.size()):
			if (temp_array[row] == temp_array.min()):
				sorted_array.append([input_array[row][0],var2str(input_array[row][1]),var2str(input_array[row][2])])
				temp_array[row] = 9999
	sorted_array.resize(size)
	return sorted_array


func _load_winners():
	var winners_text = ""
	winners = _load()
	$HallPanel/NameLabel.text = ""
	$HallPanel/ScoreLabel.text = ""
	for row in winners.size():
		$HallPanel/NameLabel.add_text(winners[row][0] + "\n")
		$HallPanel/ScoreLabel.append_bbcode("[right] S: " + var2str(winners[row][1]) + " A: " + var2str(winners[row][2]) + "[/right]")
	return winners


func _save_winners(input_array):
	var file = File.new()
	var size
	var content = ""
	if input_array.size() < 10:
		size = input_array.size()
	else:
		size = 10
	for row in range(size):
		content += input_array[row][0] + " : {str} : {str2}".format({"str": input_array[row][1], "str2": input_array[row][2]})
		if row != size - 1:
			content += "\n"
	file.open("res://save_game.dat", File.WRITE)
	file.store_string(content)
	file.close()
