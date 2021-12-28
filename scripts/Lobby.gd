extends Spatial

func _ready():
	Global.connect("show_network_setup",self,"_show_network_setup")

func _show_network_setup(isConnected):
	visible = !isConnected
