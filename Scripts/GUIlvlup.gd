extends Control

@onready var boton1 = $lvlupchains/opcion1
@onready var boton2 = $lvlupchains/opcion2
@onready var boton3 = $lvlupchains/opcion3

@onready var stats = get_node("/root/Mundo/Juego/Player/EstadisticasPersonaje")
@onready var conectorSignals = get_node("/root/Mundo/Juego/Player/Armas")



signal mejora_elegida(indiceMejora)


var arraytmp = []
var array = []
var mejoras = []

var menulvlupactivo = false

var mejorasNombres = []
var mejorasDesc = []
var mejorasSprites = []
var mejorasDatos = ["arma WIP","arma WIP","arma WIP"]
var mejorasEnPantalla = []

var nivelesMejoras = {"0":0,"1":0,"2":0,"6":0,"7":0,"8":0,"9":0}
#<indiceMejora , nivelMejora>
#0 Botas , 1 Pico , 2 Rango
# 3, 4 y 5 omitidos (MEJORAS EXTRA) ,DAÑO-VIDA-DINERO



# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false

#func _process(delta):
#	if Input.is_action_just_pressed("ui_accept"):
#		setMejoras()
	
func actualizarGUI():
	
	$lvlupchains/opcion1/Escalar/opcion1label.set_text(mejorasNombres[0])
	$lvlupchains/opcion2/Escalar/opcion2label.set_text(mejorasNombres[1])
	$lvlupchains/opcion3/Escalar/opcion3label.set_text(mejorasNombres[2])
	
	$lvlupchains/opcion1/Escalar/descripcion1.set_text(mejorasDesc[0])
	$lvlupchains/opcion2/Escalar/descripcion2.set_text(mejorasDesc[1])
	$lvlupchains/opcion3/Escalar/descripcion3.set_text(mejorasDesc[2])
	
	$lvlupchains/opcion1/Escalar/imagen1.set_texture(load(mejorasSprites[0]))
	$lvlupchains/opcion2/Escalar/imagen2.set_texture(load(mejorasSprites[1]))
	$lvlupchains/opcion3/Escalar/imagen3.set_texture(load(mejorasSprites[2]))

	setdatos()

	$lvlupchains/opcion1/Escalar/datos1.set_text(mejorasDatos[0])
	$lvlupchains/opcion2/Escalar/datos2.set_text(mejorasDatos[1])
	$lvlupchains/opcion3/Escalar/datos3.set_text(mejorasDatos[2])


func setdatos():
		if mejorasEnPantalla.has("0"):
				var indiceMejora = mejorasEnPantalla.find("0")
				var movActual = stats.get_velocidad_movimiento()
				var sum = int(mejorasDesc[indiceMejora])
				var movSiguiente = movActual + sum
				mejorasDatos[indiceMejora] = String(movActual)+ "->" + String(movSiguiente)
			
		if mejorasEnPantalla.has("1"):
				var indiceMejora = mejorasEnPantalla.find("1")
				var nivelPico = conectorSignals.get_nivelPico()
				
				match nivelPico:
					0: 
						mejorasDatos[indiceMejora] = ""
				
					1, 3: 
						var pico = get_node("/root/Mundo/Juego/Player/Armas/Pico")
						var damagePicoActualSinMejora = pico.preDamage
						var damagePicoActual = pico.preDamage * stats.get_damage()
						var sum = int(mejorasDesc[indiceMejora])
						var damagePicoSiguiente = (damagePicoActualSinMejora + sum) * stats.get_damage()
						mejorasDatos[indiceMejora] = String(damagePicoActual) + "->" + String(damagePicoSiguiente)
						
					2, 4:
						var pico = get_node("/root/Mundo/Juego/Player/Armas/Pico")
						var cdPicoActual = pico.tiempoCooldown
						var res = 1.0 - float(mejorasDesc[indiceMejora]) 
						var cdPicoSiguiente = cdPicoActual * res
						mejorasDatos[indiceMejora] = String(cdPicoActual) + "s -> " + String(cdPicoSiguiente) + "s"
						
#					3:
#						var pico = get_node("/root/Mundo/Juego/Player/Armas/Pico")
#						var damagePicoActual = pico.get_damage()
#						var sum = int(mejorasDesc[indiceMejora])
#						var damagePicoSiguiente = damagePicoActual + sum
#						mejorasDatos[indiceMejora] = String(damagePicoActual) + "->" + String(damagePicoSiguiente)
#
#					4:
#						var pico = get_node("/root/Mundo/Juego/Player/Armas/Pico")
#						var cdPicoActual = pico.tiempoCooldown
#						var res = 1.0 - float(mejorasDesc[indiceMejora]) 
#						var cdPicoSiguiente = cdPicoActual * res
#						mejorasDatos[indiceMejora] = String(cdPicoActual) + "s -> " + String(cdPicoSiguiente) + "s"
#
					5:
						var pico = get_node("/root/Mundo/Juego/Player/Armas/Pico")
						var rangoPicoActual = pico.rango_slash
						var sum = int(mejorasDesc[indiceMejora])
						var rangoPicoSiguiente = rangoPicoActual + sum
						mejorasDatos[indiceMejora] = String(rangoPicoActual) + "->" + String(rangoPicoSiguiente)
			
		if mejorasEnPantalla.has("2"):
				var indiceMejora = mejorasEnPantalla.find("2")
				var rangExpActual = stats.get_rango_recogida()
				var rangExpActualLim = limitar_a_centesimas(rangExpActual)
				var mul = float(mejorasDesc[indiceMejora])
				var rangExpSiguiente = rangExpActual * mul
				var rangExpSiguienteLim = limitar_a_centesimas(rangExpSiguiente)
				mejorasDatos[indiceMejora] = String(rangExpActualLim)+"->" + String(rangExpSiguienteLim)
		
		if mejorasEnPantalla.has("3"):
				var indiceMejora = mejorasEnPantalla.find("3")
				var damageActual = stats.get_damage()
				var sum = float(mejorasDesc[indiceMejora])
				var damageSiguiente = damageActual + sum
				mejorasDatos[indiceMejora] = String(damageActual)+ "->" + String(damageSiguiente)
				
		if mejorasEnPantalla.has("4"):
				var indiceMejora = mejorasEnPantalla.find("4")
				var dineroActual = stats.get_monedas()
				var sum = int(mejorasDesc[indiceMejora])
				var dineroSiguiente = dineroActual + sum
				mejorasDatos[indiceMejora] = String(dineroActual)+"->" + String(dineroSiguiente)
				
		if mejorasEnPantalla.has("5"):
				var indiceMejora = mejorasEnPantalla.find("5")
				var saludActual = int(stats.get_salud())
				var sum = int(mejorasDesc[indiceMejora])
				var saludSiguiente = int(saludActual + sum)
				if saludSiguiente > stats.get_salud_max():
					saludSiguiente = stats.get_salud_max()
				mejorasDatos[indiceMejora] = String(saludActual) + "->" + String(saludSiguiente)
		
		if mejorasEnPantalla.has("6"):
				var indiceMejora = mejorasEnPantalla.find("6")
				var nivelGun = conectorSignals.get_nivelGun()

				match nivelGun:
					0:
						mejorasDatos[indiceMejora] = ""
					1, 3:
						var gun = get_node("/root/Mundo/Juego/Player/Armas/Ametralladora")
						var damageGunActualSinMejora = gun.preDamage
						var damageGunActual = gun.preDamage * stats.get_damage()
						var sum = int(mejorasDesc[indiceMejora])
						var damageGunSiguiente = (damageGunActualSinMejora + sum) * stats.get_damage()
						mejorasDatos[indiceMejora] = String(damageGunActual) + "->" + String(damageGunSiguiente)
					
					2:
						var gun = get_node("/root/Mundo/Juego/Player/Armas/Ametralladora")
						var cdGunActual = gun.tiempoCooldown
						var res = 1.0 - float(mejorasDesc[indiceMejora]) 
						var cdGunSiguiente = cdGunActual * res
						mejorasDatos[indiceMejora] = String(cdGunActual) + "s -> " + String(cdGunSiguiente) + "s"
						
#					3:
#						var gun = get_node("/root/Mundo/Juego/Player/Armas/Ametralladora")
#						var damageGunActual = gun.preDamage * stats.get_damage()
#						var sum = int(mejorasDesc[indiceMejora])
#						var damageGunSiguiente = damageGunActual + sum
#						mejorasDatos[indiceMejora] = String(damageGunActual) + "->" + String(damageGunSiguiente)
#
					4: 
						var gun = get_node("/root/Mundo/Juego/Player/Armas/Ametralladora")
						var cdGunActual = gun.tiempoCooldown
						var municionGunActual = gun.ammo_max
						var municionGunSiguiente = 45
						var res = 1.0 - float(mejorasDesc[indiceMejora]) 
						var cdGunSiguiente = cdGunActual * res
						mejorasDatos[indiceMejora] = String(cdGunActual) + "s->" + String(cdGunSiguiente) + "s " + String(municionGunActual) + "->" + String(municionGunSiguiente)
						
					5:
						var gun = get_node("/root/Mundo/Juego/Player/Armas/Ametralladora")
						var GunRangoActual= gun.RANGO_BASE
						var reloadTimeGun = gun.RELOAD_TIME_BASE 
						var sum = int(mejorasDesc[indiceMejora])
						var GunRangoSiguiente =  GunRangoActual + sum
						mejorasDatos[indiceMejora] = String(GunRangoActual) + "->" + String(GunRangoSiguiente) + "  " + String(reloadTimeGun) + "s->0s"
			
		if mejorasEnPantalla.has("7"):
				var indiceMejora = mejorasEnPantalla.find("7")
				var nivelTesla = conectorSignals.get_nivelTesla()
				
				match nivelTesla:
					0: 
						mejorasDatos[indiceMejora] = ""
						
					1, 3:
						var tesla = get_node("/root/Mundo/Juego/Player/Armas/Bobina_tesla")
						var damageTeslaActualSinMejora = tesla.preDamage
						var damageTeslaActual = tesla.preDamage * stats.get_damage()
						var sum = int(mejorasDesc[indiceMejora])
						var damageTeslaSiguiente = (damageTeslaActualSinMejora + sum) * stats.get_damage()
						mejorasDatos[indiceMejora] = String(damageTeslaActual) + "->" + String(damageTeslaSiguiente)
					2, 4:
						var tesla = get_node("/root/Mundo/Juego/Player/Armas/Bobina_tesla")
						var rangoTeslaActual = tesla.rango_inicial
						var sum = int(mejorasDesc[indiceMejora])
						var rangoTeslaSiguiente = rangoTeslaActual + sum
						mejorasDatos[indiceMejora] = String(rangoTeslaActual) + "->" + String(rangoTeslaSiguiente)
						
#					3:
#						var tesla = get_node("/root/Mundo/Juego/Player/Armas/Bobina_tesla")
#						var damageTeslaActual = tesla.preDamage * stats.get_damage()
#						var sum = int(mejorasDesc[indiceMejora])
#						var damageTeslaSiguiente = damageTeslaActual + sum
#						mejorasDatos[indiceMejora] = String(damageTeslaActual) + "->" + String(damageTeslaSiguiente)
#					4:
#						var tesla = get_node("/root/Mundo/Juego/Player/Armas/Bobina_tesla")
#						var rangoTeslaActual = tesla.rango_inicial
#						var sum = int(mejorasDesc[indiceMejora])
#						var rangoTeslaSiguiente = rangoTeslaActual + sum
#						mejorasDatos[indiceMejora] = String(rangoTeslaActual) + "->" + String(rangoTeslaSiguiente)
					5:
						var tesla = get_node("/root/Mundo/Juego/Player/Armas/Bobina_tesla")
						var damageTeslaActual = tesla.preDamage * stats.get_damage()
						var rangoTeslaActual = tesla.rango_inicial
						var sumDmg = 2
						var sumRng = 30
						var damageTeslaSiguiente = damageTeslaActual + sumDmg
						var rangoTeslaSiguiente =  rangoTeslaActual + sumRng
						mejorasDatos[indiceMejora] = String(damageTeslaActual) + "->" + String(damageTeslaSiguiente)+ " " + String(rangoTeslaActual) + "->" + String(rangoTeslaSiguiente)
		
		if mejorasEnPantalla.has("8"):
				var indiceMejora = mejorasEnPantalla.find("8")
				var nivelSniper = conectorSignals.get_nivelSniper()
				
				match nivelSniper:
					0:
						mejorasDatos[indiceMejora] = ""
					1, 3, 4:
						var sniper = get_node("/root/Mundo/Juego/Player/Armas/Sniper")
						var damageSniperActualSinMejoras = sniper.preDamage
						var damageSniperActual = sniper.preDamage * stats.get_damage()
						var sum = int(mejorasDesc[indiceMejora])
						var damageSniperSiguiente = (damageSniperActualSinMejoras + sum) * stats.get_damage()
						mejorasDatos[indiceMejora] = String(damageSniperActual) + "->" + String(damageSniperSiguiente)
					2:
						var sniper = get_node("/root/Mundo/Juego/Player/Armas/Sniper")
						var bouncesActual = sniper.bounces
						var sum =  int(mejorasDesc[indiceMejora])
						var bouncesSiguiente = bouncesActual + sum
						mejorasDatos[indiceMejora] = String(bouncesActual) + "->" + String(bouncesSiguiente)
#					3:
#						var sniper = get_node("/root/Mundo/Juego/Player/Armas/Sniper")
#						var damageSniperActual = sniper.preDamage * stats.get_damage()
#						var sum = int(mejorasDesc[indiceMejora])
#						var damageSniperSiguiente = damageSniperActual + sum
#						mejorasDatos[indiceMejora] = String(damageSniperActual) + "->" + String(damageSniperSiguiente)
#					4: 
#						var sniper = get_node("/root/Mundo/Juego/Player/Armas/Sniper")
#						var damageSniperActual = sniper.preDamage * stats.get_damage()
#						var sum = int(mejorasDesc[indiceMejora])
#						var damageSniperSiguiente = damageSniperActual + sum
#						mejorasDatos[indiceMejora] = String(damageSniperActual) + "->" + String(damageSniperSiguiente)
						
					5:
						var sniper = get_node("/root/Mundo/Juego/Player/Armas/Sniper")
						var damageSniperActual = sniper.preDamage * stats.get_damage()
						var sum = int(mejorasDesc[indiceMejora])
						var damageSniperSiguiente =  damageSniperActual + sum
						var bouncesActual = sniper.bounces
						var sumb =  1 #QUE ES ESTA VARIABLE ?? , SUMA BOUNCES SUPONGO? , PONGANLE BIEN LOS NOMBRES
						var bouncesDespues = bouncesActual + 1
						mejorasDatos[indiceMejora] = String(damageSniperActual) + "->" + String(damageSniperSiguiente) + "" + String(bouncesActual) + "->" + String(bouncesDespues)
						
		if mejorasEnPantalla.has("9"):
				var indiceMejora = mejorasEnPantalla.find("9")
				var nivelLanzallamas = conectorSignals.get_nivelLanzallamas()
				
				match nivelLanzallamas:
					0:
						mejorasDatos[indiceMejora] = ""
					1, 2, 3 , 4:
						var lanzallamas = get_node("/root/Mundo/Juego/Player/Armas/Lanzallamas")
						var damageLanzallamasActualSinMejoras = lanzallamas.preDamage
						var damageLanzallamasActual = lanzallamas.preDamage * stats.get_damage()
						var sum =  int(mejorasDesc[indiceMejora])
						var damageLanzallamasDespues =  (damageLanzallamasActualSinMejoras + sum) * stats.get_damage()
						mejorasDatos[indiceMejora] = String(damageLanzallamasActual) + "->" + String(damageLanzallamasDespues)
					
#					2:
#						var lanzallamas = get_node("/root/Mundo/Juego/Player/Armas/Lanzallamas")
#						var damageLanzallamasActual = lanzallamas.preDamage * stats.get_damage()
#						var sum =  int(mejorasDesc[indiceMejora])
#						var damageLanzallamasDespues =  damageLanzallamasActual + sum
#						mejorasDatos[indiceMejora] = String(damageLanzallamasActual) + "->" + String(damageLanzallamasDespues)
#
#					3:
#						var lanzallamas = get_node("/root/Mundo/Juego/Player/Armas/Lanzallamas")
#						var damageLanzallamasActual = lanzallamas.preDamage * stats.get_damage()
#						var sum =  int(mejorasDesc[indiceMejora])
#						var damageLanzallamasDespues =  damageLanzallamasActual + sum
#						mejorasDatos[indiceMejora] = String(damageLanzallamasActual) + "->" + String(damageLanzallamasDespues)
#
#					4:
#						var lanzallamas = get_node("/root/Mundo/Juego/Player/Armas/Lanzallamas")
#						var damageLanzallamasActual = lanzallamas.preDamage * stats.get_damage()
#						var sum =  int(mejorasDesc[indiceMejora])
#						var damageLanzallamasDespues =  damageLanzallamasActual + sum
#						mejorasDatos[indiceMejora] = String(damageLanzallamasActual) + "->" + String(damageLanzallamasDespues)
#
					5:
						var lanzallamas = get_node("/root/Mundo/Juego/Player/Armas/Lanzallamas")
						var reloadTimeLanzallamas = lanzallamas.reload_time
						mejorasDatos[indiceMejora] = String(reloadTimeLanzallamas)+ "s -> 0s"
					
						
	
func limitar_a_centesimas(valor):
	var factor = pow(10, 2)
	return floor(valor * factor) / factor

		
func setMejoras():
	mejoras = extraerMejora()
	getDatos()
	actualizarGUI()
	

func extraerMejora():
	array=StaticData.datos_mejoras.keys()
	array.erase("3")
	array.erase("4")
	array.erase("5")
	array.shuffle()
	arraytmp = array.duplicate()
	mejoras =[]
	if array:
		for _i in range(array.size()):
			if nivelesMejoras[String(arraytmp[0])]>5:
				arraytmp.remove(0)
			else:
				mejoras.append(arraytmp[0]) 
				arraytmp.remove(0)
	if mejoras.size()<3:
		var mejorasFaltantes = 3-mejoras.size()
		var mejorasExtra = 3
		for _i in range(mejorasFaltantes):
			mejoras.append(String(mejorasExtra))
			mejorasExtra+=1
		if(mejoras!=["3","4","5"]):	
			mejoras.shuffle()
	return mejoras

func getDatos():
	mejorasNombres.clear()
	mejorasDesc.clear()
	mejorasSprites.clear()
	mejorasEnPantalla.clear()
	var mejoraDesc =""
	for i in range(3):
		mejorasEnPantalla.append(mejoras[i])
		var mejoraNom = StaticData.datos_mejoras[String(mejoras[i])]["mejora_name"] 
		if(mejoras[i]=="3"or mejoras[i]=="4"or mejoras[i]=="5"):
			mejoraDesc = StaticData.datos_mejoras[String(mejoras[i])]["mejora_desc"][0] 
		else:
			mejoraDesc = StaticData.datos_mejoras[String(mejoras[i])]["mejora_desc"][nivelesMejoras[String(mejoras[i])]] 
		var mejoraSprite =StaticData.datos_mejoras[String(mejoras[i])]["mejora_sprite"] 

		mejorasNombres.append(mejoraNom)
		mejorasDesc.append(mejoraDesc)
		mejorasSprites.append(mejoraSprite)

func _on_EstadisticasPersonaje_lvl_up():
	get_tree().paused = true
	setMejoras()
	visible = true
	boton1.grab_focus()
	menulvlupactivo = true
	

func _on_opcion1_pressed():
	get_tree().paused = false
	visible = false
	var opc = mejoras[0]
	if nivelesMejoras.has(opc):
		nivelesMejoras[opc]+=1
	emit_signal("mejora_elegida",mejoras[0])
	menulvlupactivo = false

func _on_opcion2_pressed():
	get_tree().paused = false
	visible = false
	var opc = mejoras[1]
	if nivelesMejoras.has(opc):
		nivelesMejoras[opc]+=1
	emit_signal("mejora_elegida",mejoras[1])
	menulvlupactivo = false

func _on_opcion3_pressed():
	get_tree().paused = false
	visible = false
	var opc = mejoras[2]
	if nivelesMejoras.has(opc):
		nivelesMejoras[opc]+=1
	emit_signal("mejora_elegida",mejoras[2])
	menulvlupactivo = false




func _on_opcion1_mouse_entered():
	boton1.grab_focus()

func _on_opcion2_mouse_entered():
	boton2.grab_focus()
	
func _on_opcion3_mouse_entered():
	boton3.grab_focus()
