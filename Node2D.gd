extends Node2D

var win_text = ""
var score = 0
var advance 
var best_jump
var matrix = [
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],] 
var possible_moves_matrix = [
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],] 

func _ready():
	pass # Replace with function body.


func calculate_advance(input_matrix):

	var metric = 0
	var metric_temp
	var best_fig
	var best_move
	var best_move_temp
	var figures = []
	var count = 0 
		
	if score % 2 == 1: # if blue win
		matrix = rotate_matrix(input_matrix)
	else:
		matrix = invert_matrix(input_matrix)

	advance = 0
	while count == 0:
		figures = []
		metric = 0
		best_fig = Vector2(0,0)
		best_move = Vector2(0,0)
		for x in 8: # fill in the figures group 
			for y in 8:
				if matrix[x][y] == 1:
					figures.append(Vector2(x,y))
	
		for fig in figures: # find the best move among all figures
			best_move_temp = _best_move(fig)
			metric_temp = (best_move_temp - fig).length()
			if metric < metric_temp:
				best_fig = fig
				best_move = best_move_temp
				metric = metric_temp

		matrix[best_fig.x][best_fig.y] = 0 # implement the move
		matrix[best_move.x][best_move.y] = 1
		advance += 1
		
		count = 1
		for x in 3: # check if all the figures reached the corner
			for y in 3:
				count *= matrix[x][y]
		
	return advance
		
			
func _best_move(pos): # calculate possible moves 

	var metric = 0
	var metric_temp 
	var best_move = pos
	best_jump = pos
	var target_cell = Vector2(0,0)
	possible_moves_matrix = [
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],] 
	
	
	for x in range(pos.x - 1, pos.x + 2): # find best step
		for y in range(pos.y - 1, pos.y + 2): 
			if x in range (8) and y in range (8):
				if matrix[x][y] == 0:
					possible_moves_matrix[x][y] = 1
					possible_moves_matrix[pos.x][pos.y] = 1
					metric_temp = move_metric(pos, Vector2(x,y))
					if metric < metric_temp: 
						metric = metric_temp
						best_move = Vector2(x,y)
	
	best_jump = _best_jump(pos) # find best jump
	metric_temp = move_metric(pos, best_jump)
	if metric < metric_temp: # compare the best step and the best jump
		metric = metric_temp
		best_move = best_jump
	return best_move
	
func _best_jump(pos): # calculate the best jump/series for figure

	var metric = 0
	var metric_temp 
	var x_to_jump 
	var y_to_jump 
	
	for x in range(pos.x - 1, pos.x + 2): # find possible jumps from current position
		for y in range(pos.y - 1, pos.y + 2):
			x_to_jump = 2 * x - pos.x
			y_to_jump = 2 * y - pos.y
			if x_to_jump in range (8) and y_to_jump in range (8) \
			and matrix[x][y] != 0 \
			and matrix[x_to_jump][y_to_jump] == 0 \
			and possible_moves_matrix[x_to_jump][y_to_jump] == 0:
				possible_moves_matrix[x_to_jump][y_to_jump] = 1
				metric_temp = move_metric(pos, Vector2(x_to_jump,y_to_jump))
				if metric < metric_temp: 
					metric = metric_temp
					best_jump = Vector2(x_to_jump,y_to_jump)
				best_jump = _best_jump(best_jump) # find possible jumps for found possitions to jump
	
	return best_jump
	
	
func move_metric(cell_from, cell_to): # metric to select moves
	var move_metric = 1
	var cell_weight = 0
	var target_cell = Vector2(0,0)
	if cell_from.x > 2 or cell_from.y > 2: # other metric for figures in the corner
		for x in 3:
			for y in 3:
				if matrix[x][y] == 0:
					if cell_weight < 1.0 / (x + y + 1.0):
						if x > y: # to add weight assymetrically to cells in closer to figure sector
							cell_weight = 1.0 / (x / 2.0 + y + 1.0)
						else:
							cell_weight = 1.0 / (x + y / 2.0 + 1.0)
						target_cell = Vector2(x,y)
		move_metric = (cell_from - target_cell).length() - (cell_to - target_cell).length()
	else:
		move_metric = cell_from.length() - cell_to.length()
	
	return move_metric

func rotate_matrix(input_matrix):
	var rotated_matrix = [
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],] 
	
	for x in 8:
		for y in 8:
			rotated_matrix[x][y] = input_matrix[7-x][7-y]
		
	return rotated_matrix


func invert_matrix(input_matrix):
	var inverted_matrix = [
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],] 
	
	for x in 8:
		for y in 8:
			if input_matrix[x][y] == 1:
				inverted_matrix[x][y] = 2
			elif input_matrix[x][y] == 2:
				inverted_matrix[x][y] = 1
		
	return inverted_matrix
