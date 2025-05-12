from flask import Flask, request, jsonify
from helpers import user_functions

app = Flask(__name__)

# PROFILE ROUTES
@app.route('/save_profile', methods=['POST'])
def save_profile():
    print("miau")
    data = request.json
    display_name = data.get('display_name')
    profile_picture_path = data.get('profile_picture')

    if not display_name or not profile_picture_path:
        return jsonify({'error': 'Missing required fields'}), 400
    
    user_functions.save_user_profile(display_name, profile_picture_path)
    return jsonify({'message': 'Profile saved successfully'}), 200

@app.route('/check_profile_exists', methods=['GET'])
def check_profile_exists():
    exists = user_functions.check_user_exists()
    return jsonify({'exists': exists}), 200

@app.route('/get_user_info', methods=['GET'])
def get_user_data():
    user = user_functions.get_user_info()
    if user is None: return jsonify({'message':'User not found'}), 404
    return jsonify(user), 200

if __name__ == '__main__':
    app.run(debug=True)