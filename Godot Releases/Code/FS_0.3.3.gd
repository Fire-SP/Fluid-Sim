extends Node2D
var noise = OpenSimplexNoise.new()
var rock = OpenSimplexNoise.new()

var map_size = 75
var size = 7
var air = []
var heightmap = []
var dry = []
var rock_hardness = []
var sediment = []
var countlistx = []
var finallistx = []
var countlisty = []
var finallisty = []

var build = false
var dig = false
var create = false
var add_water = false
var stop_click = false
var rain = false
var enable_rain = false
var enable_erosion = false
var enable_evaporation = false



func _ready():
	randomize()
	noise.seed = randi()
	rock.seed = randi()
	noise.octaves = 4.5
	rock.octaves = 4
	noise.period = 90
	rock.period = 35
	noise.persistence = 0.75
	rock.persistence = 0.75
	generate_map()
	randomize_X()
	randomize_Y()


#warning-ignore:unused_argument
func _process(delta):
	update_tiles()
	pen()
	update()


func update_tiles():
	for i in finallistx:
		for j in finallisty:
			if dry[i][j] < 20:
				dry[i][j] += 0.5

			if dry[i][j] < 0:
					dry[i][j] = 0

			if j >= map_size:
				j -= 1
			if i >= map_size:
				i -= 1

			var d1 = [heightmap[i][j-1]+air[i][j-1], heightmap[i][j+1]+air[i][j+1], heightmap[i-1][j]+air[i-1][j], heightmap[i+1][j]+air[i+1][j],
	              heightmap[i-1][j-1]+air[i-1][j-1],heightmap[i+1][j-1]+air[i+1][j-1],heightmap[i-1][j+1]+air[i-1][j+1],heightmap[i+1][j+1]+air[i+1][j+1]]

			var target_location = 10000
			for k in range(0,8):
				target_location = min(target_location,d1[k])

			for k in range(0,8):
				if int(target_location) == int(d1[k]):
					target_location = k

			if air[i][j] > 0.01:
				if heightmap[i][j] >= target_location and air[i][j] != 0:
					if target_location == 0:
						air[i][j] -= air[i][j]/2
						air[i][j-1] += air[i][j]
						if enable_erosion == true:
							sediment[i][j] -= sediment[i][j]/2
							sediment[i][j-1] += sediment[i][j]

					if target_location == 1:
						air[i][j] -= air[i][j]/2
						air[i][j+1] += air[i][j]
						if enable_erosion == true:
							sediment[i][j] -= sediment[i][j]/2
							sediment[i][j+1] += sediment[i][j]

					if target_location == 2:
						air[i][j] -= air[i][j]/2
						air[i-1][j] += air[i][j]
						if enable_erosion == true:
							sediment[i][j] -= sediment[i][j]/2
							sediment[i-1][j] += sediment[i][j]

					if target_location == 3:
						air[i][j] -= air[i][j]/2
						air[i+1][j] += air[i][j]
						if enable_erosion == true:
							sediment[i][j] -= sediment[i][j]/2
							sediment[i+1][j] += sediment[i][j]
							
					if target_location == 4:
						air[i][j] -= air[i][j]/2
						air[i-1][j-1] += air[i][j]
						if enable_erosion == true:
							sediment[i][j] -= sediment[i][j]/2
							sediment[i-1][j-1] += sediment[i][j]
							
					if target_location == 5:
						air[i][j] -= air[i][j]/2
						air[i+1][j-1] += air[i][j]
						if enable_erosion == true:
							sediment[i][j] -= sediment[i][j]/2
							sediment[i+1][j-1] += sediment[i][j]
					if target_location == 6:
						air[i][j] -= air[i][j]/2
						air[i-1][j+1] += air[i][j]
						if enable_erosion == true:
							sediment[i][j] -= sediment[i][j]/2
							sediment[i-1][j+1] += sediment[i][j]
					if target_location == 7:
						air[i][j] -= air[i][j]/2
						air[i+1][j+1] += air[i][j]
						if enable_erosion == true:
							sediment[i][j] -= sediment[i][j]/2
							sediment[i+1][j+1] += sediment[i][j]

				if dry[i][j] >= 0.6:
					dry[i][j] -=2.5
					dry[i][j-1] -= 0.6
					dry[i][j+1] -= 0.6
					dry[i-1][j] -= 0.6
					dry[i+1][j] -= 0.6

			if enable_rain == true:
				if rain == true:
					if randi() % 500 == 0:
						air[i][j] += 0.5
					if randi() % 1000000 == 0:
						rain = false

				if rain == false:
					air[i][j] -= 0.025
					if air[i][j] < 0:
						air[i][j] = 0
					if randi() % 200000 == 0:
						rain = true

			if enable_erosion == true:
				if air[i][j] > 0.01 and sediment[i][j] < 0.05:
					heightmap[i][j] -= rock_hardness[i][j]
					sediment[i][j] += rock_hardness[i][j]

				if air[i][j] <= 0.2:
					heightmap[i][j] += sediment[i][j]
					sediment[i][j] -= sediment[i][j]

			if enable_evaporation == true:
					air[i][j] -= 0.025
					if air[i][j] < 0:
						air[i][j] = 0
						
func generate_map():
	for i in range(map_size+1):

		air.append([])
		heightmap.append([])
		dry.append([])
		rock_hardness.append([])
		sediment.append([])

		if i != map_size or i != map_size + 1:
			countlistx.append(i)
		for j in range(map_size+1):

			var height = (noise.get_noise_2d(i,j)*35)+50+(rand_range(0,0.8))
			height = abs(height)
			var rock_H = (rock.get_noise_2d(i,j)/75)
			rock_H = abs(rock_H)

			heightmap[i].append(abs(height))
			rock_hardness[i].append(abs(rock_H)*5)
			air[i].append(0)
			sediment[i].append(0)
			dry[i].append((rand_range(1,2)/100))



func randomize_X():
#warning-ignore:unused_variable
	for i in range(map_size+1):
		var temp = randi()%countlistx.size()
		finallistx.append(countlistx[temp])
		countlistx.remove(temp)

func randomize_Y():
	for i in range(map_size+1):
		countlisty.append(i)
#warning-ignore:unused_variable
	for i in range(map_size+1):
		var temp = randi()%countlisty.size()
		finallisty.append(countlisty[temp])
		countlisty.remove(temp)


func _draw():
	for i in range(map_size):
		for j in range(map_size):
			var aircolor = (air[j][i]/1.5)
			var heightcolor = ((heightmap[j][i])-42)/35
			var dryness = (dry[j][i]/150)+0.7
			if aircolor > 0.7:
		        aircolor= rand_range(0.7,0.8)
			var x = (j*size+size)+100
			var y = (i*size+size)
			if heightmap[j][i] == 80:
				draw_rect(Rect2((j*size)+100,(i*size),x,y),Color(1,1,1))
			else:
#				draw_rect(Rect2((j*size)+100,(i*size),x,y),Color(((heightcolor/2)+dryness/3)+0.05,heightcolor/(dryness)+0.001,aircolor))
				if heightmap[j][i] <= 45:
					draw_rect(Rect2((j*size)+100,(i*size),x,y),Color((dryness/3)+(sediment[i][j]/10),((heightcolor-rock_hardness[i][j]*3)),aircolor-(sediment[i][j])))
				if heightmap[j][i] > 45 and heightmap[j][i] < 55:
					draw_rect(Rect2((j*size)+100,(i*size),x,y),Color((dryness/3)+(sediment[i][j]/10),(heightcolor-rock_hardness[i][j]*3)/(dryness)+0.001,aircolor-(sediment[i][j])))
				if heightmap[j][i] >= 55:
					draw_rect(Rect2((j*size)+100,(i*size),x,y),Color(((heightcolor/3.5)+dryness/3)+(sediment[i][j]/10),(heightcolor-rock_hardness[i][j]*3)/(dryness)+0.001,aircolor-(sediment[i][j])))
					

func pen():
	stop_click = false
	var mouse = get_viewport().get_mouse_position()
	mouse = (mouse/7)
	if mouse[0] < 14:
		stop_click = true
	else:
		if Input.is_mouse_button_pressed(1):
			if build == true and dig == false and add_water == false and stop_click == false and create == false:
				heightmap[mouse[0]-14][mouse[1]] = 800
				stop_click = true
			if dig == true and build == false and add_water == false and stop_click == false:
				heightmap[mouse[0]-14][mouse[1]] -= 0.5
				heightmap[mouse[0]-13][mouse[1]] -= 0.5
				heightmap[mouse[0]-15][mouse[1]] -= 0.5
				heightmap[mouse[0]-14][mouse[1]-1] -= 0.5
				heightmap[mouse[0]-14][mouse[1]+1] -= 0.5
				heightmap[mouse[0]-13][mouse[1]-1] -= 0.45
				heightmap[mouse[0]-13][mouse[1]+1] -= 0.45
				heightmap[mouse[0]-15][mouse[1]-1] -= 0.45
				heightmap[mouse[0]-15][mouse[1]+1] -= 0.45

			if create == true and build == false and add_water == false and stop_click == false and dig == false:
				heightmap[mouse[0]-14][mouse[1]] += 0.5
				heightmap[mouse[0]-13][mouse[1]] += 0.5
				heightmap[mouse[0]-15][mouse[1]] += 0.5
				heightmap[mouse[0]-14][mouse[1]-1] += 0.5
				heightmap[mouse[0]-14][mouse[1]+1] += 0.5
				heightmap[mouse[0]-13][mouse[1]-1] += 0.45
				heightmap[mouse[0]-13][mouse[1]+1] += 0.45
				heightmap[mouse[0]-15][mouse[1]-1] += 0.45
				heightmap[mouse[0]-15][mouse[1]+1] += 0.45


				stop_click = true
			if add_water == true and build == false and dig == false and stop_click == false and create == false:
				for i in rand_range(0,100):
					air[mouse[0]-14][mouse[1]] += 0.9999
				stop_click = true


#GUI Functions here
#warning-ignore:unused_argument
func _on_Rain_Checkbox_toggled(button_pressed):
	if enable_rain == false:
		enable_rain = true
	elif enable_rain == true:
		enable_rain = false

#warning-ignore:unused_argument
func _on_Build_Walls_Checkbox_toggled(button_pressed):
	if build == false:
		build = true
	elif build == true:
		build = false

#warning-ignore:unused_argument
func _on_Dig_Checkbox_toggled(button_pressed):
	if dig == false:
		dig = true
	elif dig == true:
		dig = false

#warning-ignore:unused_argument
func _on_Water_Checkbox_toggled(button_pressed):
	if add_water == false:
		add_water = true
	elif add_water == true:
		add_water = false

#warning-ignore:unused_argument
func _on_Erosion_Checkbox_toggled(button_pressed):
	if enable_erosion == false:
		enable_erosion = true
	elif enable_erosion == true:
		enable_erosion = false

#warning-ignore:unused_argument
func _on_Evaporation_Checkbox_toggled(button_pressed):
	if enable_evaporation == false:
		enable_evaporation = true
	elif enable_evaporation == true:
		enable_evaporation = false

#warning-ignore:unused_argument
func _on_Create_Checkbox_toggled(button_pressed):
	if create == false:
		create = true
	elif create == true:
		create = false