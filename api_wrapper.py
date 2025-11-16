"""
API Wrapper for ComfyUI TTS Integration with n8n
This server receives requests from n8n (running in Docker) and forwards them to ComfyUI
"""
import json
import requests
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# ComfyUI server configuration
COMFYUI_HOST = "127.0.0.1"
COMFYUI_PORT = 8000  # Your ComfyUI is running on port 8000
COMFYUI_URL = f"http://{COMFYUI_HOST}:{COMFYUI_PORT}"

# Wrapper server configuration
WRAPPER_PORT = 8001  # Wrapper runs on different port to avoid conflict

# Default parameters for IndexTTS Engine node
DEFAULT_ENGINE_PARAMS = {
    "model_path": "IndexTTS-2",
    "device": "auto",
    "emotion_alpha": 0.7,
    "use_random": False,
    "max_text_tokens_per_segment": 120,
    "interval_silence": 200,
    "temperature": 0.8,
    "top_p": 0.8,
    "top_k": 30,
    "do_sample": True,
    "length_penalty": 0,
    "num_beams": 3,
    "repetition_penalty": 9.5,
    "max_mel_tokens": 1500,
    "use_fp16": True,
    "use_deepspeed": True,
    "use_cuda_kernel": "auto",
    "use_torch_compile": False,
    "use_accel": False,
    "stream_return": False,
    "more_segment_before": 0
}


def fix_prompt_parameters(prompt_json):
    """
    Fix common issues in prompt parameters to match ComfyUI requirements
    """
    # Fix node 51 - CharacterVoicesNode
    if "51" in prompt_json:
        node_51 = prompt_json["51"]
        if "inputs" in node_51:
            voice_name = node_51["inputs"].get("voice_name", "")
            # Add voices_examples/ prefix if missing
            if voice_name and not voice_name.startswith("voices_examples/") and voice_name != "none":
                node_51["inputs"]["voice_name"] = f"voices_examples/{voice_name}"

    # Fix node 123 - IndexTTSEngineNode
    if "123" in prompt_json:
        node_123 = prompt_json["123"]
        if "inputs" in node_123:
            # Add missing required parameters with defaults
            for key, value in DEFAULT_ENGINE_PARAMS.items():
                if key not in node_123["inputs"]:
                    node_123["inputs"][key] = value

    # Fix node 47 - UnifiedTTSTextNode
    if "47" in prompt_json:
        node_47 = prompt_json["47"]
        if "inputs" in node_47:
            # Add narrator_voice if missing
            if "narrator_voice" not in node_47["inputs"]:
                node_47["inputs"]["narrator_voice"] = "none"

    return prompt_json


@app.route('/prompt', methods=['POST'])
def process_prompt():
    """
    Receives prompt request from n8n and forwards to ComfyUI
    Handles JSON string conversion and format validation
    """
    try:
        data = request.get_json(force=True)

        # Extract prompt and client_id
        prompt_data = data.get('prompt')
        client_id = data.get('client_id', 'n8n_client')

        # If prompt is a string, parse it to JSON
        if isinstance(prompt_data, str):
            try:
                prompt_json = json.loads(prompt_data)
            except json.JSONDecodeError as e:
                return jsonify({
                    'error': 'Invalid JSON in prompt field',
                    'details': str(e)
                }), 400
        else:
            prompt_json = prompt_data

        # Fix missing parameters and path issues
        prompt_json = fix_prompt_parameters(prompt_json)

        # Prepare the request for ComfyUI
        comfyui_payload = {
            'prompt': prompt_json,
            'client_id': client_id
        }

        # Forward to ComfyUI
        response = requests.post(
            f"{COMFYUI_URL}/prompt",
            json=comfyui_payload,
            headers={'Content-Type': 'application/json'}
        )

        # Return ComfyUI's response
        if response.status_code == 200:
            return jsonify(response.json()), 200
        else:
            return jsonify({
                'error': 'ComfyUI returned an error',
                'status_code': response.status_code,
                'response': response.text
            }), response.status_code

    except requests.exceptions.ConnectionError:
        return jsonify({
            'error': 'Cannot connect to ComfyUI',
            'details': f'Make sure ComfyUI is running on {COMFYUI_URL}'
        }), 503
    except Exception as e:
        return jsonify({
            'error': 'Internal server error',
            'details': str(e)
        }), 500


@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    try:
        # Check if ComfyUI is reachable
        response = requests.get(f"{COMFYUI_URL}/system_stats", timeout=2)
        comfyui_status = "online" if response.status_code == 200 else "offline"
    except:
        comfyui_status = "offline"

    return jsonify({
        'status': 'running',
        'comfyui': comfyui_status,
        'comfyui_url': COMFYUI_URL
    })


@app.route('/history/<prompt_id>', methods=['GET'])
def get_history(prompt_id):
    """Forward history requests to ComfyUI"""
    try:
        response = requests.get(f"{COMFYUI_URL}/history/{prompt_id}")
        return jsonify(response.json()), response.status_code
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/view', methods=['GET'])
def view_file():
    """
    Proxy endpoint to serve files from ComfyUI output directory
    Usage: /view?filename=file.wav&subfolder=&type=output
    """
    try:
        # Get query parameters
        filename = request.args.get('filename')
        subfolder = request.args.get('subfolder', '')
        file_type = request.args.get('type', 'output')

        if not filename:
            return jsonify({'error': 'filename parameter is required'}), 400

        # Forward to ComfyUI's view endpoint
        params = {
            'filename': filename,
            'type': file_type
        }
        if subfolder:
            params['subfolder'] = subfolder

        response = requests.get(
            f"{COMFYUI_URL}/view",
            params=params,
            stream=True
        )

        if response.status_code == 200:
            # Return the file with appropriate headers
            return response.content, 200, {
                'Content-Type': response.headers.get('Content-Type', 'application/octet-stream'),
                'Content-Disposition': f'attachment; filename="{filename}"'
            }
        else:
            return jsonify({
                'error': 'File not found',
                'status_code': response.status_code
            }), response.status_code

    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    print(f"🚀 Starting API Wrapper Server")
    print(f"📡 Listening on: http://0.0.0.0:{WRAPPER_PORT}")
    print(f"🎨 ComfyUI target: {COMFYUI_URL}")
    print(f"🐳 Docker can access via: http://host.docker.internal:{WRAPPER_PORT}")
    print()
    print(f"⚙️  Update your n8n URL to: http://host.docker.internal:{WRAPPER_PORT}/prompt")
    print()

    # Run on wrapper port and listen on all interfaces (so Docker can access it)
    app.run(host='0.0.0.0', port=WRAPPER_PORT, debug=True)
