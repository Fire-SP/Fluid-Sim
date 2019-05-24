extends Node2D
var noise = OpenSimplexNoise.new()

var map_size = 75
var size = 7
var rain = false
var enable_rain = false
var air = []
var heightmap = []
var dry = []
var countlistx = []
var finallistx = []
var countlisty = []
var finallisty = []

var build = false
var dig = false
var add_water = false
var stop_click = false


func _ready():
	randomize()
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 70
	noise.persistence = 0.75
	generate_map()
	randomize_X()
	randomize_Y()


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
	
					if target_location == 1:
		                air[i][j] -= air[i][j]/2
		                air[i][j+1] += air[i][j]
	
					if target_location == 2:
		                air[i][j] -= air[i][j]/2
		                air[i-1][j] += air[i][j]
	
					if target_location == 3:
		                air[i][j] -= air[i][j]/2
		                air[i+1][j] += air[i][j]
	
					if target_location == 4:
		                air[i][j] -= air[i][j]/2
		                air[i-1][j-1] += air[i][j]
	
					if target_location == 5:
		                air[i][j] -= air[i][j]/2
		                air[i+1][j-1] += air[i][j]
	
					if target_location == 6:
		                air[i][j] -= air[i][j]/2
		                air[i-1][j+1] += air[i][j]
	
					if target_location == 7:
		                air[i][j] -= air[i][j]/2
		                air[i+1][j+1] += air[i][j]
						
						
						
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
					air[i][j] -= 0.035
					if air[i][j] < 0:
						air[i][j] = 0
					if randi() % 200000 == 0:
						rain = true
						
	
func generate_map():
	for i in range(map_size+1):
		air.append([])
		heightmap.append([])
		dry.append([])
		if i != map_size or i != map_size + 1:
			countlistx.append(i)
		for j in range(map_size+1):
			var height = (noise.get_noise_2d(i,j)*35)+50
			height = abs(height)
			heightmap[i].append(abs(height))
			air[i].append(0)
			dry[i].append((rand_range(1,2)/100))

			
			
func randomize_X():
	for i in range(map_size+1):
		var temp = randi()%countlistx.size()
		finallistx.append(countlistx[temp])
		countlistx.remove(temp)

func randomize_Y():
	for i in range(map_size+1):
		countlisty.append(i)
	for i in range(map_size+1):
		var temp = randi()%countlisty.size()
		finallisty.append(countlisty[temp])
		countlisty.remove(temp)
		

func _draw():
	for i in range(map_size):
		for j in range(map_size):
			var aircolor = (air[j][i]/1.5)
			var heightcolor = ((heightmap[j][i])-46)/25
			var dryness = (dry[j][i]/200)+0.7
			if aircolor > 0.7:
		        aircolor= 0.7
			var x = (j*size+size)+100
			var y = (i*size+size)
			if heightmap[j][i] == 80:
				draw_rect(Rect2((j*size)+100,(i*size),x,y),Color(1,1,1))
			else:
				draw_rect(Rect2((j*size)+100,(i*size),x,y),Color(((heightcolor/2)+dryness/3)+0.05,heightcolor/(dryness)+0.001,(aircolor/1.2)+0.15))

func pen():
	stop_click = false
	var mouse = get_viewport().get_mouse_position()
	mouse = (mouse/7)
	if mouse[0] < 14:
		stop_click = true
	else:
		if Input.is_mouse_button_pressed(1):
			if build == true and dig == false and add_water == false and stop_click == false:
				heightmap[mouse[0]-14][mouse[1]] = 80
				stop_click = true
			if dig == true and build == false and add_water == false and stop_click == false:
				heightmap[mouse[0]-14][mouse[1]] -= 1
				heightmap[mouse[0]-13][mouse[1]] -= 1
				heightmap[mouse[0]-15][mouse[1]] -= 1
				heightmap[mouse[0]-14][mouse[1]-1] -= 1
				heightmap[mouse[0]-14][mouse[1]+1] -= 1
				heightmap[mouse[0]-13][mouse[1]-1] -= 0.75
				heightmap[mouse[0]-13][mouse[1]+1] -= 0.75
				heightmap[mouse[0]-15][mouse[1]-1] -= 0.75
				heightmap[mouse[0]-15][mouse[1]+1] -= 0.75
				
				
				stop_click = true
			if add_water == true and build == false and dig == false and stop_click == false:
				for i in rand_range(0,100):
					air[mouse[0]-14][mouse[1]] += 0.9999
				stop_click = true
				

#GUI Functions here
func _on_Rain_Checkbox_toggled(button_pressed):
	if enable_rain == false:
		enable_rain = true
	elif enable_rain == true:
		enable_rain = false

func _on_Build_Walls_Checkbox_toggled(button_pressed):
	if build == false:
		build = true
	elif build == true:
		build = false

func _on_Dig_Checkbox_toggled(button_pressed):
	if dig == false:
		dig = true
	elif dig == true:
		dig = false

func _on_Water_Checkbox_toggled(button_pressed):
	if add_water == false:
		add_water = true
	elif add_water == true:
		add_water = false

