extends Node2D

var win_text = ""
var score = 0
var advance = 0 
var matrix = [
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0],] 
var checked = []
var queue = []

func _ready():
	pass # Replace with function body.


func calculate_advance(input_matrix):
	var count_metric = 0
	var current
	var best_count_metric = 999
	var previous_metric = 0
	var priority
	var found = false
	var next_moves = []
	var goal = [Vector2(0,0),Vector2(0,1),Vector2(0,2),
		Vector2(1,0),Vector2(1,1),Vector2(1,2),
		Vector2(2,0),Vector2(2,1),Vector2(2,2)]
	var figures = []
	var count = 0 
		
	if score % 2 == 1: # if blue win
		matrix = rotate_matrix(input_matrix)
	else:
		matrix = invert_matrix(input_matrix)

	for x in 8: # convert matrix to vectors
		for y in 8:
			if matrix[x][y] == 1:
				figures.append(Vector2(x,y))
	
	checked.append([0,figures])
	queue.append([0,0,figures])
	
	while queue.size() > 0:
		current = queue[0] # get and remove next element from queue
		queue.remove(0)
		
		if goal in current: # if found setup is the goal
			if best_count_metric > current[1]: # update the best result
				best_count_metric = current[1]
			
		next_moves = discover_possible_moves(current[2]) 
		count_metric = current[1] + 1
			
		for next_move in next_moves: # check next step and add them to queue
			priority = disposition_metric(next_move) + count_metric
			previous_metric = current[0] - current[1]

			if count_metric + tiles_to_fill(next_move) < best_count_metric \
			and (previous_metric == 0 or (previous_metric - (priority - count_metric) > -0.2)): # to decline setups that make position worse : # don't consider longer than winner pathes
				found = false
				for i in checked.size(): # has the setup aready been checked?
					if next_move in checked[i]:
						found = true
						if checked[i][0] > count_metric: # update metric if it's better than previous and send to queue
							checked[i][0] = count_metric
							add_to_queue(priority, count_metric, next_move, queue)
				
				if found == false:
					checked.append([count_metric,next_move])
					add_to_queue(priority, count_metric, next_move, queue)
			else:
					checked.append([0,next_move])

	return best_count_metric
				
func discover_possible_moves(current_figures): 
	var figures_next = []
	var figures_temp = []	
	
	for fig in current_figures:
		for x in range(fig.x - 1, fig.x + 2): 
			for y in range(fig.y - 1, fig.y + 2): 
				if x in range (8) and y in range (8) \
				and !(Vector2(x,y) in current_figures):
					figures_temp = apply_move(current_figures, fig, Vector2(x,y))
					if !(figures_temp in figures_next):
						figures_next.append(figures_temp)
	discover_possible_jump(current_figures, figures_next, null)
	return figures_next
	
	
func discover_possible_jump(current_figures, figures_next, jumped_figure):
	var figures_temp = []
	var x_to_jump
	var y_to_jump
	
	if typeof(jumped_figure) == TYPE_NIL:
		for fig in current_figures:
			for x in range(fig.x - 1, fig.x + 2): 
				for y in range(fig.y - 1, fig.y + 2):
					x_to_jump = 2 * x - fig.x
					y_to_jump = 2 * y - fig.y
					if x_to_jump in range (8) and y_to_jump in range (8) \
					and Vector2(x,y) in current_figures \
					and !(Vector2(x_to_jump,y_to_jump) in current_figures):
						figures_temp = apply_move(current_figures, fig, Vector2(x_to_jump,y_to_jump))
						if !(figures_temp in figures_next):
							figures_next.append(figures_temp)
							discover_possible_jump(figures_temp, figures_next, Vector2(x_to_jump,y_to_jump))
	else:			
		for x in range(jumped_figure.x - 1, jumped_figure.x + 2): 
			for y in range(jumped_figure.y - 1, jumped_figure.y + 2):
				x_to_jump = 2 * x - jumped_figure.x
				y_to_jump = 2 * y - jumped_figure.y
				if x_to_jump in range (8) and y_to_jump in range (8) \
				and Vector2(x,y) in current_figures \
				and !(Vector2(x_to_jump,y_to_jump) in current_figures) :
					figures_temp = apply_move(current_figures, jumped_figure, Vector2(x_to_jump,y_to_jump))
					if !(figures_temp in figures_next):
						figures_next.append(figures_temp)
						discover_possible_jump(figures_temp, figures_next, Vector2(x_to_jump,y_to_jump))			
	return figures_next
	
	
func apply_move(figures_input, current_pos, new_pos):
	var new_figures = []
	for x in 8:
		for y in 8:
			if Vector2(x,y) in figures_input and Vector2(x,y) != current_pos or Vector2(x,y) == new_pos:
				new_figures.append(Vector2(x,y))
	return new_figures


func disposition_metric(figures_input):
	var metric = 0
	var cell_weight = 0
	var target_cell = Vector2(0,0)
	
	for current_fig in figures_input:
		if current_fig.x > 2 or current_fig.y > 2:
			for x in 3:
				for y in 3:
					if !(Vector2(x,y) in figures_input):
						if cell_weight < 1.0 / (x + y + 1.0):
							if x > y: # to add weight assymetrically to cells in closer to figure sector
								cell_weight = 1.0 / (x / 2.0 + y + 1.0)
							else:
								cell_weight = 1.0 / (x + y / 2.0 + 1.0)
							target_cell = Vector2(x,y)
			metric += (current_fig - target_cell).length() * 0.5
	return metric
	
	
func add_to_queue(priority, count_metric, figures_next, queue):
	var flag = false

	if queue.size() == 0:
		queue.append([priority, count_metric, figures_next])
	else:
		for i in queue.size():
			if queue[i][2] == figures_next:
				flag = true
				if priority < queue[i][0]:
					queue.remove(i)
					flag = false
					break
		if flag == false:
			for i in queue.size():
				if priority < queue[i][0]:
					queue.insert(i, [priority, count_metric, figures_next])
					break
		
func tiles_to_fill(input): # to find out min moves to go
	var count_tile = 0
	
	for x in 3:
		for y in 3:
			if !(Vector2(x,y) in input):
				count_tile += 1
	return count_tile
	

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
