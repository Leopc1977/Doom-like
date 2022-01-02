extends Node

const SERVER_PORT = 28960
var MAX_CLIENTS = 6

var server = null
var client = null

var ip_adress = "127.0.0.1"

func _ready():
	get_tree().connect("connected_to_server",self,"_connected_to_server")
	get_tree().connect("server_disconnected",self,"_server_disconnected")
	get_tree().connect("connection_failed",self,"_connection_failed")
	get_tree().connect("network_peer_connected",self,"_network_peer_connected")

func create_server():
	print("[SERVER]: Creating the server")
	
	server = NetworkedMultiplayerENet.new()
	server.create_server(SERVER_PORT, MAX_CLIENTS)
	get_tree().network_peer = server
	
func join_server():
	print("[CLIENT]: Joining the server")
	
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_adress, SERVER_PORT)
	get_tree().network_peer = client

func _connected_to_server():
	print("[CLIENT]: Connected to the server")
	
func _server_disconnected():
	print("Disconnected from the server")
	
func _connection_failed():
	print("Connection failed")
	reset_network_connection()
	
func _network_peer_connected(id):
	print("Client connected "+str(id))
	
func reset_network_connection():
	if get_tree().has_network_peer():
		get_tree().network_peer=null
	print("Network reset")
