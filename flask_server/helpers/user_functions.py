import json
import os

def get_user_dir(username):
    path = os.path.join('data', username)
    os.makedirs(path, exist_ok=True)
    return path

def get_profile_path(username):
    return os.path.join(get_user_dir(username), 'data.json')

def save_user_profile(username, display_name, profile_picture_path):
    json_file = get_profile_path(username)

    if not os.path.exists(json_file):
        with open(json_file, 'w') as file:
            json.dump({}, file)

    with open(json_file, 'r') as file:
        try:
            data = json.load(file)
        except json.JSONDecodeError:
            data = {}

    data['user'] = {
        'display_name': display_name,
        'profile_picture': profile_picture_path,
        'least_breaks': None,
        'total_sessions_completed': 0,
        'total_focus_time': 0,
        'total_good_posture_time': 0,
        'good_posture_streak': 0,
        'milestones': [],
        'last_achievement_unlocked': None,
        'first_session_date': None,
        'consecutive_days_used': 0,
        'badges': []
    }

    with open(json_file, 'w') as file:
        json.dump(data, file, indent=4)

def check_user_exists(username):
    json_file = get_profile_path(username)
    if not os.path.exists(json_file):
        return False
    try:
        with open(json_file, 'r') as f:
            data = json.load(f)
            user = data.get('user', {})
            return 'display_name' in user and 'profile_picture' in user
    except:
        return False

def get_user_info(username):
    json_file = get_profile_path(username)
    if not os.path.exists(json_file):
        return None
    try:
        with open(json_file, 'r') as f:
            data = json.load(f)
            user = data.get('user')
            if user:
                return {
                    'display_name': user.get('display_name'),
                    'profile_picture': user.get('profile_picture')
                }
    except:
        return None

def get_full_user_info(username):
    json_file = get_profile_path(username)
    if not os.path.exists(json_file):
        return None
    try:
        with open(json_file, 'r') as f:
            data = json.load(f)
            return data.get('user')
    except:
        return None

def get_badges_info(username):
    json_file = get_profile_path(username)
    if not os.path.exists(json_file):
        return None
    try:
        with open(json_file, 'r') as f:
            data = json.load(f)
            user = data.get('user', {})
            return {'badges': user.get('badges', [])}
    except:
        return None

def save_badges_info(username, badges):
    json_file = get_profile_path(username)
    if not os.path.exists(json_file):
        return False
    try:
        with open(json_file, 'r+') as f:
            data = json.load(f)
            if 'user' not in data:
                data['user'] = {}
            data['user']['badges'] = badges
            f.seek(0)
            json.dump(data, f, indent=4)
            f.truncate()
        return True
    except:
        return False
