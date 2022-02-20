tool
extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(NodePath) var viewport_path : NodePath;
export(NodePath) var texture_rect : NodePath
export(bool) var generate_texture = false setget _set_generate_texture, _get_generate_texture

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_texture
	print(viewport_path)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _set_generate_texture(value):
	if value == true:
		print('generating texture')
		var viewport = get_node(viewport_path) as Viewport
		var rect = get_node(texture_rect) as TextureRect
		if not viewport:
			return
			
		viewport.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
		
		var img = viewport.get_texture().get_data()
		
		img.flip_y()
		img.convert(Image.FORMAT_RGBA8)
		img.save_png('C:/Users/ryan6/Captures/export_img.png')
		var tex = ImageTexture.new()
		tex.create_from_image(img)
		
		rect.set_texture(tex)
func _get_generate_texture():
	return false
