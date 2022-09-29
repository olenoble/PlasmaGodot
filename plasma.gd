extends Node2D

export var number_wave = 11
export var length_range = Vector2(1.0 / 500.0, 1.0 / 50.0)
export var angle_range = Vector2(0, 2 * PI)
export var zero_phase_range = Vector2(- 1.0 / 50.0, 1.0 / 50.0)
export var speed = 1.0 / 2.0

var phase = 0

var num_tiles = 0
var all_parameters = []
var cell_size = 0
var needed_tiles = []

var tilemap
var tiles_pos = []


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	# get info on tiles (number, size and how many needed for our window)
	tilemap = get_node("PlasmaTiles")

	num_tiles = len(tilemap.tile_set.get_tiles_ids())
	print("Using " + str(num_tiles) + " tiles")

	cell_size = tilemap.cell_size[0]
	print("Tile Size = " + str(cell_size))
	
	var window_size = OS.get_window_size()
	needed_tiles = [floor(window_size[0] / cell_size), floor(window_size[1] / cell_size)]
	print("Number of required tiles = " + str(needed_tiles))
	
	# first generate waves parameters
	for _i in range(number_wave):
		# we had length, angle (converted to vector) and phase
		var angle = rand_range(angle_range.x, angle_range.y)
		var wave_param = [rand_range(length_range.x, length_range.y),
						  [cos(angle), sin(angle)],
						  rand_range(zero_phase_range.x, zero_phase_range.y)]
		all_parameters += [wave_param]
	
	# generate center position for all cells
	for row in needed_tiles[1]:
		var row_pos = []
		for col in needed_tiles[0]:
			row_pos += [[(col + 0.5) * cell_size, (row + 0.5) * cell_size]]
		tiles_pos += [row_pos]
	
	print("Done generating")


func _process(delta):
	# this is where we generate the waves	
	var pos
	var val
	
	var pos_shift = 0.5 * cell_size
	for row in range(needed_tiles[1]):
		for col in range(needed_tiles[0]):
			pos = tiles_pos[row][col]
			val = 0
			for params in all_parameters:
				val += 1 + sin(params[0] * (pos[0] * params[1][0] + pos[1] * params[1][1]) + params[2] + phase)
			
			val *= (num_tiles - 1) / (2.0 * number_wave)
			val = floor(val) + 1
			
			# set the tile
			tilemap.set_cell((pos[0] - pos_shift) / cell_size, 
							 (pos[1] - pos_shift) / cell_size, val)

	# update the phase
	var phase_shift = speed * delta
	phase += phase_shift
