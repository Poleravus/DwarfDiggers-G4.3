extends Node2D

signal mejorarPico
signal mejorarArma
signal mejorarAmetralladora
signal mejorarBobina
signal mejorarSniper
signal mejorarLanzallamas
signal inventarioPico
signal inventarioAmetralladora
signal inventarioSniper
signal inventarioBobina
signal inventarioLanzallamas

var nivelPico = 0
var nivelTesla = 0
var nivelLanzallamas = 0
var nivelGun = 0
var nivelSniper = 0

func _ready():
	for arma in self.get_children():
		if arma.get_name() == "Pico":
			emit_signal("inventarioPico")
			nivelPico = 1
		if arma.get_name() == "Ametralladora":
			emit_signal("inventarioAmetralladora")
			nivelGun = 1
		if arma.get_name() == "Bobina_tesla":
			emit_signal("inventarioBobina")
			nivelTesla = 1
		if arma.get_name() == "Sniper":
			emit_signal("inventarioSniper")
			nivelSniper = 1
		if arma.get_name() == "Lanzallamas":
			emit_signal("inventarioLanzallamas")
			nivelLanzallamas = 1
	

# Getters
func get_nivelPico():
	return nivelPico

func get_nivelTesla():
	return nivelTesla

func get_nivelLanzallamas():
	return nivelLanzallamas

func get_nivelGun():
	return nivelGun

func get_nivelSniper():
	return nivelSniper

# Setters
func set_nivelPico(value):
	nivelPico = value

func set_nivelTesla(value):
	nivelTesla = value

func set_nivelLanzallamas(value):
	nivelLanzallamas = value

func set_nivelGun(value):
	nivelGun = value

func set_nivelSniper(value):
	nivelSniper = value

func _on_Player_set_mejora_pico():
	for arma in self.get_children():
		if arma.get_name() == "Pico":
			emit_signal("mejorarPico")
			set_nivelPico(get_nivelPico()+1)
			return
	var pico = load("res://Scenes/Armas/Pico.tscn").instantiate()
	emit_signal("inventarioPico")
	set_nivelPico(1)
	add_child(pico)


func _on_Player_set_mejora_ametra():
	for arma in self.get_children():
		if arma.get_name() == "Ametralladora":
			emit_signal("mejorarAmetralladora")
			set_nivelGun(get_nivelGun()+1)
			return  
	var ametralladora = load("res://Scenes/Armas/Ametralladora.tscn")
	emit_signal("inventarioAmetralladora")
	set_nivelGun(1)
	add_child(ametralladora.instantiate())

func _on_EstadisticasPersonaje_actualizarDamageArma():
	for arma in self.get_children():
		arma.set_damage()



func _on_Player_set_mejora_bobina():

	for arma in self.get_children():
		if arma.get_name() == "Bobina_tesla":

			emit_signal("mejorarBobina")
			set_nivelTesla(get_nivelTesla()+1)
			return  
	var bobina = load("res://Scenes/Armas/Bobina_tesla.tscn")
	emit_signal("inventarioBobina")
	set_nivelTesla(1)
	add_child(bobina.instantiate())


func _on_Player_set_mejora_sniper():
	for arma in self.get_children():
		if arma.get_name() == "Sniper":
			emit_signal("mejorarSniper")
			set_nivelSniper(get_nivelSniper()+1)
			return  # Si la ametralladora ya existe, no necesitas instanciarla nuevamente
	var sniper = load("res://Scenes/Armas/Sniper.tscn")
	set_nivelSniper(1)
	emit_signal("inventarioSniper")
	add_child(sniper.instantiate())
	
func _on_Player_set_mejora_lanzallamas():
	for arma in self.get_children():
		if arma.get_name() == "Lanzallamas":
			emit_signal("mejorarLanzallamas")
			set_nivelLanzallamas(get_nivelLanzallamas()+1)
			return  # Si la ametralladora ya existe, no necesitas instanciarla nuevamente
	var lanzallamas = load("res://Scenes/Armas/Lanzallamas.tscn")
	emit_signal("inventarioLanzallamas")
	set_nivelLanzallamas(1)
	add_child(lanzallamas.instantiate())



