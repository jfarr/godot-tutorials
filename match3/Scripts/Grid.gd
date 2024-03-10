extends Node2D

signal level_complete
signal game_over

enum {wait, move}
var state
var level = 0

enum Bounce {disallow, discard, keep}
@export var bounce_behavior : Bounce
@export var max_anchors = 20

@export var width: int
@export var height: int
@export var side_rows: int
@export var offset: int
@export var y_offset: int

@onready var x_start = ((get_window().size.x / 2.0) - ((width/2.0) * offset ) + (offset / 2))
@onready var y_start = ((get_window().size.y / 2.0) + ((height/2.0) * offset ) - (offset / 2))

@export var anchor_spaces: PackedVector2Array

@onready var all_possible_dots = [
	preload("res://Scenes/Dots/blue_dot.tscn"),
	preload("res://Scenes/Dots/green_dot.tscn"),
	preload("res://Scenes/Dots/red_dot.tscn"),
	preload("res://Scenes/Dots/yellow_dot.tscn"),
	preload("res://Scenes/Dots/pink_dot.tscn"),
	preload("res://Scenes/Dots/grey_dot.tscn"),
]

var swap_timer = Timer.new()
var destroy_timer = Timer.new()
var unanchored_timer = Timer.new()
var collapse_timer = Timer.new()
var refill_timer = Timer.new()

var all_dots = []
var possible_dots
var num_colors : int
var move_history = []

var dot_one = null
var dot_two = null
var first_place = Vector2(0,0)
var last_place = Vector2(0,0)
var last_direction = Vector2(0,0)

func _ready():
	setup_timers()
	randomize()
	all_dots = make_2d_array()

func next_level():
	level += 1
	reset()

func reset():
	clear_board(all_dots)
	clear_history()
	num_colors = 3 + (level - 1) / 4
	possible_dots = all_possible_dots.slice(0, num_colors)
	select_anchors()
	spawn_dots()
	state = move

func select_anchors():
	var num_anchors = min(max_anchors, level + 2)
	anchor_spaces = []
	var count = 0
	while count < num_anchors:
		var i = randi_range(side_rows + 1, width - side_rows - 2)
		var j = randi_range(side_rows + 1, height - side_rows - 2)
		var pos = Vector2(i, j)
		if !is_in_array(anchor_spaces, pos):
			anchor_spaces.append(pos)
			count += 1

func setup_timers():
	swap_timer.connect("timeout", Callable(self, "swap_back"))
	swap_timer.set_one_shot(true)
	swap_timer.set_wait_time(0.2)
	add_child(swap_timer)

	destroy_timer.connect("timeout", Callable(self, "destroy_matches"))
	destroy_timer.set_one_shot(true)
	destroy_timer.set_wait_time(0.2)
	add_child(destroy_timer)
	
	unanchored_timer.connect("timeout", Callable(self, "destroy_unanchored"))
	unanchored_timer.set_one_shot(true)
	unanchored_timer.set_wait_time(0.2)
	add_child(unanchored_timer)
	
	collapse_timer.connect("timeout", Callable(self, "collapse_columns"))
	collapse_timer.set_one_shot(true)
	collapse_timer.set_wait_time(0.2)
	add_child(collapse_timer)

	refill_timer.connect("timeout", Callable(self, "refill_columns"))
	refill_timer.set_one_shot(true)
	refill_timer.set_wait_time(0.2)
	add_child(refill_timer)

func is_anchor(place):
	return all_dots[place.x][place.y] and all_dots[place.x][place.y].anchor

func is_anchor_space(place):
	return is_in_array(anchor_spaces, place)

func find_regions():
	var regions = []
	var checked = {}
	for i in range(side_rows, width - side_rows):
		for j in range(side_rows, height - side_rows):
			if checked.has(Vector2(i, j)):
				continue
			var region = []
			find_region(checked, region, i, j)
			if region.size() > 0:
				regions.append(region)
	return regions

func find_region(checked, region, i, j):
	if checked.has(Vector2(i, j)):
		return
	checked[Vector2(i, j)] = 1
	if all_dots[i][j] == null:
		return
	region.append(Vector2(i, j))
	if i < width - side_rows - 1:
		find_region(checked, region, i + 1, j)
	if i > side_rows:
		find_region(checked, region, i - 1, j)
	if j < height - side_rows - 1:
		find_region(checked, region, i, j + 1)
	if j > side_rows:
		find_region(checked, region, i, j - 1)

func has_anchors():
	for place in anchor_spaces:
		if all_dots[place.x][place.y]:
			return true
	return false 

func is_in_array(array, item):
	for i in array.size():
		if array[i] == item:
			return true
	return false

func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array

func spawn_dots():
	for i in width:
		for j in height:
			var pos = Vector2(i, j)
			if !in_corner(pos) and (!in_center(pos) or is_anchor_space(pos)):
				var rand = floor(randf_range(0, possible_dots.size()))
				var scene = possible_dots[rand]
				var dot = scene.instantiate()
				dot.scene = scene
				all_dots[i][j] = dot
				var loops = 0
				while (is_anchor_space(pos) and center_match() and loops < 100):
					print("found anchor match")
					dot.queue_free()
					rand = floor(randf_range(0,possible_dots.size()))
					scene = possible_dots[rand]
					dot = scene.instantiate()
					dot.scene = scene
					all_dots[i][j] = dot
					loops += 1
				dot.position = grid_to_pixel(i, j)
				if is_anchor_space(pos):
					dot.anchor = true
				add_child(dot)
	for pos in anchor_spaces:
		var anchor_dot = all_dots[pos.x][pos.y]
		anchor_dot.show_marker()

func in_corner(pos : Vector2):
	return (pos.x < side_rows or pos.x >= width - side_rows) and (pos.y < side_rows or pos.y >= height - side_rows)

func in_center(pos : Vector2):
	return pos.x >= side_rows and pos.x < width - side_rows and pos.y >= side_rows and pos.y < height - side_rows

func center_match():
	for i in range(side_rows, width - side_rows):
		for j in range(side_rows, height - side_rows):
			if find_match(i, j):
				return true
	return false

func grid_to_pixel(column, row):
	var new_x = x_start + offset * column
	var new_y = y_start + -offset * row
	return Vector2(new_x, new_y)

func pixel_to_grid(pixel_x,pixel_y):
	var new_x = round((pixel_x - x_start) / offset)
	var new_y = round((pixel_y - y_start) / -offset)
	return Vector2(new_x, new_y)

func is_in_grid(grid_position):
	if grid_position.x >= 0 && grid_position.x < width:
		if grid_position.y >= 0 && grid_position.y < height:
			return true
	return false

func touch_input():
	if Input.is_action_just_pressed("ui_touch"):
		var touch = pixel_to_grid(get_global_mouse_position().x,get_global_mouse_position().y)
		if is_in_grid(touch):
			if touch.x == side_rows - 1 and touch.y >= side_rows and touch.y < height - side_rows:
				swap_dots(touch.x, touch.y, Vector2(1, 0))
			elif touch.x == width - side_rows and touch.y >= side_rows and touch.y < height - side_rows:
				swap_dots(touch.x, touch.y, Vector2(-1, 0))
			elif touch.y == side_rows - 1 and touch.x >= side_rows and touch.x < width - side_rows:
				swap_dots(touch.x, touch.y, Vector2(0, 1))
			elif touch.y == width - side_rows and touch.x >= side_rows and touch.x < width - side_rows:
				swap_dots(touch.x, touch.y, Vector2(0, -1))

func swap_dots(column, row, direction):
	var first_dot = all_dots[column][row]
	var other_dot = all_dots[column + direction.x][row + direction.y]
	if first_dot != null and !in_center(Vector2(column, row)) \
		and other_dot == null and in_center(Vector2(column + direction.x, row + direction.y)):
		save_move()
		store_info(first_dot, Vector2(column, row), Vector2(column, row), direction)
		state = wait
		slide_dots()

func slide_dots():
	var start_pos = last_place
	var dot_pos = start_pos + last_direction
	var next_pos = dot_pos + last_direction
	while in_center(next_pos) and all_dots[next_pos.x][next_pos.y] == null:
		dot_pos = next_pos
		next_pos = dot_pos + last_direction
	if !in_center(next_pos):
		if bounce_behavior == Bounce.disallow:
			dot_one.move(grid_to_pixel(dot_pos.x, dot_pos.y))
			store_info(dot_one, start_pos, dot_pos, last_direction)
			swap_timer.start()
		elif bounce_behavior == Bounce.discard:
			all_dots[start_pos.x][start_pos.y].dim()
			all_dots[start_pos.x][start_pos.y].queue_free()
			all_dots[start_pos.x][start_pos.y] = null
			collapse_timer.start()
		elif bounce_behavior == Bounce.keep:
			swap_across(next_pos)
		state = move
		return
	all_dots[dot_pos.x][dot_pos.y] = dot_one
	all_dots[start_pos.x][start_pos.y] = null
	dot_one.move(grid_to_pixel(dot_pos.x, dot_pos.y))
	store_info(dot_one, start_pos, Vector2(dot_pos.x, dot_pos.y), last_direction)
	find_matches()

func store_info(first_dot, first_place, place, direction):
	dot_one = first_dot
	self.first_place = first_place
	last_place = place
	last_direction = direction

func swap_across(dot_pos):
	var first_dot = dot_one
	var second_dot = all_dots[dot_pos.x][dot_pos.y]
	all_dots[first_place.x][first_place.y] = second_dot
	all_dots[dot_pos.x][dot_pos.y] = first_dot
	first_dot.move(grid_to_pixel(dot_pos.x, dot_pos.y))
	second_dot.move(grid_to_pixel(first_place.x, first_place.y))

func swap_back():
	if dot_one != null:
		dot_one.move(grid_to_pixel(first_place.x, first_place.y))

func _process(_delta):
	if state == move:
		touch_input()

func save_move():
	var last_move = make_2d_array()
	copy_board(all_dots, last_move)
	move_history.push_front(last_move)

func undo_move():
	if move_history.size() > 0:
		var last_move = move_history.pop_front()
		clear_board(all_dots)
		copy_board(last_move, all_dots)
		sync_board()

func copy_board(src, dest):
	for i in width:
		for j in height:
			if src[i][j]:
				dest[i][j] = src[i][j].scene.instantiate()
				dest[i][j].scene = src[i][j].scene
			else:
				dest[i][j] = null

func clear_board(dots):
	for i in width:
		for j in height:
			if dots[i][j]:
				dots[i][j].queue_free()
			dots[i][j] = null

func sync_board():
	for i in width:
		for j in height:
			if all_dots[i][j]:
				if is_anchor_space(Vector2(i, j)):
					all_dots[i][j].anchor = true
				add_child(all_dots[i][j])
				all_dots[i][j].position = grid_to_pixel(i, j)
	for pos in anchor_spaces:
		var anchor_dot = all_dots[pos.x][pos.y]
		if anchor_dot:
			anchor_dot.show_marker()

func clear_history():
	for board in move_history:
		clear_board(board)
	move_history = []

func find_matches():
	for i in range(side_rows, width - side_rows):
		for j in range(side_rows, height - side_rows):
			var matched = find_match(i, j)
			if matched:
				for dot in matched:
					match_and_dim(dot)
	destroy_timer.start()

func find_match(i, j):
	if !is_piece_null(i, j):
		var current_color = all_dots[i][j].color
		if i > side_rows && i < width - side_rows - 1:
			if !is_piece_null(i - 1, j) && !is_piece_null(i + 1, j):
				if all_dots[i - 1][j].color == current_color && all_dots[i + 1][j].color == current_color:
					return [all_dots[i - 1][j], all_dots[i][j], all_dots[i + 1][j]]
		if j > side_rows && j < height - side_rows - 1:
			if !is_piece_null(i, j - 1) && !is_piece_null(i, j + 1):
				if all_dots[i][j - 1].color == current_color && all_dots[i][j + 1].color == current_color:
					return [all_dots[i][j - 1], all_dots[i][j], all_dots[i][j + 1]]
		if j > side_rows and i < width - side_rows - 1:
			if !is_piece_null(i, j - 1) and !is_piece_null(i + 1, j):
				if all_dots[i][j - 1].color == current_color && all_dots[i + 1][j].color == current_color:
					return [all_dots[i][j - 1], all_dots[i][j], all_dots[i + 1][j]]
		if i > side_rows and j < width - side_rows - 1:
			if !is_piece_null(i - 1, j) and !is_piece_null(i, j + 1):
				if all_dots[i - 1][j].color == current_color && all_dots[i][j + 1].color == current_color:
					return [all_dots[i - 1][j], all_dots[i][j], all_dots[i][j + 1]]
		if j < height - side_rows - 1 and i < width - side_rows - 1:
			if !is_piece_null(i, j + 1) and !is_piece_null(i + 1, j):
				if all_dots[i][j + 1].color == current_color && all_dots[i + 1][j].color == current_color:
					return [all_dots[i][j + 1], all_dots[i][j], all_dots[i + 1][j]]
		if j > side_rows and i > side_rows:
			if !is_piece_null(i, j - 1) and !is_piece_null(i - 1, j):
				if all_dots[i][j - 1].color == current_color && all_dots[i - 1][j].color == current_color:
					return [all_dots[i][j - 1], all_dots[i][j], all_dots[i - 1][j]]
	return null

func is_piece_null(column, row):
	return all_dots[column][row] == null

func match_and_dim(item):
	item.matched = true
	item.dim()

func destroy_matches():
	var was_matched = false
	for i in width:
		for j in height:
			if all_dots[i][j] != null:
				if all_dots[i][j].matched:
					was_matched = true
					all_dots[i][j].queue_free()
					all_dots[i][j] = null
	unanchored_timer.start()

func destroy_unanchored():
	var regions = find_regions()
	for region in regions:
		var has_anchor = false
		for place in region:
			if is_anchor(place):
				has_anchor = true
				break
		if !has_anchor:
			for place in region:
				var dot = all_dots[place.x][place.y]
				match_and_dim(dot)
				dot.queue_free()
				all_dots[place.x][place.y] = null
	collapse_timer.start()

func collapse_columns():
	for i in range(side_rows, width - side_rows):
		for j in range(side_rows-1, 0, -1):
			if all_dots[i][j] == null:
				for k in range(j - 1, side_rows - 1):
					if all_dots[i][k] != null:
						all_dots[i][k].move(grid_to_pixel(i, j))
						all_dots[i][j] = all_dots[i][k]
						all_dots[i][k] = null
						break
	for i in range(side_rows, width - side_rows):
		for j in range(height - side_rows, height):
			if all_dots[i][j] == null:
				for k in range(j + 1, height):
					if all_dots[i][k] != null:
						all_dots[i][k].move(grid_to_pixel(i, j))
						all_dots[i][j] = all_dots[i][k]
						all_dots[i][k] = null
						break
	for i in range(side_rows-1, 0, -1):
		for j in range(side_rows, height - side_rows):
			if all_dots[i][j] == null:
				for k in range(i - 1, side_rows - 1):
					if all_dots[k][j] != null:
						all_dots[k][j].move(grid_to_pixel(i, j))
						all_dots[i][j] = all_dots[k][j]
						all_dots[k][j] = null
						break
	for i in range(width - side_rows, width - 1):
		for j in range(side_rows, height - side_rows):
			if all_dots[i][j] == null:
				for k in range(i + 1, width - side_rows, -1):
					if all_dots[k][j] != null:
						all_dots[k][j].move(grid_to_pixel(i, j))
						all_dots[i][j] = all_dots[k][j]
						all_dots[k][j] = null
						break
	refill_timer.start()

func refill_columns():
	for i in range(side_rows, width - side_rows):
		var j = height - 1
		if all_dots[i][j] == null:
			var rand = floor(randf_range(0, possible_dots.size()))
			var scene = possible_dots[rand]
			var dot = scene.instantiate()
			dot.scene = scene
			add_child(dot)
			dot.position = grid_to_pixel(i, j - y_offset)
			dot.move(grid_to_pixel(i,j))
			all_dots[i][j] = dot
	for i in range(side_rows, width - side_rows):
		var j = 0
		if all_dots[i][j] == null:
			var rand = floor(randf_range(0, possible_dots.size()))
			var scene = possible_dots[rand]
			var dot = scene.instantiate()
			dot.scene = scene
			add_child(dot)
			dot.position = grid_to_pixel(i, j + y_offset)
			dot.move(grid_to_pixel(i,j))
			all_dots[i][j] = dot
	for j in range(side_rows, height - side_rows):
		var i = width - 1
		if all_dots[i][j] == null:
			var rand = floor(randf_range(0, possible_dots.size()))
			var scene = possible_dots[rand]
			var dot = scene.instantiate()
			dot.scene = scene
			add_child(dot)
			dot.position = grid_to_pixel(i - y_offset, j)
			dot.move(grid_to_pixel(i,j))
			all_dots[i][j] = dot
	for j in range(side_rows, height - side_rows):
		var i = 0
		if all_dots[i][j] == null:
			var rand = floor(randf_range(0, possible_dots.size()))
			var scene = possible_dots[rand]
			var dot = scene.instantiate()
			dot.scene = scene
			add_child(dot)
			dot.position = grid_to_pixel(i + y_offset, j)
			dot.move(grid_to_pixel(i,j))
			all_dots[i][j] = dot
	check_complete()

func check_complete():
	if has_anchors():
		state = move
	else:
		level_complete.emit()
