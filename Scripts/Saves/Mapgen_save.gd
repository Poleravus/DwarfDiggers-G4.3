class_name MapGenSave
extends Resource

@export var seedMapa: int

func set_seed(valor = 0) -> void:
	seedMapa = valor
	
func get_seed() -> int:
	return seedMapa
