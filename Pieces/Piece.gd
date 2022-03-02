extends Node2D

export (String) var piece

var matched
var is_counted
var is_column_bomb = false
var is_row_bomb = false
var is_adjacent_bomb = false
var is_color_bomb = false
var selected = false
var target_position = Vector2(0,0)
var grid = Vector2.ZERO
var column_bomb_color = Color(1, 0.2, 0.2, 1)
var row_bomb_color = Color(0.2, 0.2, 1, 1)
var adjacent_bomb_color = Color(0, 0, 1, 1)
var color_bomb_color = Color(0.5, 0.5, 0.5, 1)
var block_drop_sounds = []
var die_sounds = []

var default_z = z_index
const max_z = 4095

func _ready():
	target_position = position
	block_drop_sounds.append(get_node("/root/Game/Sounds/BlockDrop0"))
	block_drop_sounds.append(get_node("/root/Game/Sounds/BlockDrop1"))
	block_drop_sounds.append(get_node("/root/Game/Sounds/BlockDrop2"))
	die_sounds.append(get_node("/root/Game/Sounds/Fruit0"))
	die_sounds.append(get_node("/root/Game/Sounds/Fruit1"))

func _physics_process(_delta):
	if selected:
		if z_index == default_z:
			z_index = max_z
			target_position = position
		global_position = constrain(Vector2(get_global_mouse_position().x, get_global_mouse_position().y))
		$Highlight.show()
		$Selected.emitting = true
	else:
		if z_index != default_z:
			z_index = default_z
			position = target_position		
		$Highlight.hide()
		$Selected.emitting = false

func move(change):
	target_position = change
	$Tween.interpolate_property(self, "position", position, target_position, 0.5, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	$Tween.start()
	var sound = block_drop_sounds[rand_range(0, len(block_drop_sounds))]
	if sound != null:
		sound.play()

func dim():
	pass

func make_column_bomb():
	is_column_bomb = true
	modulate = column_bomb_color
	var Fire = load("res://Shaders/Fire.tscn")
	add_child(Fire.instance())

func make_row_bomb():
	is_row_bomb = true
	modulate = row_bomb_color
	var Fire = load("res://Shaders/Fire.tscn")
	add_child(Fire.instance())

func make_adjacent_bomb():
	is_adjacent_bomb = true
	modulate = adjacent_bomb_color
	var Fire = load("res://Shaders/Fire.tscn")
	add_child(Fire.instance())

func make_color_bomb():
	is_color_bomb = true
	piece = "Color"
	modulate = color_bomb_color
	var Fire = load("res://Shaders/Fire.tscn")
	add_child(Fire.instance())

func die():
	var sound = die_sounds[rand_range(0, len(die_sounds))]
	if sound != null:
		sound.play()
	$Tween.interpolate_property(self, "position:y", position.y, 1000, randf()+0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	$Tween.interpolate_property(self, "scale", scale, Vector2(0.75, 1.25), randf()+0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	$Tween.interpolate_property(self, "modulate:a", modulate.a, 0, randf()+0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	$Timer.wait_time = 2
	$Timer.start()
	Global.update_goals(piece)


func constrain(xy):
	var Grid = get_node_or_null("/root/Game/Grid")
	if Grid == null:
		return xy
	else:
		var temp = xy
		var tptg = Grid.pixel_to_grid(temp.x,temp.y)
		tptg.x = clamp(tptg.x,0,Grid.width-1)
		tptg.y = clamp(tptg.y,0,Grid.height-1)
		var gtp = Grid.grid_to_pixel(grid.x, grid.y)
		if tptg.x == grid.x:
			#extend y axis by 1 each direction
			temp.x = gtp.x
			var max_y = Grid.grid_to_pixel(grid.x, clamp(grid.y-1,0,grid.y))
			var min_y = Grid.grid_to_pixel(grid.x, clamp(grid.y+1,grid.y,Grid.height-1))
			temp.y = clamp(temp.y,min_y.y,max_y.y)
		elif tptg.x == grid.x and tptg.y == grid.y:
			pass
		else:
			#extend x axis by 1 each direction
			temp.y = gtp.y
			var min_x = Grid.grid_to_pixel(clamp(grid.x-1,0,grid.x), grid.y)
			var max_x = Grid.grid_to_pixel(clamp(grid.x+1,grid.x,Grid.width-1), grid.y)
			temp.x = clamp(temp.x,min_x.x,max_x.x)
		return temp


func _on_Timer_timeout():
	queue_free()
