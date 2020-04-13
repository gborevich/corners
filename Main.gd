extends Node2D

var selected 
var board_origin = Vector2(0,100)
var board_size 
var board_frame_thickness = 4
var pos_x
var pos_y
var new_pos
var current_pos
var old_pos = Vector2(8,8)
var score = 0
var child
var win_text = "Dummy"
var game_matrix
var game_possible_moves = [
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],] 

func _initialize_game():
	score = 0
	selected = Vector2(8,8)
	_clear_stars()
	game_matrix = [
	[2,2,2,0,0,0,0,0],
	[2,2,2,0,0,0,0,0],
	[2,2,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,2,0,1,1,1],
	[0,0,0,0,0,1,1,1],
	[0,0,0,0,0,1,1,1],
	] # 1 - red, 2 - blue
	for x in range(game_matrix.size()): # set up figures
		for y in range(game_matrix[x].size()):
			if game_matrix[x][y] == 1:
				var new_Figure = load ("res://Figure.tscn")
				child = new_Figure.instance() #new_Figure = _globalize_position(x, y)
				add_child(child)
				child.position = _globalize_position(x, y) 
				child.scale.x = 0.5
				child.scale.y = 0.5
				child.frame = 0
				child.add_to_group("red")
				child.add_to_group("figures")
			elif game_matrix[x][y] == 2:
				var new_Figure = load ("res://Figure.tscn")
				child = new_Figure.instance()#new_Figure = _globalize_position(x, y)
				add_child(child)
				child.position = _globalize_position(x, y) 
				child.scale.x = 0.5
				child.scale.y = 0.5
				child.frame = 2
				child.add_to_group("blue")
				child.add_to_group("figures")
	
func _on_RestartButton_pressed():
	for child in self.get_children():
		if child.is_in_group("figures"):
			child.free()
	_initialize_game()
	
func _localize_position(event): # transform global position to board coordinates
	pos_x = ceil((event.x - board_origin.x) / ((board_size.x - 2 * board_frame_thickness) / 8)) - 1
	pos_y = ceil((event.y - board_origin.y)/ ((board_size.y - 2 * board_frame_thickness) / 8)) - 1
	return Vector2(pos_x, pos_y)

func _globalize_position(pos_x, pos_y): # to get global position from board coordinates
	pos_x = board_origin.x + (pos_x + 0.5) * ((board_size.x - 2 * board_frame_thickness) / 8) + board_frame_thickness
	pos_y = board_origin.y + (pos_y + 0.5) * ((board_size.y - 2 * board_frame_thickness) / 8) + board_frame_thickness
	return Vector2(pos_x, pos_y)

func _find_by_coordinates(pos_x,pos_y): # find the instance on the given position
	for child in self.get_children():
		if child.is_in_group("figures")\
		and _localize_position(child.position).x == pos_x \
		and _localize_position(child.position).y == pos_y:
			return child

func _clear_stars():
	var s
	for s in self.get_children():
		if s.is_in_group("stars"):
			s.free()

func _can_move(child):
	var s
	var sprite = preload("res://Star.tscn")
	_clear_stars()
	for x in range(game_matrix.size()):
		for y in range(game_matrix[x].size()):
			game_possible_moves[x][y] = 0
	current_pos = _localize_position(child.position)
	for x in range(current_pos.x-1, current_pos.x + 2):
		for y in range(current_pos.y-1, current_pos.y + 2):
			if x in range (8) and y in range (8):
				if game_matrix[x][y] == 0:
					game_possible_moves[x][y] = 1
					s = sprite.instance()
					add_child(s)
					s.position = _globalize_position(x,y)
					s.add_to_group("stars")

func _can_jump(child):
	var s
	var sprite = preload("res://Star.tscn")
	current_pos = _localize_position(child.position)
	for x in range(current_pos.x-1, current_pos.x + 2):
		for y in range(current_pos.y-1, current_pos.y + 2):
			if x in range (8) and y in range (8) \
			and ((2 * x - current_pos.x) in range (8)) \
			and ((2 * y - current_pos.y) in range (8)) \
			and (game_matrix[x][y] != 0) and ((x != current_pos.x) or (y != current_pos.y)):
				game_possible_moves[2 * x - current_pos.x][2 * y - current_pos.y] = 1
				s = sprite.instance()
				add_child(s)
				s.position = _globalize_position(2 * x - current_pos.x,2 * y - current_pos.y)
				s.add_to_group("stars")

func _move_completed():
	child.frame -= 1
	selected = Vector2(8,8)
	_clear_stars()
	var count = 0
	for x in range(3):
		for y in range(3):
			if game_matrix[x][y] == 2:
				count += 1
	if count == 9:
		get_node("/root/Global").win_text = "Blue win!"
		_game_over()
	
	count = 0
	for x in range(5,8):
		for y in range(5,8):
			if game_matrix[x][y] == 1:
				count += 1
	if count == 9:
		get_node("/root/Global").win_text = "Red win!"
		_game_over()
	score += 1

	
func _game_over():
	get_tree().change_scene("Menu.tscn")
	get_node("/root/Global").score = score
	get_node("/root/Global").advance = get_node("/root/Global").calculate_advance(game_matrix)

# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _on_Board_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed	and event.button_index == BUTTON_LEFT:
		current_pos = _localize_position(event.position)
		if game_matrix[current_pos.x][current_pos.y] == score % 2 + 1: # click on figure
			child = _find_by_coordinates(current_pos.x,current_pos.y)
			if selected.x >= 8 and selected.y >= 8: # the figure is not selected one
				selected = _localize_position(child.position) # select the figure and calculate possible moves
				old_pos = selected
				child.frame += 1 
				_can_move(child)
				_can_jump(child)
				old_pos = current_pos
			elif selected == current_pos and (current_pos - old_pos).length() != 0:
				_move_completed()
			else: # the figure is already selected
				_find_by_coordinates(selected.x,selected.y).frame -= 1 #снимаем выделение со старой
				_find_by_coordinates(selected.x,selected.y).position = _globalize_position(old_pos.x, old_pos.y)
				game_matrix[selected.x][selected.y] = 0
				game_matrix[old_pos.x][old_pos.y] = score % 2 + 1
				_clear_stars()
				selected = _localize_position(child.position) # выделяем новую
				child.frame += 1
				_can_move(child)
				_can_jump(child)
				old_pos = current_pos
		elif game_matrix[current_pos.x][current_pos.y] == 0 \
		and current_pos.x in range (8) and current_pos.y in range (8) \
		and game_possible_moves[current_pos.x][current_pos.y] == 1 \
		and selected.x < 8 and selected.y < 8: # move the figure
			child = _find_by_coordinates(selected.x,selected.y)
			child.position = _globalize_position(current_pos.x,current_pos.y)
			game_matrix[selected.x][selected.y] = 0
			game_matrix[current_pos.x][current_pos.y] = score % 2 + 1
			selected = current_pos
			_clear_stars()
			if current_pos == old_pos: # the figure didn't move
				_can_move(child)
				_can_jump(child)
			elif (old_pos - current_pos).length() >= 2: # the figure jumped
				_can_jump(child)
			
func _ready():
	board_size = $Board/Background.get_rect().size * $Board/Background.scale 
	$Board/Background.centered = false
	$Board.position = board_origin
	OS.window_size = board_size + board_origin
	_initialize_game()
	
func _process(delta):
	$ScoreDisplay.text = "Score: " + var2str(score)
	if score % 2 == 0:
		$TurnDisplay.text = "Now moves: red"
	else:
		$TurnDisplay.text = "Now moves: blue"



