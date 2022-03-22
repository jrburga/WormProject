extends Node

export(NodePath) var TextureRectNode : NodePath

var local_url = "http://localhost:8000/"

func _ready():
	var http_request = HTTPRequest.new()
	
	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_completed")
	
	var error = http_request.request(local_url + "image/clown-fish.png")
	
	if error != OK:
		push_error("An error occurred in the HTTP request")

func _http_request_completed(result, response_code, headers, body):
	var texture_rect = get_node(TextureRectNode)
	
	var image = Image.new()
	var error = image.load_png_from_buffer(body)
	if error != OK:
		push_error("Couldn't load the image")
		
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	
	texture_rect.texture = texture
