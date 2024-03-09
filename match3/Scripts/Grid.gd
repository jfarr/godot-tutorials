extends Node2D

signal game_over

enum {wait, move}
var state

enum Bounce {disallow, discard, keep}
@export var bounce_behavior : Bounce

@export var width: int
@export var height: int
@export var side_rows: int
@export var offset: int
@export var y_offset: int

@onready var x_start = ((get_window().size.x / 2.0) - ((width/2.0) * offset ) + (offset / 2))
@onready var y_start = ((get_window().size.y / 2.0) + ((height/2.0) * offset ) - (offset / 2))

@export var anchor_spaces: PackedVector2Array

@onready var possible_dots = [
	preload("res://Scenes/Dots/blue_dot.tscn"),
	preload("res://Scenes/Dots/green_dot.tscn"),
	preload("res://Scenes/Dots/pink_dot.tscn"),
	preload("res://Scenes/Dots/red_dot.tscn"),
	preload("res://Scenes/Dots/yellow_dot.tscn"),
]
@onready var grey_dot = preload("res://Scenes/Dots/grey_dot.tscn")

var slide_timer = Timer.new()
var destroy_timer = Timer.new()
var unanchored_timer = Timer.new()
var collapse_timer = Timer.new()
var refill_timer = Timer.new()

var all_dots = []

var dot_one = null
var dot_two = null
var first_place = Vector2(0,0)
var last_place = Vector2(0,0)
var last_direction = Vector2(0,0)
var move_checked = false


var first_touch = Vector2(0,0)
var final_touch = Vector2(0,0)
var controlling = false

func _ready():
	state = move
	setup_timers()
	randomize()
	all_dots = make_2d_array()
	spawn_dots()
	
func setup_timers():
	slide_timer.connect("timeout", Callable(self, "slide_dots"))
	slide_timer.set_one_shot(true)
	slide_timer.set_wait_time(0.1)
	add_child(slide_timer)
	
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
				var dot = possible_dots[rand].instantiate()
				var loops = 0
				while (match_at(i, j, dot.color) && loops < 100):
					rand = floor(randf_range(0,possible_dots.size()))
					loops += 1
					dot = possible_dots[rand].instantiate()
				dot.position = grid_to_pixel(i, j)
				if is_anchor_space(pos):
					dot.anchor = true
				add_child(dot)
				all_dots[i][j] = dot
	for pos in anchor_spaces:
		var anchor_dot = all_dots[pos.x][pos.y]
		anchor_dot.show_marker()

func in_corner(pos : Vector2):
	return (pos.x < side_rows or pos.x >= width - side_rows) and (pos.y < side_rows or pos.y >= height - side_rows)

func in_center(pos : Vector2):
	return pos.x >= side_rows and pos.x < width - side_rows and pos.y >= side_rows and pos.y < height - side_rows

func match_at(i, j, color):
	if i > 1:
		if all_dots[i - 1][j] != null && all_dots[i - 2][j] != null:
			if all_dots[i - 1][j].color == color && all_dots[i - 2][j].color == color:
				return true
	if j > 1:
		if all_dots[i][j - 1] != null && all_dots[i][j - 2] != null:
			if all_dots[i][j - 1].color == color && all_dots[i][j - 2].color == color:
				return true
	pass

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
		if is_in_grid(pixel_to_grid(get_global_mouse_position().x,get_global_mouse_position().y)):
			first_touch = pixel_to_grid(get_global_mouse_position().x,get_global_mouse_position().y)
			controlling = true
	if Input.is_action_just_released("ui_touch"):
		if is_in_grid(pixel_to_grid(get_global_mouse_position().x,get_global_mouse_position().y)) && controlling:
			controlling = false
			final_touch = pixel_to_grid(get_global_mouse_position().x,get_global_mouse_position().y )
			touch_difference(first_touch, final_touch)

func swap_dots(column, row, direction):
	var first_dot = all_dots[column][row]
	var other_dot = all_dots[column + direction.x][row + direction.y]
	if first_dot != null and !in_center(Vector2(column, row)) \
		and other_dot == null and in_center(Vector2(column + direction.x, row + direction.y)):
		store_info(first_dot, Vector2(column, row), Vector2(column, row), direction)
		state = wait
		#first_dot.direction = direction
		all_dots[column + direction.x][row + direction.y] = first_dot
		all_dots[column][row] = null
		first_dot.move(grid_to_pixel(column + direction.x, row + direction.y))
		slide_dots()

func slide_dots():
	var dot_pos = last_place + last_direction
	# if the dot hits the other side
	if !in_center(Vector2(dot_pos.x + last_direction.x, dot_pos.y + last_direction.y)):
		if bounce_behavior == Bounce.disallow:
			swap_back()
		elif bounce_behavior == Bounce.discard:
			all_dots[dot_pos.x][dot_pos.y].dim()
			all_dots[dot_pos.x][dot_pos.y].queue_free()
			all_dots[dot_pos.x][dot_pos.y] = null
		elif bounce_behavior == Bounce.keep:
			swap_across(dot_pos)
		# stop sliding
		find_matches()
	else:
		# else if no dot in the next slot then slide
		if all_dots[dot_pos.x + last_direction.x][dot_pos.y + last_direction.y] == null:
			all_dots[dot_pos.x + last_direction.x][dot_pos.y + last_direction.y] = dot_one
			all_dots[dot_pos.x][dot_pos.y] = null
			dot_one.move(grid_to_pixel(dot_pos.x + last_direction.x, dot_pos.y + last_direction.y))
			store_info(dot_one, first_place, Vector2(dot_pos.x, dot_pos.y), last_direction)
			slide_timer.start()
		else:
			# stop sliding
			find_matches()

func store_info(first_dot, first_place, place, direction):
	dot_one = first_dot
	self.first_place = first_place
	last_place = place
	last_direction = direction

func swap_across(dot_pos):
	all_dots[dot_pos.x][dot_pos.y] = null
	var first_dot = dot_one
	var second_dot = all_dots[dot_pos.x + last_direction.x][dot_pos.y + last_direction.y]
	all_dots[first_place.x][first_place.y] = second_dot
	all_dots[dot_pos.x + last_direction.x][dot_pos.y + last_direction.y] = first_dot
	first_dot.move(grid_to_pixel(dot_pos.x + last_direction.x, dot_pos.y + last_direction.y))
	second_dot.move(grid_to_pixel(first_place.x, first_place.y))

func swap_back():
	if dot_one != null:
		all_dots[first_place.x][first_place.y] = dot_one
		all_dots[last_place.x + last_direction.x][last_place.y + last_direction.y] = null
		dot_one.move(grid_to_pixel(first_place.x, first_place.y))
	
func touch_difference(grid_1, grid_2):
	var difference = grid_2 - grid_1
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swap_dots(grid_1.x, grid_1.y, Vector2(1, 0))
		elif difference.x < 0:
			swap_dots(grid_1.x, grid_1.y, Vector2(-1, 0))
	elif abs(difference.y) > abs(difference.x):
		if difference.y > 0:
			swap_dots(grid_1.x, grid_1.y, Vector2(0, 1))
		elif difference.y < 0:
			swap_dots(grid_1.x, grid_1.y, Vector2(0, -1))

func _process(_delta):
	if state == move:
		touch_input()
	
func find_matches():
	for i in range(side_rows, width - side_rows):
		for j in range(side_rows, height - side_rows):
			if all_dots[i][j] != null:
				var current_color = all_dots[i][j].color
				if i > side_rows && i < width - side_rows - 1:
					if !is_piece_null(i - 1, j) && !is_piece_null(i + 1, j):
						if all_dots[i - 1][j].color == current_color && all_dots[i + 1][j].color == current_color:
							match_and_dim(all_dots[i - 1][j])
							match_and_dim(all_dots[i][j])
							match_and_dim(all_dots[i + 1][j])
				if j > side_rows && j < height - side_rows - 1:
					if !is_piece_null(i, j - 1) && !is_piece_null(i, j + 1):
						if all_dots[i][j - 1].color == current_color && all_dots[i][j + 1].color == current_color:
							match_and_dim(all_dots[i][j - 1])
							match_and_dim(all_dots[i][j])
							match_and_dim(all_dots[i][j + 1])
				if j > side_rows and i < width - side_rows - 1:
					if !is_piece_null(i, j - 1) and !is_piece_null(i + 1, j):
						if all_dots[i][j - 1].color == current_color && all_dots[i + 1][j].color == current_color:
							match_and_dim(all_dots[i][j - 1])
							match_and_dim(all_dots[i][j])
							match_and_dim(all_dots[i + 1][j])
				if i > side_rows and j < width - side_rows - 1:
					if !is_piece_null(i - 1, j) and !is_piece_null(i, j + 1):
						if all_dots[i - 1][j].color == current_color && all_dots[i][j + 1].color == current_color:
							match_and_dim(all_dots[i - 1][j])
							match_and_dim(all_dots[i][j])
							match_and_dim(all_dots[i][j + 1])
				if j < height - side_rows - 1 and i < width - side_rows - 1:
					if !is_piece_null(i, j + 1) and !is_piece_null(i + 1, j):
						if all_dots[i][j + 1].color == current_color && all_dots[i + 1][j].color == current_color:
							match_and_dim(all_dots[i][j + 1])
							match_and_dim(all_dots[i][j])
							match_and_dim(all_dots[i + 1][j])
				if j > side_rows and i > side_rows:
					if !is_piece_null(i, j - 1) and !is_piece_null(i - 1, j):
						if all_dots[i][j - 1].color == current_color && all_dots[i - 1][j].color == current_color:
							match_and_dim(all_dots[i][j - 1])
							match_and_dim(all_dots[i][j])
							match_and_dim(all_dots[i - 1][j])
	destroy_timer.start()

func is_piece_null(column, row):
	if all_dots[column][row] == null:
		return true
	return false

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
	move_checked = true
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
			var dot = possible_dots[rand].instantiate()
			add_child(dot)
			dot.position = grid_to_pixel(i, j - y_offset)
			dot.move(grid_to_pixel(i,j))
			all_dots[i][j] = dot
	for i in range(side_rows, width - side_rows):
		var j = 0
		if all_dots[i][j] == null:
			var rand = floor(randf_range(0, possible_dots.size()))
			var dot = possible_dots[rand].instantiate()
			add_child(dot)
			dot.position = grid_to_pixel(i, j + y_offset)
			dot.move(grid_to_pixel(i,j))
			all_dots[i][j] = dot
	for j in range(side_rows, height - side_rows):
		var i = width - 1
		if all_dots[i][j] == null:
			var rand = floor(randf_range(0, possible_dots.size()))
			var dot = possible_dots[rand].instantiate()
			add_child(dot)
			dot.position = grid_to_pixel(i - y_offset, j)
			dot.move(grid_to_pixel(i,j))
			all_dots[i][j] = dot
	for j in range(side_rows, height - side_rows):
		var i = 0
		if all_dots[i][j] == null:
			var rand = floor(randf_range(0, possible_dots.size()))
			var dot = possible_dots[rand].instantiate()
			add_child(dot)
			dot.position = grid_to_pixel(i + y_offset, j)
			dot.move(grid_to_pixel(i,j))
			all_dots[i][j] = dot
	check_end()

func check_end():
	if has_anchors():
		state = move
	else:
		game_over.emit()