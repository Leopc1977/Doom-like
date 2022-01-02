extends StaticBody

var is_opened = false

signal open_chest

func _ready():
	connect("open_chest",self,"_open_chest")

func _open_chest():
	self.queue_free()
