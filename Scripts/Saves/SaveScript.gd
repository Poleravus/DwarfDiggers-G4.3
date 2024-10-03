extends Node
#Cosas a guardar
#-Seed del mapa
#-Datos del personaje
#-Armas del personaje
#Oleada y nivel
#El guardado reinicia el personaje al comienzo de la ultima oleada y nivel.

#Posible arquitectura
#Crear scripts de guardado (extienden de Resource) para cada nodo que 
#contenga informacion a guardar // Player , mapgen, etc
#Crear la logica en estos scripts para guardar en ellos los datos al igual que cargarlos
#En el script de Save , guardar los scripts de guardado individuales.
var SAVE_FILE_NAME : String #Ambas variables definidas en Login.gd
var SAVE_GAME_PATH : String #"user://save/id+username/ "data"

var SaveEncontrado :bool

var estadisticasGuardar : EstadisticasSave 

var mapgenData: MapGenSave 

var contenedor : Resource = Resource_de_Guardado.new()
var isGuest = false
var userID


func reset() -> void:
	self.SAVE_FILE_NAME = ""
	self.SAVE_GAME_PATH = ""
	self.SaveEncontrado = false
	self.estadisticasGuardar = null
	self.mapgenData = null
	self.contenedor = Resource_de_Guardado.new()
	
func set_SaveEncontrado(valor:bool) -> void:
	self.SaveEncontrado = valor
	
func get_SaveEncontrado() ->bool:
	return self.SaveEncontrado
	
func write_savegame() -> void:
	contenedor.contenedor_init(estadisticasGuardar,mapgenData)

	var err = ResourceSaver.save (contenedor, SAVE_GAME_PATH+SAVE_FILE_NAME)
	if err:
		print("ERROR:",err)
		print(SAVE_GAME_PATH)
	load_savegame()
		
func load_savegame():
	contenedor = ResourceLoader.load(SAVE_GAME_PATH+SAVE_FILE_NAME).duplicate(true)
	print("Seed despues de load: ",contenedor._mapgenData.get_seed())
