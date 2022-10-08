extends Node2D

export var number_wave = 11
export var length_range = Vector2(1.0 / 500.0, 1.0 / 50.0)
export var angle_range = Vector2(0, 2 * PI)
export var zero_phase_range = Vector2(- 1.0 / 50.0, 1.0 / 50.0)
export var speed = 1.0 / 2.0

var phase = 0

var num_tiles = 0
# var all_parameters = []
var cell_size = 0
var needed_tiles = []

var tilemap
# var tiles_pos = []
var precalc_vec = []


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
	_generate_all_parameters()
	print("Done generating")


func _generate_all_parameters():
	# first generate waves parameters
	var all_parameters = []
	for _i in range(number_wave):
		# we had length, angle (converted to vector) and phase
		var angle = rand_range(angle_range.x, angle_range.y)
		var wave_param = [rand_range(length_range.x, length_range.y),
						  [cos(angle), sin(angle)],
						  rand_range(zero_phase_range.x, zero_phase_range.y)]
		all_parameters += [wave_param]
	
	# then pre-generate the vector for the phase
	precalc_vec = []
	var vecx
	var vecy
	var val
	for row in needed_tiles[1]:
		var row_pos = []
		var row_precalc = []
		for col in needed_tiles[0]:
			row_pos = [(col + 0.5) * cell_size, (row + 0.5) * cell_size]
			vecx = 0
			vecy = 0
			for params in all_parameters:
				val = params[0] * (row_pos[0] * params[1][0] + 
					  row_pos[1] * params[1][1]) + params[2]
				vecx += sin(val)
				vecy += cos(val)
			row_precalc += [[vecx, vecy]]
		precalc_vec += [row_precalc]


func _process(delta):
	# this is where we generate the waves
	
	# if we press space - we reset all the waves
	if Input.is_physical_key_pressed(32):
		_generate_all_parameters()
	
	var val
	var phase_trig = [cos(phase), sin(phase)]
	
	for row in range(needed_tiles[1]):
		for col in range(needed_tiles[0]):
			val = precalc_vec[row][col][0] * phase_trig[0] + precalc_vec[row][col][1] * phase_trig[1]
			val += number_wave
			val *= (num_tiles - 1) / (2.0 * number_wave)
			val = floor(val) + 1
			
			# set the tile
			tilemap.set_cell(col, row, val)

	# update the phase
	var phase_shift = speed * delta
	phase += phase_shift
