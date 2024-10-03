extends Node

var datos_mejoras 
var on_android = false

func _ready():
	if OS.get_name() == "Android":
		on_android = true
	datos_mejoras = importar_archivo_json("res://DatosMejoras.json")
	

func importar_archivo_json(path:String): #Retorna un archivo JSON importado
	var archivo_data = FileAccess.open(path,FileAccess.READ)
	var test_json_conv = JSON.new()
	test_json_conv.parse(archivo_data.get_as_text())
	var data_json = test_json_conv.get_data()
	
	archivo_data.close() 
	
	var data_output = data_json
	return(data_output)
