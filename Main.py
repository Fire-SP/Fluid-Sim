# air on higher value squares will try to flow to lower value squares
# a square can only hold a certain amount of air ( Depends on square value ). If square is full, air will not flow into it.

import random, pygame, time, sys
from noise import pnoise2
global density
noise_X = random.randint(-10000,10000)
noise_Y = random.randint(-10000,10000)
noise_zoom = 0.05
mapsize = 100
size = 10
density = 4


pygame.init()
info = pygame.display.Info()
screen = pygame.display.set_mode(((mapsize-1)*size,(mapsize-1)*size))

air = []
heightmap = []

def update_air_index(i,j):
    if i == 0 or i == (mapsize-1) or j == 0 or j == (mapsize-1):
        d1 = [255,255,255,255]
        
    else:
        d1 = [heightmap[i][j-1]+air[i][j-1], heightmap[i][j+1]+air[i][j+1], heightmap[i-1][j]+air[i-1][j], heightmap[i+1][j]+air[i+1][j],
              heightmap[i-1][j-1]+air[i-1][j-1],heightmap[i+1][j-1]+air[i+1][j-1],heightmap[i-1][j+1]+air[i-1][j+1],heightmap[i+1][j+1]+air[i+1][j+1]]
        
        target_location = d1.index(min(d1))
        old_air = air[i][j]
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

        if old_air == air[i][j]:
            a1 = [air[i][j-1], air[i][j+1], air[i-1][j], air[i+1][j],air[i-1][j-1],air[i+1][j-1],air[i-1][j+1],air[i+1][j+1]]
            
            target_location2 = a1.index(min(a1))
            random.shuffle(a1)
            
            
            if air[i][j-1] <= air[i][j]:
                if target_location2 == 0:
                    air[i][j] -= air[i][j]/2
                    air[i][j-1] += air[i][j]

            if air[i][j+1] <= air[i][j]:
                if target_location2 == 1:
                    air[i][j] -= air[i][j]/2
                    air[i][j+1] += air[i][j]

            if air[i-1][j] <= air[i][j]: 
                if target_location2 == 2:
                    air[i][j] -= air[i][j]/2
                    air[i-1][j] += air[i][j]

            if air[i+1][j] <= air[i][j]:
                if target_location2 == 3:
                    air[i][j] -= air[i][j]/2
                    air[i+1][j] += air[i][j]

            if air[i-1][j-1] <= air[i][j]: 
                if target_location2 == 4:
                    air[i][j] -= air[i][j]/2
                    air[i-1][j-1] += air[i][j]
                
            if air[i+1][j-1] <= air[i][j]: 
                if target_location2 == 5:
                    air[i][j] -= air[i][j]/2
                    air[i+1][j-1] += air[i][j]
            
            if air[i-1][j+1] <= air[i][j]: 
                if target_location2 == 6:
                    air[i][j] -= air[i][j]/2
                    air[i-1][j+1] += air[i][j]
                    
            if air[i+1][j+1] <= air[i][j]: 
                if target_location2 == 7:
                    air[i][j] -= air[i][j]/2
                    air[i+1][j+1] += air[i][j]

                
def update_air():
    global i_list, j_list
    random.shuffle(i_list)
    random.shuffle(j_list)
    for i in i_list:
        for j in j_list:
            update_air_index(i,j)
        

def generate_map():
    global i_list,j_list
    for i in range(mapsize+1):
        air.append([])
        heightmap.append([])
        for j in range(mapsize+1):
            height = pnoise2((i + (noise_X*5))*noise_zoom, (j + (noise_Y))*noise_zoom)*120
            height += 15 + (random.randint(0,2500)/10000)
            if height < 0:
                height = 0
            heightmap[i].append(abs(height))
            air[i].append(3)
    i_list = [ i for i in range(mapsize)]
    j_list = [ i for i in range(mapsize)]
            
def key_press(): # Added by u/ delijati. Thank you!
    raw_mouse = pygame.mouse.get_pos()
    mouse = (raw_mouse[0] / size, raw_mouse[1] / size)
    
    
    global density
    for event in pygame.event.get():
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_c and pygame.key.get_mods() and pygame.KMOD_CTRL:
                print("Quitting with Ctrl-C...")
                sys.exit(0)
            if event.key == pygame.K_d:
                density = int(input("Density? "))

        if pygame.mouse.get_pressed()[0] == 1:
            air[int(mouse[0])][int(mouse[1])] += 3

        if pygame.mouse.get_pressed()[2] == 1:
            heightmap[int(mouse[0])][int(mouse[1])] = 10000

            
def render():
    for i in range(mapsize):
        for j in range(mapsize):
            aircolor = air[j][i]*25
            heightcolor = (heightmap[j][i])
            if int(heightcolor) > 255:
                heightcolor = 255
            if aircolor > 255:
                aircolor=255
            #pygame.draw.circle(screen,(heightcolor,heightcolor,aircolor),(j*size,i*size),size)
            pygame.draw.rect(screen,(heightcolor,heightcolor,aircolor),(j*size,i*size,size,size))

            
            
generate_map()     
while True:
    update_air()
    render()
    key_press()
    pygame.display.flip()
