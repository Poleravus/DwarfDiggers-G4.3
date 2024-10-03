extends Node2D

var saveMapgen : Resource = MapGenSave.new()

var map_width = 200
var map_height = 200
var ambar_rock_scene = preload("res://Scenes/Entidades/AmbarRock.tscn")
@onready var juego = get_node("/root/Mundo/Juego")
var rng = RandomNumberGenerator.new()
var tiles = []
var factor = map_height * map_width


func _ready():
	position.x = ( ( (map_width * 16) / 2 ) * -1)
	position.y = ( ( (map_height * 16) / 2 ) * -1)
	nuevoMapa()
	
		
func nuevoMapa():
	if(tiles):
		tiles.clear()
	randomize()
	setup()
	liberar_medio()
	for _i in range(6):
		iterarTiles()
	mapgen()
	encontrarVacios()
	spawn_curas()

func spawn_curas():
	for i in range(10):
		var ambar_rock = ambar_rock_scene.instantiate()
		ambar_rock.position.x = ceil(randf_range( (( (map_width * 16) / 2 ) * -1)+50, ( (map_width * 16) / 2 )-50))
		ambar_rock.position.y = ceil(randf_range( (( (map_height * 16) / 2 ) * -1)+50, ( (map_height * 16) / 2 )-50))
		juego.add_child(ambar_rock)
		

func setup(_semilla = randi()):
	var cont = 0
	var semilla = _semilla
	var rand = RandomNumberGenerator.new()
	rand.set_seed(semilla)
	for _i in range(map_width):
		for _j in range(map_height):
			cont+=1
			var solid = rand.randf() < 0.45
			tiles.append(solid)
	print("Semilla : ",semilla," Cont: ",cont)
	saveMapgen.set_seed(semilla)
	ScriptGuardado.mapgenData = saveMapgen
	
func liberar_medio():
	var x
	var y
	var indice
	# Asumiendo que map_width es una variable global o está definida en el alcance de la clase
	for i in range(-5, 6):  # Rango de -10 a 10 (inclusive)
		y = map_width / 2 + i
		for j in range(-5, 6):  # Rango de -10 a 10 (inclusive)
			x = map_width / 2 + j
			indice = int(x + y * map_width)  # Asegurarse de que el índice sea un número entero
			tiles[indice] = false  # Suponiendo que tiles es un array global o definido antes de la función

func mapgen():
	for i in range(map_width):
		for j in range(map_height):
			var solid = esSolido(i,j)
			if (solid):
				$Layer0.set_cell(Vector2i(i,j),0)
			else:
				$Layer0.set_cell(Vector2i(i,j),2)

func iterarTiles():
	var nuevasTiles = []
	for j in range(map_height):
		for i in range(map_width):
			var num = numParedesAlrededor(i,j)
			var nuevaTile = num >=5
			nuevasTiles.append(nuevaTile)
				
	tiles = nuevasTiles
	
func encontrarVacios():
	for i in range(map_width):
		for j in range(map_height):
			if estaEncerrada(i,j):
				$Layer0.set_cell(Vector2i(i,j),1)
#			if (x == 0 || y ==0 || x == map_width-1 || y == map_height-1  ):
#				$TileMap.set_cell(i,j,2)
	
	
func estaEncerrada(x,y):
	if esSolido(x-1,y) and esSolido(x,y-1) and esSolido(x,y+1)and esSolido(x+1,y):
		return true
		
	else:
		return false

func numParedesAlrededor(x,y):
	var num = 0
	for i in range(-1,2):
		for j in range(-1,2):
			if(esSolido(x+i,y+j)):
				num+=1
	return num

func esSolido(x,y):
	var indice=x + y * map_width
	if (x == 0 || y ==0 || x == map_width-1 || y == map_height-1  ):
		return true;
	if indice>=map_height*map_width:
		indice = (map_height*map_width)-1
	return tiles [indice]
