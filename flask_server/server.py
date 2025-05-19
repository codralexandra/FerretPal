from flask import Flask, request, jsonify
from helpers import user_functions, session_functions
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

# SESSION ROUTES
#To implement!!!
@app.route('/session/start_session', methods=['POST'])
def start_session():
    session_functions.start_session()
    return jsonify({"message": "Session started"}), 200

@app.route('/session/stop_session', methods=['POST'])
def stop_session():
    session_functions.stop_session()
    return jsonify({"message": "Session stopped"}), 200

@app.route('/session/save_values', methods=['POST'])
def save_values():
    session_functions.save_sensor_values()

@app.route('/session/save_session', methods=['POST'])
def save_session():
    session_functions.save_session()

if __name__ == '__main__':
    app.run(debug=True)