# air on higher value squares will try to flow to lower value squares
# a square can only hold a certain amount of air ( Depends on square value ). If square is full, air will not flow into it.

import random, pygame, time, sys, thorpy
from noise import pnoise2
global density
noise_X = random.randint(-1000,1000)
noise_Y = random.randint(-1000,1000)
noise_zoom = 0.05
mapsize = 250
size = 5
density = 2

noise_zoom = float(input("Noise? "))
mapsize = int(input("Mapsize? "))
size = int(input("Paritlcesize? "))
density = int(input("Density? "))

pygame.init()
info = pygame.display.Info()
screen = pygame.display.set_mode((mapsize*size,mapsize*size))

air = []
heightmap = []

def update_air_index(i,j):
    if i == 0 or i == (mapsize) or j == 0 or j == (mapsize-1):
        d1 = [255,255,255,255]
        
    else:
        d1 = [heightmap[i][j-1], heightmap[i][j+1], heightmap[i-1][j], heightmap[i+1][j],heightmap[i-1][j-1],heightmap[i+1][j-   1],heightmap[i-1][j+1],heightmap[i+1][j+1],heightmap[i][j]]

        target = min(d1)
        target_location = d1.index(min(d1))
        if target < 14 and random.randint(0,2) == 0 :
            target_location = random.randint(0,7)
        
        
        if air[i][j] >= 1:
            if heightmap[i][j] >= target:
                if air[i-1][j] <= density: 
                    if target_location == 2:
                        air[i][j] -= 1
                        air[i-1][j] += 1

                if air[i+1][j] <= density:
                    if target_location == 3:
                        air[i][j] -= 1
                        air[i+1][j] += 1
                        
                if air[i][j-1] <= density:
                    if target_location == 0:
                        air[i][j] -= 1
                        air[i][j-1] += 1

                if air[i][j+1] <= density:
                    if target_location == 1:
                        air[i][j] -= 1
                        air[i][j+1] += 1
                        
                if air[i-1][j-1] <= density: 
                    if target_location == 4:
                        air[i][j] -= 1
                        air[i-1][j-1] += 1
                        
                if air[i+1][j-1] <= density: 
                    if target_location == 5:
                        air[i][j] -= 1
                        air[i+1][j-1] += 1
                
                if air[i-1][j+1] <= density: 
                    if target_location == 6:
                        air[i][j] -= 1
                        air[i-1][j+1] += 1
                        
                if air[i+1][j+1] <= density: 
                    if target_location == 7:
                        air[i][j] -= 1
                        air[i+1][j+1] += 1
                        
                
      
def update_air():
    for i in range(mapsize):
        for j in range(mapsize):
            update_air_index(i,j)
        

def generate_map():
    for i in range(mapsize+1):
        air.append([])
        heightmap.append([])
        for j in range(mapsize):
            height = pnoise2((i + (noise_X))*noise_zoom, (j + (noise_Y))*noise_zoom)*10
            height += 15
            heightmap[i].append(abs(height))
            air[i].append(1)
            
def key_press(): # Added by u/ delijati. Thank you!
    global density
    for event in pygame.event.get():
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_c and pygame.key.get_mods() and pygame.KMOD_CTRL:
                print("Quitting with Ctrl-C...")
                sys.exit(0)
            if event.key == pygame.K_d:
                density = int(input("Density? "))

            
def render():
    for i in range(mapsize):
        for j in range(mapsize):
            aircolor = air[j][i]*25
            heightcolor = int(heightmap[j][i]*3)
            if int(heightcolor) > 255:
                heightcolor = 255
            if aircolor > 255:
                aircolor=255
            pygame.draw.circle(screen,(heightcolor*1.2,heightcolor,aircolor),(j*size,i*size),size)

            
            
generate_map()     
while True:
    update_air()
    render()
    key_press()
    pygame.display.flip()
