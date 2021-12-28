extends Spatial

var player = preload("res://player/player.tscn")

func _ready():
	get_tree().connect("network_peer_connected",self,"_network_peer_connected")
	get_tree().connect("network_peer_disconnected",self,"_network_peer_disconnected")

	Global.connect("instance_player",self,"_instance_player")

func _instance_player(id):
	var player_instance = player.instance()
	get_node("/root/World/Players").add_child(player_instance)
	player_instance.set_network_master(id)
	player_instance.name = str(id)
	
	player_instance.global_transform.origin = Vector3(0,15,0)
	
	print("New Instance Player: "+str(player_instance.get_network_master()))

func _network_peer_connected(id):
	_instance_player(id)
	print("Client: "+str(id)+" has connected")

func _network_peer_disconnected(id):
	if has_node(str(id)):
		get_node(str(id)).queue_free()
	print("Client: "+str(id)+" has disconnected")
