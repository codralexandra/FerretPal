import serial
import time
import threading
from datetime import datetime
from flask import jsonify
import os
import json
import glob

from .user_functions import (
    get_full_user_info as load_user_profile,
    save_user_profile,
    get_user_dir
)

arduino = None
stop_event = threading.Event()
offset = None
clients = []

session_data = {}
current_bad_segment = None
session_file_path = None
is_session_running = False

def get_user_session_dir(username):
    path = os.path.join(get_user_dir(username), 'session_logs')
    os.makedirs(path, exist_ok=True)
    return path

def read_from_arduino(username):
    global arduino, current_bad_segment, session_data, session_file_path

    port = 'COM5'
    baud = 9600

    try:
        arduino = serial.Serial(port, baud, timeout=1)
        time.sleep(2)
        arduino.flushInput()

        calibrate_sensor()
        session_data["start_time"] = datetime.now().isoformat()
        session_data["offset"] = offset
        session_data["posture_events"] = []
        session_data["bad_posture_segments"] = []

        session_file_path = os.path.join(
            get_user_session_dir(username),
            f"session_{session_data['start_time'].replace(':', '-')}.json"
        )

        while not stop_event.is_set():
            if arduino.in_waiting:
                try:
                    value = int(arduino.readline().decode().strip())
                    print("value:",value)
                    timestamp = datetime.now().isoformat()
                    is_good = value >= offset - 5

                    session_data["posture_events"].append({
                        "timestamp": timestamp,
                        "value": value,
                        "is_good": is_good
                    })

                    if not is_good and current_bad_segment is None:
                        current_bad_segment = {"start": timestamp}
                    elif is_good and current_bad_segment:
                        current_bad_segment["end"] = timestamp
                        start_time = datetime.fromisoformat(current_bad_segment["start"])
                        end_time = datetime.fromisoformat(current_bad_segment["end"])
                        current_bad_segment["duration"] = round((end_time - start_time).total_seconds())
                        session_data["bad_posture_segments"].append(current_bad_segment)
                        current_bad_segment = None

                    broadcast_posture_status(is_good)
                except ValueError:
                    continue
            time.sleep(0.2)
    except Exception as e:
        print(f"Error: {e}")
    finally:
        if arduino and arduino.is_open:
            arduino.close()

def start_session(username):
    global is_session_running, stop_event
    if is_session_running:
        return
    is_session_running = True
    stop_event.clear()
    threading.Thread(target=read_from_arduino, args=(username,), daemon=True).start()

def stop_session(username):
    global stop_event, is_session_running, session_data, session_file_path

    if not is_session_running:
        return

    stop_event.set()
    is_session_running = False

    session_data["end_time"] = datetime.now().isoformat()
    start_time = datetime.fromisoformat(session_data["start_time"])
    end_time = datetime.fromisoformat(session_data["end_time"])
    session_data["duration_seconds"] = (end_time - start_time).seconds
    session_data["total_breaks"] = len(session_data["bad_posture_segments"])

    good_time = 0
    for i in range(len(session_data["posture_events"]) - 1):
        if session_data["posture_events"][i]["is_good"]:
            t1 = datetime.fromisoformat(session_data["posture_events"][i]["timestamp"])
            t2 = datetime.fromisoformat(session_data["posture_events"][i + 1]["timestamp"])
            diff = (t2 - t1).total_seconds()
            if diff < 5:
                good_time += diff
    session_data["total_good_posture_time"] = round(good_time)

    with open(session_file_path, "w") as f:
        json.dump(session_data, f, indent=2)

    profile = load_user_profile(username)
    if profile is None:
        return

    profile["total_sessions_completed"] += 1
    profile["total_focus_time"] += session_data["duration_seconds"]
    profile["total_good_posture_time"] += session_data["total_good_posture_time"]

    if profile.get("least_breaks") is None or session_data["total_breaks"] < profile["least_breaks"]:
        profile["least_breaks"] = session_data["total_breaks"]

    today = datetime.now().date()
    last_date = profile.get("last_session_date")
    if last_date:
        days = (today - datetime.fromisoformat(last_date).date()).days
        if days == 1:
            profile["good_posture_streak"] += 1
            profile["consecutive_days_used"] += 1
        elif days > 1:
            profile["good_posture_streak"] = 1
            profile["consecutive_days_used"] = 1
    else:
        profile["first_session_date"] = today.isoformat()
        profile["good_posture_streak"] = 1
        profile["consecutive_days_used"] = 1

    profile["last_session_date"] = today.isoformat()
    save_user_profile(username, profile["display_name"], profile["profile_picture"])
    save_path = os.path.join(get_user_dir(username), "data.json")
    with open(save_path, 'r+') as f:
        data = json.load(f)
        data["user"].update(profile)
        f.seek(0)
        json.dump(data, f, indent=4)
        f.truncate()

def calibrate_sensor():
    global offset
    readings = []
    start = time.time()
    while time.time() - start < 6:
        try:
            value = int(arduino.readline().decode().strip())
            readings.append(value)
        except:
            continue
        time.sleep(0.1)
    if readings:
        offset = sum(readings) / len(readings)

def broadcast_posture_status(is_good):
    for client in clients:
        try:
            client.put(is_good)
        except:
            pass

def get_last_session_data(username):
    log_dir = get_user_session_dir(username)
    session_files = sorted(glob.glob(os.path.join(log_dir, "session_*.json")), reverse=True)
    if not session_files:
        return jsonify({"error": "No sessions found"}), 404
    with open(session_files[0], "r") as f:
        session = json.load(f)
    return jsonify(session), 200

def get_second_to_last_session(username):
    log_dir = get_user_session_dir(username)
    session_files = sorted(glob.glob(os.path.join(log_dir, "session_*.json")), reverse=True)
    if not session_files:
        return jsonify({"error": "No sessions found"}), 404
    with open(session_files[1], "r") as f:
        session = json.load(f)
    return jsonify(session), 200

def get_all_sessions(username):
    log_dir = get_user_session_dir(username)
    session_files = sorted(glob.glob(os.path.join(log_dir, "session_*.json")))
    if not session_files:
        return jsonify({"sessions": []}), 200

    session_data = []
    for file in session_files:
        with open(file, "r") as f:
            data = json.load(f)
            if "start_time" in data:
                session_data.append(data["start_time"])

    return jsonify({"sessions": session_data}), 200

def clear_sessions(username):
    log_dir = get_user_session_dir(username)
    session_files = glob.glob(os.path.join(log_dir, "session_*.json"))

    deleted_files = 0
    for file_path in session_files:
        try:
            os.remove(file_path)
            deleted_files += 1
        except Exception as e:
            print(f"Failed to delete {file_path}: {e}")

    return jsonify({
        "status": "success",
        "message": f"{deleted_files} session(s) deleted."
    }), 200

def compare_last_two_sessions(username):
    log_dir = get_user_session_dir(username)
    session_files = sorted(glob.glob(os.path.join(log_dir, "session_*.json")), reverse=True)

    if len(session_files) < 2:
        return json.dumps({"summary": "Not enough data to compare sessions."})

    with open(session_files[0], "r") as f1, open(session_files[1], "r") as f2:
        current = json.load(f1)
        previous = json.load(f2)

    curr_breaks = current.get("total_breaks", 0)
    prev_breaks = previous.get("total_breaks", 0)

    curr_good_time = current.get("total_good_posture_time", 0)
    prev_good_time = previous.get("total_good_posture_time", 0)

    curr_duration = current.get("duration_seconds", 0)
    prev_duration = previous.get("duration_seconds", 0)

    def safe_div(a, b):
        return a / b if b != 0 else float('inf') if a > 0 else 0.0

    breaks_change_pct = safe_div(curr_breaks - prev_breaks, prev_breaks or 1) * 100
    posture_change_pct = safe_div(curr_good_time - prev_good_time, prev_good_time or 1) * 100
    duration_change_pct = safe_div(curr_duration - prev_duration, prev_duration or 1) * 100

    normalized_breaks = -breaks_change_pct
    normalized_posture = posture_change_pct
    normalized_duration = duration_change_pct

    breaks_contrib = normalized_breaks * 0.3
    posture_contrib = normalized_posture * 0.5
    duration_contrib = normalized_duration * 0.2

    total_score = breaks_contrib + posture_contrib + duration_contrib

    summary = "This session was "
    if total_score > 5:
        summary += f"{round(total_score)}% better than the last one."
    elif total_score < -5:
        summary += f"{round(abs(total_score))}% worse than the last one."
    else:
        summary += "about the same as the last one."

    detailed_report = {
        "previous_session": {
            "breaks": prev_breaks,
            "good_posture_seconds": prev_good_time,
            "duration_seconds": prev_duration
        },
        "current_session": {
            "breaks": curr_breaks,
            "good_posture_seconds": curr_good_time,
            "duration_seconds": curr_duration
        },
        "changes": {
            "breaks_change_percent": round(breaks_change_pct, 2),
            "posture_change_percent": round(posture_change_pct, 2),
            "duration_change_percent": round(duration_change_pct, 2)
        },
        "normalized_metrics": {
            "breaks_normalized": round(normalized_breaks, 2),
            "posture_normalized": round(normalized_posture, 2),
            "duration_normalized": round(normalized_duration, 2)
        },
        "weighted_score_components": {
            "breaks_contribution": round(breaks_contrib, 2),
            "posture_contribution": round(posture_contrib, 2),
            "duration_contribution": round(duration_contrib, 2)
        },
        "total_score": round(total_score, 2),
        "summary": summary
    }

    return json.dumps(detailed_report)