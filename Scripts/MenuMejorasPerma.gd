extends Control

@onready var upgradevida = $Contenedor/UpgradeVida
@onready var upgradevidalbl = $Contenedor/UpgradeVida/Label2

@onready var upgradedamage = $Contenedor/Upgradedamage
@onready var upgradedamagelbl = $Contenedor/Upgradedamage/Label2

@onready var upgradevelocidad = $Contenedor/Upgradevelocidad
@onready var upgradevelocidadlbl = $Contenedor/Upgradevelocidad/Label2

@onready var upgraderange = $Contenedor/Upgraderange
@onready var upgraderangelbl = $Contenedor/Upgraderange/Label2

@onready var btnVolver = $Contenedor/btnVolver
@onready var camera2d = $Camera2D

@onready var vidalvllabel = $Contenedor/UpgradeVida/nivel/value
@onready var dmglvllabel = $Contenedor/Upgradedamage/nivel/value
@onready var vellvllabel = $Contenedor/Upgradevelocidad/nivel/value
@onready var ranglvllabel = $Contenedor/Upgraderange/nivel/value

@onready var AudioMenuMover = get_node("/root/Mundo/SoundMenuFX/MenuMover")
@onready var AudioMenuAceptar =  get_node("/root/Mundo/SoundMenuFX/MenuAceptar")
@onready var AudioMenuAtras = get_node("/root/Mundo/SoundMenuFX/MenuAtras")




var player_id


@onready var monedaslbl = $Contenedor/Titulo/monedas/value

var monedas
var vidamaxima
var vidalvl
var damage
var dmglvl
var velocidad
var vellvl 
var rango
var ranglvl 

@onready var vidaprecio = $Contenedor/UpgradeVida/Vidamax/Precio/value
@onready var dmgprecio = $Contenedor/Upgradedamage/damage/Precio/value
@onready var velprecio = $Contenedor/Upgradevelocidad/Velocidad/Precio/value
@onready var rangprecio = $Contenedor/Upgraderange/Velocidad/Precio/value

@onready var fondoslbl = $FondosLBL
@onready var fondos = $Fondos

const sqlite = preload("res://addons/godot-sqlite/gdsqlite.gdextension")
var db
const DATABASE_PATH_RES = "res://data.db"
const DATABASE_PATH = "user://data.db"


func userDatabase():
	var dir = DirAccess.open("user://")
	if !dir.file_exists(DATABASE_PATH):
		dir.copy(DATABASE_PATH_RES,DATABASE_PATH)

		
# Called when the node enters the scene tree for the first time.
func _ready():
	userDatabase()
	db = SQLite.new()
	db.path = DATABASE_PATH
	fondoslbl.hide()
	fondos.hide()

	
func obtenerStatsDB():
	db.open_db()
	var query_player = "SELECT _id FROM players WHERE bandera = true"
	db.query(query_player)
	player_id = db.query_result[0]["_id"]
	var query = "SELECT monedas, vidamaxima, nivel_vida, daño, nivel_daño, velocidad, nivel_velocidad, rango, nivel_rango FROM player_stats WHERE player_id = ?"
	db.query_with_bindings(query, [player_id])
	if db.query_result.size()>0:
		var stats = db.query_result[0]
		monedas = stats["monedas"]
		vidamaxima = stats["vidamaxima"]
		vidalvl = stats["nivel_vida"]
		damage = stats["daño"]
		dmglvl = stats["nivel_daño"]
		velocidad = stats["velocidad"]
		vellvl = stats["nivel_velocidad"]
		rango = stats["rango"]
		ranglvl = stats["nivel_rango"]
		
# Función para mostrar el mensaje de error por 5 segundos
func mostrar_fondos_insuficientes():
	fondoslbl.show()
	fondos.show()
	await get_tree().create_timer(2).timeout
	fondoslbl.hide()
	fondos.hide()

func actualizarDatos():
	match vidalvl:
		0:
			vidaprecio.set_text("500")
			vidalvllabel.set_text("0")
			upgradevidalbl.set_text("UPGRADE")
			upgradevida.disabled = false
			upgradevida.focus_mode = Control.FOCUS_ALL
		1:
			vidaprecio.set_text("1000")
			vidalvllabel.set_text("I")
			upgradevidalbl.set_text("UPGRADE")
			vidamaxima = 120
			upgradevida.disabled = false
			upgradevida.focus_mode = Control.FOCUS_ALL
		2:
			vidaprecio.set_text("1500")
			vidalvllabel.set_text("II")
			upgradevidalbl.set_text("UPGRADE")
			vidamaxima = 140
			upgradevida.disabled = false
			upgradevida.focus_mode = Control.FOCUS_ALL
		3:
			vidaprecio.set_text("2000")
			vidalvllabel.set_text("III")
			upgradevidalbl.set_text("UPGRADE")
			vidamaxima = 160
			upgradevida.disabled = false
			upgradevida.focus_mode = Control.FOCUS_ALL
		4:
			vidaprecio.set_text("2000")
			vidalvllabel.set_text("IV")
			upgradevidalbl.set_text("UPGRADE")
			vidamaxima = 180
			upgradevida.disabled = false
			upgradevida.focus_mode = Control.FOCUS_ALL
		_:
			vidaprecio.set_text("--")
			vidalvllabel.set_text("V")
			upgradevidalbl.set_text("MAX")
			vidamaxima = 200
			upgradevida.disabled = true
			upgradevida.focus_mode = Control.FOCUS_NONE

	match dmglvl:
		0:
			dmgprecio.set_text("500")
			dmglvllabel.set_text("0")
			upgradedamage.disabled = false
			upgradedamage.focus_mode = Control.FOCUS_ALL
			upgradedamagelbl.set_text("UPGRADE")
		1:
			dmgprecio.set_text("1000")
			dmglvllabel.set_text("I")
			damage = 1.1
			upgradedamage.disabled = false
			upgradedamage.focus_mode = Control.FOCUS_ALL
			upgradedamagelbl.set_text("UPGRADE")
		2:
			dmgprecio.set_text("1500")
			dmglvllabel.set_text("II")
			damage = 1.2
			upgradedamage.disabled = false
			upgradedamage.focus_mode = Control.FOCUS_ALL
			upgradedamagelbl.set_text("UPGRADE")
		3:
			dmgprecio.set_text("2000")
			dmglvllabel.set_text("III")
			damage = 1.3
			upgradedamage.disabled = false
			upgradedamage.focus_mode = Control.FOCUS_ALL
			upgradedamagelbl.set_text("UPGRADE")
		4:
			dmgprecio.set_text("2000")
			dmglvllabel.set_text("IV")
			damage = 1.4
			upgradedamage.disabled = false
			upgradedamage.focus_mode = Control.FOCUS_ALL
			upgradedamagelbl.set_text("UPGRADE")
		_:
			dmgprecio.set_text("--")
			dmglvllabel.set_text("V")
			upgradedamagelbl.set_text("MAX")
			damage = 1.5
			upgradedamage.disabled = true
			upgradedamage.focus_mode = Control.FOCUS_NONE

	match vellvl:
		0:
			velprecio.set_text("500")
			vellvllabel.set_text("0")
			upgradevelocidad.disabled = false
			upgradevelocidad.focus_mode = Control.FOCUS_ALL
			upgradevelocidadlbl.set_text("UPGRADE")
		1:
			velprecio.set_text("1000")
			vellvllabel.set_text("I")
			upgradevelocidadlbl.set_text("UPGRADE")
			velocidad = 110
			upgradevelocidad.disabled = false
			upgradevelocidad.focus_mode = Control.FOCUS_ALL
		2:
			velprecio.set_text("1500")
			vellvllabel.set_text("II")
			velocidad = 120
			upgradevelocidad.disabled = false
			upgradevelocidad.focus_mode = Control.FOCUS_ALL
			upgradevelocidadlbl.set_text("UPGRADE")
		3:
			velprecio.set_text("2000")
			vellvllabel.set_text("III")
			velocidad = 130
			upgradevelocidad.disabled = false
			upgradevelocidad.focus_mode = Control.FOCUS_ALL
			upgradevelocidadlbl.set_text("UPGRADE")
		4:
			velprecio.set_text("2000")
			vellvllabel.set_text("IV")
			velocidad = 140
			upgradevelocidad.disabled = false
			upgradevelocidad.focus_mode = Control.FOCUS_ALL
			upgradevelocidadlbl.set_text("UPGRADE")
		_:
			velprecio.set_text("--")
			vellvllabel.set_text("V")
			upgradevelocidadlbl.set_text("MAX")
			velocidad = 150
			upgradevelocidad.disabled = true
			upgradevelocidad.focus_mode = Control.FOCUS_NONE

	match ranglvl:
		0:
			rangprecio.set_text("500")
			ranglvllabel.set_text("0")
			upgraderange.disabled = false
			upgraderange.focus_mode = Control.FOCUS_ALL
			upgraderangelbl.set_text("UPGRADE")
		1:
			rangprecio.set_text("1000")
			ranglvllabel.set_text("I")
			rango = 1.1
			upgraderange.disabled = false
			upgraderange.focus_mode = Control.FOCUS_ALL
			upgraderangelbl.set_text("UPGRADE")
		2:
			rangprecio.set_text("1500")
			ranglvllabel.set_text("II")
			rango = 1.2
			upgraderange.disabled = false
			upgraderange.focus_mode = Control.FOCUS_ALL
			upgraderangelbl.set_text("UPGRADE")
		3:
			rangprecio.set_text("2000")
			ranglvllabel.set_text("III")
			rango = 1.25
			upgraderange.disabled = false
			upgraderange.focus_mode = Control.FOCUS_ALL
			upgraderangelbl.set_text("UPGRADE")
		4:
			rangprecio.set_text("2000")
			ranglvllabel.set_text("IV")
			rango = 1.30
			upgraderange.disabled = false
			upgraderange.focus_mode = Control.FOCUS_ALL
			upgraderangelbl.set_text("UPGRADE")
		_:
			rangprecio.set_text("--")
			ranglvllabel.set_text("V")
			upgraderangelbl.set_text("MAX")
			rango = 1.40
			upgraderange.disabled = true
			upgraderange.focus_mode = Control.FOCUS_NONE
			
	monedaslbl.set_text(String(monedas))
	guardarDatos()

func get_coins():
	db.open_db()
	var query = "SELECT _id FROM players WHERE bandera = true"
	var resultado = db.query(query)
	if resultado and db.query_result.size() > 0:
		player_id = db.query_result[0]["_id"]
		var query_monedas = "SELECT monedas FROM player_stats WHERE player_id = ?"
		db.query_with_bindings(query_monedas, [player_id])
		monedas = db.query_result[0]["monedas"]
		return monedas
			

func _on_btnVolver_mouse_entered():
	btnVolver.grab_focus()

func _on_btnVolver_pressed():
	hide()
	camera2d.current = false
	var menuinicio2 = get_node("/root/Mundo/MenuInicio")
	var CamaraMenu = get_node("/root/Mundo/MenuInicio/Camera2D")
	menuinicio2.visible = true
	CamaraMenu.current = true
	menuinicio2.BotonI.grab_focus()

func _on_UpgradeVida_mouse_entered():
	upgradevida.grab_focus()

func _on_UpgradeVida_pressed():
	AudioMenuAceptar.play()
	var costo = 500 * (vidalvl + 1)
	if monedas >= costo:
		vidalvl += 1
		monedas -= costo
		actualizarDatos()

		if vidalvl == 5:
			upgradevida.disabled = true
			upgradevida.focus_mode = Control.FOCUS_NONE
	else:
		mostrar_fondos_insuficientes()



func _on_Upgradedamage_mouse_entered():
	upgradedamage.grab_focus()

func _on_Upgradedamage_pressed():
	AudioMenuAceptar.play()
	var costo = 500 * (dmglvl + 1)
	if monedas >= costo:
		dmglvl += 1
		monedas -= costo
		actualizarDatos()
		if dmglvl == 5:
			upgradedamage.disabled = true
			upgradedamage.focus_mode = Control.FOCUS_NONE
	else:
		mostrar_fondos_insuficientes()

func _on_Upgradevelocidad_mouse_entered():
	upgradevelocidad.grab_focus()

func _on_Upgradevelocidad_pressed():
	AudioMenuAceptar.play()
	var costo = 500 * (vellvl + 1)
	if monedas >= costo:
		vellvl += 1
		monedas -= costo
		actualizarDatos()
		if vellvl == 5:
			upgradevelocidad.disabled = true
			upgradevelocidad.focus_mode = Control.FOCUS_NONE
	else:
		mostrar_fondos_insuficientes()

func _on_Upgraderange_mouse_entered():
	upgraderange.grab_focus()

func _on_Upgraderange_pressed():
	AudioMenuAceptar.play()
	var costo = 500 * (ranglvl + 1)
	if monedas >= costo:
		ranglvl += 1
		monedas -= costo
		actualizarDatos()
		if ranglvl == 5:
			upgraderange.disabled = true
			upgraderange.focus_mode = Control.FOCUS_NONE
	else:
		mostrar_fondos_insuficientes()

func guardarDatos():
	db.open_db()
	var query_stats = "UPDATE player_stats SET monedas = ?, vidamaxima = ?, nivel_vida = ?, daño = ?, nivel_daño = ?, velocidad = ?, nivel_velocidad = ?, rango = ?, nivel_rango = ? WHERE player_id = ?"
	var bindings = [monedas, vidamaxima, vidalvl, damage, dmglvl, velocidad, vellvl, rango, ranglvl, player_id]
	db.query_with_bindings(query_stats, bindings)
	db.close_db()



func _on_UpgradeVida_focus_entered():
	AudioMenuMover.play()


func _on_Upgradedamage_focus_entered():
	AudioMenuMover.play()


func _on_Upgradevelocidad_focus_entered():
	AudioMenuMover.play()


func _on_Upgraderange_focus_entered():
	AudioMenuMover.play()

func _on_btnVolver_focus_entered():
	AudioMenuMover.play()
