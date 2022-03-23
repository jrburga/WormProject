extends Node

export(NodePath) var TextureRectNode : NodePath

var base_url : String = ""

func _ready():
	# determine the URL from javascript
	# returns null if JavaScript is not available
	# (when we're not exported for HTML5)
	var js_eval = JavaScript.eval("location.href.replace(/[^/]*$/, '')")
	if js_eval:
		base_url = js_eval as String
		print(base_url)

# example for fetching an image
func fetch_clown_fish():
	var http_request = HTTPRequest.new()

	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_completed")

	# notice that this assumes therre's an "images" directory
	var error = http_request.request(base_url + "images/clown-fish.png")

	if error != OK:
		push_error("An error occurred in the HTTP request")

func _http_request_completed(result, response_code, headers, body):
	print(result)
	print(response_code)
	print(headers)
	print(body)
	var texture_rect = get_node(TextureRectNode)
	
	var image = Image.new()
	var error = image.load_png_from_buffer(body)
	if error != OK:
		push_error("Couldn't load the image")
		
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	
	texture_rect.texture = texture
