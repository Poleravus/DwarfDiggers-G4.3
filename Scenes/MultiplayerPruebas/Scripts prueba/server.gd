extends Node

var client
@onready var BtnUnirse : Button = null
@onready var Lobby : Control = null

var player = preload("res://Scenes/Personajes/PlayerMultiplayer.tscn") 
var otroPlayer = preload("res://Scenes/Personajes/OtroPlayerMultiplayer.tscn")

func _ready():
	set_process(false)
	get_tree().connect("connected_to_server", Callable(self, "_connected_to_server"))
	get_tree().connect("server_disconnected", Callable(self, "_server_disconnected"))
	get_tree().connect("connection_failed", Callable(self, "connection_failed"))
	
func join_server():
#	var client = NetworkedMultiplayerENet.new()     MULTIPLAYER API , NO WEBSOCKET
#	var err = client.create_client("127.0.0.1",4242)
#	if err != OK:
#		print("No se pudo conectar")
#		return
#	get_tree().set_network_peer(client)
	client = WebSocketPeer.new()   #WEB SOCKET
	var err = client.connect_to_url("ws://67.205.177.255:4242",PackedStringArray(),true)
	print("Error: ", err)
	if err!= OK:
		print("No se pudo conectar")
		return
	set_process(true)
	get_tree().set_multiplayer_peer(client)
	
func _process(delta):
		client.poll()
	
func connection_failed():
	BtnUnirse.disabled = false
	print("Connection failed")
	
func _server_disconnected():
	Lobby.show()
	print("server diconnected")
	
func _connected_to_server():
	Lobby.hide()
	print("Connected to server")
	
@rpc("any_peer") func instance_player ( id,location):
	var p = player if get_tree().get_unique_id() == id else otroPlayer
	var player_instance = Global.instance_node ( p, Nodes, location)
	player_instance.name = str(id)
	if get_tree().get_unique_id() == id:
		for i in get_tree().get_peers():
			if i !=1:
				instance_player(i,location)

@rpc("any_peer") func update_player_transform(id, position, animation, velocity,spriteFlip):
	print("update_player_transform")
	if get_tree().get_unique_id() != id:
		Nodes.get_node(str(id)).update_transform(position, animation, velocity,spriteFlip)

@rpc("any_peer") func delete_obj(id):
	if Nodes.has_node(str(id)):
		Nodes.get_node(str(id)).queue_free()
