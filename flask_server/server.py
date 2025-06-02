from flask import Flask, request, jsonify, Response
from helpers import user_functions, session_functions
import json
import queue
app = Flask(__name__)

# PROFILE ROUTES
@app.route('/user/save_profile', methods=['POST'])
def save_profile():
    print("miau")
    data = request.json
    display_name = data.get('display_name')
    profile_picture_path = data.get('profile_picture')

    if not display_name or not profile_picture_path:
        return jsonify({'error': 'Missing required fields'}), 400
    
    user_functions.save_user_profile(display_name, profile_picture_path)
    return jsonify({'message': 'Profile saved successfully'}), 200

@app.route('/user/check_profile_exists', methods=['GET'])
def check_profile_exists():
    exists = user_functions.check_user_exists()
    return jsonify({'exists': exists}), 200

@app.route('/user/get_user_info', methods=['GET'])
def get_user_data():
    user = user_functions.get_user_info()
    if user is None: return jsonify({'message':'User not found'}), 404
    return jsonify(user), 200

@app.route('/user/get_profile', methods=['GET'])
def get_profile():
    user = user_functions.get_full_user_info()
    if user is None:
        return jsonify({'message': 'User not found'}), 404
    return jsonify(user), 200

@app.route('/user/get_badge_preferences', methods=['GET'])
def get_badge_preferences():
    badges_info = user_functions.get_badges_info()
    if badges_info is None:
        return jsonify({'message': 'User or badges not found'}), 404
    return jsonify(badges_info), 200


@app.route('/user/save_badge_preferences', methods=['POST'])
def save_badge_preferences():
    data = request.json
    badges = data.get('badges')
    if badges is None or not isinstance(badges, list):
        return jsonify({'error': 'Invalid or missing badges data'}), 400

    success = user_functions.save_badges_info(badges)
    if not success:
        return jsonify({'error': 'Failed to save badges'}), 500

    return jsonify({'message': 'Badge preferences saved successfully'}), 200

# SESSION ROUTES
@app.route('/session/start_session', methods=['POST'])
def start_session():
    session_functions.start_session()
    return jsonify({"message": "Session started"}), 200

@app.route('/session/stop_session', methods=['POST'])
def stop_session():
    session_functions.stop_session()
    return jsonify({"message": "Session stopped"}), 200

@app.route('/session/posture_stream', methods=['GET'])
def posture_stream():
    def event_stream():
        q = queue.Queue()
        session_functions.clients.append(q)
        try:
            while True:
                is_good = q.get()
                print(f"Sending SSE: {is_good}")
                yield f"data: {json.dumps({'is_good': is_good})}\n\n"
        except GeneratorExit:
            session_functions.clients.remove(q)
    return Response(event_stream(), mimetype='text/event-stream')

@app.route('/session/get_last_session', methods=['GET'])
def get_last_session():
    return session_functions.get_last_session_data()

if __name__ == '__main__':
    app.run(debug=True)