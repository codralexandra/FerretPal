from flask import Flask, request, jsonify, Response
from helpers import user_functions, session_functions
import json
import queue

app = Flask(__name__)

@app.route('/user/<username>/save_profile', methods=['POST'])
def save_profile(username):
    data = request.json
    display_name = data.get('display_name')
    profile_picture = data.get('profile_picture')
    if not display_name or not profile_picture:
        return jsonify({'error': 'Missing fields'}), 400
    user_functions.save_user_profile(username, display_name, profile_picture)
    return jsonify({'message': 'Saved'}), 200

@app.route('/user/<username>/check_profile_exists', methods=['GET'])
def check_profile_exists(username):
    exists = user_functions.check_user_exists(username)
    return jsonify({'exists': exists}), 200

@app.route('/user/<username>/get_user_info', methods=['GET'])
def get_user_info(username):
    user = user_functions.get_user_info(username)
    if user is None:
        return jsonify({'error': 'User not found'}), 404
    return jsonify(user), 200

@app.route('/user/<username>/get_profile', methods=['GET'])
def get_profile(username):
    user = user_functions.get_full_user_info(username)
    if user is None:
        return jsonify({'error': 'User not found'}), 404
    return jsonify(user), 200

@app.route('/user/<username>/get_badge_preferences', methods=['GET'])
def get_badge_preferences(username):
    badges = user_functions.get_badges_info(username)
    if badges is None:
        return jsonify({'error': 'Not found'}), 404
    return jsonify(badges), 200

@app.route('/user/<username>/save_badge_preferences', methods=['POST'])
def save_badge_preferences(username):
    badges = request.json.get('badges')
    if not isinstance(badges, list):
        return jsonify({'error': 'Invalid badges'}), 400
    success = user_functions.save_badges_info(username, badges)
    return (jsonify({'message': 'Saved'}), 200) if success else (jsonify({'error': 'Failed'}), 500)

@app.route('/session/<username>/start_session', methods=['POST'])
def start_session(username):
    session_functions.start_session(username)
    return jsonify({"message": "Session started"}), 200

@app.route('/session/<username>/stop_session', methods=['POST'])
def stop_session(username):
    session_functions.stop_session(username)
    return jsonify({"message": "Session stopped"}), 200

@app.route('/session/posture_stream', methods=['GET'])
def posture_stream():
    def event_stream():
        q = queue.Queue()
        session_functions.clients.append(q)
        try:
            while True:
                is_good = q.get()
                yield f"data: {json.dumps({'is_good': is_good})}\n\n"
        except GeneratorExit:
            session_functions.clients.remove(q)
    return Response(event_stream(), mimetype='text/event-stream')

@app.route('/session/<username>/get_last_session', methods=['GET'])
def get_last_session(username):
    return session_functions.get_last_session_data(username)

if __name__ == '__main__':
    app.run(debug=True)
