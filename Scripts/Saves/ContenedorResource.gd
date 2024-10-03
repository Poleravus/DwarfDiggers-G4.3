extends Resource
class_name Resource_de_Guardado

@export var  _estadisticasGuardar : Resource

@export var  _mapgenData: Resource

func contenedor_init(estadisticasResource:EstadisticasSave,mapGenResource:MapGenSave):
	self._estadisticasGuardar = estadisticasResource
	self._mapgenData = mapGenResource

