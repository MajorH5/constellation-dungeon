extends Node2D

@onready var jc = $JamConnect
var api_key = ''
var url = 'https://api.openai.com/v1/chat/completions'
var header = [ 'Authorization: Bearer ' + api_key]
var messages = []
var request: HTTPRequest


func _ready():
	var res = await jc.server.callback_api.get_vars(["THE_API_KEY"])
	if res.errored:
		printerr(res.error_msg)
		return
	print(res.data)
	print("fetched API key value: %s" % [res.data["vars"]["THE_API_KEY"]])
	request = HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(_on_request_completed)
	
	_ask_ai("What is 2+2", true)

## Calls the GPT API, can format into JSON object if needed
## Inputs: A query to GPT, JSON boolean
## Returns: void
func _ask_ai(query ,json = false):
	## Sets up API call
	messages.append({
		'role': 'user',
		'content': query + ("in JSON" if json else "") # Actual message being sent
	})
	var body = JSON.new().stringify({
		'messages': messages, ## History of the messages
		'response_format': {
			'type': 'json_object' if json else "text"
		},
		'temperature': 0.7,
		'max_tokens': 1024,
		'model': 'gpt-4o'
	})
	
	var send_request = request.request(url, header, HTTPClient.METHOD_POST, body)
	
	if (send_request != OK):
		print("GPT PROMPT ERROR")

## Request calls are sent here
## Used as a event receiver
## Inputs: void
## Outputs: JSON object or String
func _on_request_completed(result, response_code, headers, body):
	## Parses JSON
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	print(response)
	var msg = response['choices'][0]['message']['content']
	return msg
