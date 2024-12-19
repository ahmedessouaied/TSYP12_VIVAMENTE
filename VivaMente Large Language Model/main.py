import json

from flask import Flask, request, jsonify
from flask_socketio import SocketIO, emit
import random
from datetime import datetime
import time
import requests

app = Flask(__name__)
socketio = SocketIO(app=app, cors_allowed_origins="*", ping_timeout=10)

active_clients = {}


def generate_mock_response(message_type):
    responses = {
        'text': [
            "There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration"
            " in some form, by injected humour, or randomised words which don't look even slightly believable. If you"
            " are going to use a passage of Lorem Ipsum, you need to be sure there isn't anything embarrassing hidden"
            " in the middle of text. All the Lorem Ipsum generators on the Internet tend to repeat predefined chunks"
            " as necessary, making this the first true generator on the Internet. It uses a dictionary of over 200"
            " Latin words, combined with a handful of model sentence structures, to generate Lorem Ipsum which looks"
            " reasonable. The generated Lorem Ipsum is therefore always free from repetition, injected humour, or"
            " non-characteristic words etc."
        ],
        'image': [
            "I can see a person in this image",
            "This looks like an outdoor scene",
            "I notice several interesting objects in this image",
            "The lighting in this image suggests it's daytime",
            "This appears to be taken indoors"
        ],
        'audio': [
            "I heard you say something about...",
            "Your audio was clear. Let me respond...",
            "I understood your message. Here's my thought...",
            "Thanks for the audio message. In response...",
            "I processed your voice message. I think..."
        ]
    }
    return random.choice(responses.get(message_type, responses['text']))


def simulate_processing_delay():
    """Simulate AI model processing time"""
    time.sleep(random.uniform(0.5, 2.0))


@socketio.on('connect')
def handle_connect():
    print(f"Client connected")
    client_id = request.sid
    active_clients[client_id] = {
        'connected_at': datetime.now(),
        'last_message': None
    }


@socketio.on('disconnect')
def handle_disconnect():
    print("client disconnected")
    client_id = request.sid
    if client_id in active_clients:
        del active_clients[client_id]
    print(f"Client disconnected: {client_id}")


@socketio.on('message')
def handle_message(message):
    try:
        message = json.loads(message)

        # Handle structured messages (image/audio)
        print("Got message from client", message.get('type'))

        message_type = message.get('type')
        if message_type == 'image':
            # Process base64 image
            simulate_processing_delay()
            response = generate_mock_response('image')
            emit('response', {'type': 'text', 'content': response})

        elif message_type == 'audio':
            # Process audio data
            simulate_processing_delay()
            response = generate_mock_response('audio')
            emit('response', {'type': 'text', 'content': response})

        elif message_type == 'text':
            # Forward text message to the specified HTTP endpoint
            payload = {
                "model": "hf.co/Hamatoysin/EMBS-G",
                "prompt": message["data"],
                "stream": False
            }
            try:
                # Send POST request to the API
                api_response = requests.post("http://localhost:11434/api/generate", json=payload)
                print("got here")
                print(api_response)
                api_response.raise_for_status()  # Raise an error for bad responses
                response_data = api_response.json()  # Assuming the response is in JSON format
                print(response_data)

                socketio.emit('response', {'type': 'text', 'content': response_data})
            except requests.exceptions.RequestException as e:
                print(f"Error calling API: {e}")
                emit('response', {'type': 'text', 'content': 'Sorry, I encountered an error calling the API.'})

    except Exception as e:
        print(f"Error processing message: {e}")
        emit('response', {'type': 'text', 'content': 'Sorry, I encountered an error processing your message.'})

# Health check endpoint
@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({
        'status': 'healthy',
        'active_connections': len(active_clients),
        'timestamp': datetime.now().isoformat()
    })


if __name__ == '__main__':
    # Configuration for production deployment
    config = {
        'host': '0.0.0.0',
        'port': 5000,
        'debug': True,  # Set to False in production
        'use_reloader': False,
        'ssl_context': None  # Add SSL context in production
    }

    print(f"Starting server on {config['host']}:{config['port']}")
    socketio.run(app, **config)