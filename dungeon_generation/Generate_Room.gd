#Author: Jacob
extends Node2D
var rng = RandomNumberGenerator.new()

#const tile = preload("res://root/scenes/maps/Random_Map/Assets/Tile.tscn")
#const startTile = preload("res://root/scenes/maps/Random_Map/Assets/start.tscn")
#const endTile = preload("res://root/scenes/maps/Random_Map/Assets/end.tscn")
#var player = preload("res://root/entities/player/player.tscn").instantiate()

#Game parameters
#Change to null if you want random gameWidth and gameHeight for variation
const gameWidth = 20
const gameHeight = 20
const tileSize = 1

#Cave generation parameters
const chanceToStartAlive = 0.4
const chanceOfWall = 0.01
const deathLimit = 3
const birthLimit = 4
const simulationNum = 30

#Board parameters
const boardWidth = int(gameWidth / tileSize)
const boardHeight = int(gameHeight / tileSize)
var board = zeros(boardWidth, boardHeight)

#starting and ending generation
var start = Vector2(0,0)
var end = Vector2(19,19)

#Makes a 2d array with all 0's
func zeros(x,y):
	var holderArray = []
	for width in x:
		holderArray.append([])
		for height in y:
			holderArray[width].append(0)
	return holderArray

#Initialize the baord randomly
func startBoard():
	for row in boardWidth:
		for col in boardHeight:
			var randomInt = rng.randi_range(0,10000)
			if randomInt < chanceToStartAlive*10000:
				board[row][col] = 1

#Clears board, not really used, but just incase.
func clearBoard():
	for row in boardWidth:
		for col in boardHeight:
			board[row][col] = 0

#Counts number of alive neighbors given a coordinate
func countAliveNeigbors(x,y):
	var count = 0
	for row in range(-1,2):
		for col in range(-1,2):
			var neighborX = x + row
			var neighborY = y + col
			if (row == 0 and col ==0):
				pass
			elif neighborX < 0 or neighborY <0 or neighborX >= boardWidth or neighborY >= boardHeight:
				count += 1
			elif board[neighborX][neighborY] == 1:
				count +=1
	return count

#Cellular automatia
func simulationStep():
	for iterations in simulationNum:
		var randomInt = rng.randi_range(1,10000)
		for row in boardWidth:
			for col in boardHeight:
				var alive = countAliveNeigbors(row,col)
				if (board[row][col] == 1):
					if alive < deathLimit:
						board[row][col] = 0
					else:
						if randomInt > chanceOfWall*10000:
							board[row][col] = 1
				else:
					if alive > birthLimit:
						if randomInt > chanceOfWall*10000:
							board[row][col] = 1
					else:
						board[row][col] = 0

func doAStar():
	var AStarGrid = AStarGrid2D.new()
	AStarGrid.size = Vector2i(boardWidth, boardHeight)
	AStarGrid.cell_size = Vector2i(tileSize, tileSize)
	
	for row in boardWidth:
		for col in boardHeight:
			if board[row][col] == 1:
				AStarGrid.set_point_solid(Vector2i(row,col), true)
	print('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
	var res = AStarGrid.get_point_path(
		start,
		end
	)
	if res.size() == 0:
		return false
	print('ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg')
	return true

#Draws the tiles on map
func drawMap():
	for x in boardWidth:
		for y in boardHeight:
			if(board[x][y]==1):
				pass
				#var piece = tile.instantiate()
				#piece.position = Vector2(x*tileSize,y*tileSize)
				#add_child(piece)

#generates board, this will always generate a viable board
func generateBoard():
	#Starts the board randomly
	startBoard()
	#Does cellular atomatia
	simulationStep()
	#Checks if the map is viable
	while(!doAStar()):
		#If not, clears board and keeps generating new board until something viable
		clearBoard()
		startBoard()
		simulationStep()
	

@rpc("call_local")
func _ready():
	#spawn = Vector2(start[0]*tileSize,start[1]*tileSize)
	generateBoard()
	print(board)
	#drawMap()
	#Global.updated_respawn(Vector2(start[0]*tileSize,start[1]*tileSize))
	

func _process(delta):
	pass
