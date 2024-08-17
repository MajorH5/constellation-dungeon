#Author: Jacob

# Change the boardWidth and boardHeight depending on the size of the room
# You can change the parameters as well if it does take a long time to generate

# Call generateBoard, this takes in a starting list and a ending list which are
# arrays that contains Vector2i's.

class_name RoomGenerator
extends Node2D
var rng = RandomNumberGenerator.new()

#Board parameters
var boardWidth = 20
var boardHeight = 10

#Game parameters
const tileSize = 1

#Cave generation parameters
const chanceToStartAlive = 0.5
const deathLimit = 3
const birthLimit = 4
const simulationNum = 1

var board = zeros(boardWidth, boardHeight)

#Makes a 2d array with all 0's
func zeros(x,y):
	var holderArray = []
	for height in range(y):
		holderArray.append([])
		for width in range(x):
			holderArray[height].append(0)
	return holderArray

#Initialize the board randomly
func startBoard():
	for y in range(boardHeight):
		for x in range(boardWidth):
			var randomInt = rng.randi_range(0,10)
			if randomInt < chanceToStartAlive*10:
				board[y][x] = 1
			else:
				board[y][x] = 0

#Counts number of alive neighbors given a coordinate
func countAliveNeigbors(x,y):
	var count = 0
	for x_offset in [-1,0,1]:
		for y_offset in [-1,0,1]:
			var neighborX = x + x_offset
			var neighborY = y + y_offset
			if (x_offset == 0 and y_offset ==0):
				pass
			elif neighborX < 0 or neighborY <0 or neighborX >= boardWidth or neighborY >= boardHeight:
				#count += 1
				pass
			elif board[neighborY][neighborX] == 1:
				count +=1
	return count

#Cellular automatia
func simulationStep():
	for iterations in range(simulationNum):
		for y in range(boardHeight):
			for x in range(boardWidth):
				var alive = countAliveNeigbors(x,y)
				if (board[y][x] == 1):
					if alive < deathLimit:
						board[y][x] = 0
					else:
						board[y][x] = 1
				else:
					if alive > birthLimit:
						board[y][x] = 1
					else:
						board[y][x] = 0

func doAStar(start, end):
	board[start[1]][start[0]] = 0
	board[end[1]][end[0]] = 0
	
	var AStarGrid = AStarGrid2D.new()
	AStarGrid.size = Vector2i(boardWidth, boardHeight)
	AStarGrid.cell_size = Vector2i(tileSize, tileSize)
	AStarGrid.default_compute_heuristic = 1
	AStarGrid.diagonal_mode = 1
	AStarGrid.update()
	
	for row in range(boardHeight):
		for col in range(boardWidth):
			if board[row][col] == 1:
				AStarGrid.set_point_solid(Vector2i(col,row))
				
	var res = AStarGrid.get_point_path(
		start,
		end
	)
	print(res)
	if res.size() == 0:
		return false
		
	# Debug use, uncomment to check the path.
	#for coord in res:
		#board[coord[1]][coord[0]] = 3
	return true

func makeBoard():
	startBoard()
	simulationStep()

func generateBoard(starting_list: Array[Vector2i], ending_list: Array[Vector2i]):
	while true:
		makeBoard()
		var paths_valid = true
		for start in starting_list:
			for end in ending_list:
				if (!doAStar(start,end)):
					paths_valid = false
					break
			if(!paths_valid):
				break
		if paths_valid:
			#printBoard()
			return board

func printBoard():
	for y in range(boardHeight):
		print(board[y])

