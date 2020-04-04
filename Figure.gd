extends Area2D
var selected = false
var pos = Vector2(0,0)
var frame = 1
var Figure_name = "Figure"

# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _ready():
	pass
	
func _process(delta):
	$AnimatedSprite.frame = frame
