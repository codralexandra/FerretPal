import json
import os

def save_user_profile(display_name, profile_picture_path, json_file='data.json'):
    """
    Saves a user's display name and profile picture path in a JSON file under the 'user' key.
    """
    if not os.path.exists(json_file):
        with open(json_file, 'w') as file:
            json.dump({}, file)

    # Safely handle empty file
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

    print("User profile saved successfully.")

def check_user_exists(json_file='data.json'):
    """
    Checks if a user profile exists in the JSON file.
    Returns:
        bool: True if both display_name and profile_picture exist under "user", else False.
    """

    if not os.path.exists(json_file):
        return False
    
    try:
        with open(json_file, 'r') as f:
            data = json.load(f)
            user = data.get('user', {})
            return 'display_name' in user and 'profile_picture' in user
    except Exception as e:
        print(f"Error checking profile existence: {e}")
        return False
    
def get_user_info(json_file='data.json'):
    """
    Retrieves the display information for a user:
    Returns:
        JSON with user information, else None.
    """
    if not os.path.exists(json_file):
        return False
    
    try:
        with open(json_file, 'r') as f:
            data = json.load(f)
            user = data.get('user')
            if user and 'display_name' in user and 'profile_picture' in user:
                return {
                    'display_name': user['display_name'],
                    'profile_picture': user['profile_picture']
                }
    except Exception as e:
        print(f"Error reading user info: {e}")
    
    return None

def get_full_user_info(json_file='data.json'):
    """
    Retrieves the full information for a user:
    Returns:
        JSON with user information, else None.
    """
    
    if not os.path.exists(json_file):
        return None

    try:
        with open(json_file, 'r') as f:
            data = json.load(f)
            user = data.get('user')
            return user if user else None
    except Exception as e:
        print(f"Error reading full user data: {e}")
        return None

def get_badges_info(json_file='data.json'):
    """
    Retrieves the badge preference for a user:
    Returns:
        JSON with badge information, else None.
    """

    if not os.path.exists(json_file):
        return False
    
    try:
        with open(json_file, 'r') as f:
            data = json.load(f)
            user = data.get('user')
            return {
                'badges': user.get('badges', [])
            }
    except Exception as e:
        print(f"Error reading user info: {e}")
    
    return None

def save_badges_info(badges, json_file='data.json'):
    """
    SAves the badge preferences for a user:
    Returns:
        Boolean depending on operation success.
    """
    
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
    except Exception as e:
        print(f"Error saving badges info: {e}")
        return False