extends Control

func _ready():
	Global.connect("show_network_setup",self,"_show_network_setup")

func _on_IPAdress_text_changed(new_text):
	Network.ip_adress = new_text

func _on_Host_pressed():
	Network.create_server()
	var id = get_tree().get_network_unique_id()
	print("[SERVER]: ID = "+str(id))
	Global.emit_signal("instance_player",id)
	
	if get_tree().network_peer!=null:
		Global.emit_signal("show_network_setup",false)
		
func _on_Join_pressed():
	Network.join_server()
	var id = get_tree().get_network_unique_id()
	print("[CLIENT]: ID = "+str(id))
	Global.emit_signal("instance_player",id)

	if get_tree().network_peer!=null:
		Global.emit_signal("show_network_setup",false)

func _show_network_setup(isConnected):
	visible = isConnected
