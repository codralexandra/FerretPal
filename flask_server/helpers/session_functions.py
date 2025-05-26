import serial
import time
import threading
from datetime import datetime
from flask import jsonify
import os
import json
import glob

arduino = None
stop_event = threading.Event()
offset = None
clients = []

session_data = {}
current_bad_segment = None
total_breaks = None
session_file_path = None
is_session_running = None

# Open the connection on COM5 and read & print each line from the serial terminal
def read_from_arduino():
    global arduino, current_bad_segment, total_breaks, session_data, session_file_path

    port = 'COM5'
    baud = 9600

    try: 
        arduino = serial.Serial(port, baud, timeout=1)
        time.sleep(2)
        arduino.flushInput()
        print("Connection established! Reading sensor values...")

        calibrate_sensor()

        session_data["start_time"] = datetime.now().isoformat()
        session_data["offset"] = offset
        session_data["posture_events"] = []
        session_data["bad_posture_segments"] = []
        total_breaks = 0
        current_bad_segment = None

        if not os.path.exists("session_logs"):
            os.makedirs("session_logs")
        session_file_path = f"session_logs/session_{session_data['start_time'].replace(':', '-')}.json"

        while not stop_event.is_set():
            print("Waiting for data...")
            if arduino.in_waiting:
                try:
                    value = int(arduino.readline().decode().strip())
                    timestamp = datetime.now().isoformat()
                    is_good = value >= offset - 10
                    
                    # save session data
                    session_data["posture_events"].append({
                    "timestamp": timestamp,
                    "value": value,
                    "is_good": is_good
                    })
                    
                    # start saving data for a bad posture segment
                    if not is_good and current_bad_segment is None:
                        current_bad_segment = {"start": timestamp}
                    elif is_good and current_bad_segment:
                        current_bad_segment["end"] = timestamp
                        start_time = datetime.fromisoformat(current_bad_segment["start"])
                        end_time = datetime.fromisoformat(current_bad_segment["end"])
                        current_bad_segment["duration"] = round((end_time - start_time).total_seconds())
                        session_data["bad_posture_segments"].append(current_bad_segment)
                        current_bad_segment = None
                        total_breaks +=1
                    
                    broadcast_posture_status(is_good)
                except ValueError:
                    continue
            time.sleep(0.2)
    except serial.SerialException as e:
        print(f"Serial error: {e}")
    except KeyboardInterrupt:
        print("\nSession was ended by user.")
    finally:
        if arduino and arduino.is_open:
            arduino.close()
            print("Closed the serial connection cleanly.")


def start_session():
    # Open the arduino connection on a separate thread and send the flex values to flutter
    global is_session_running, stop_event
    if is_session_running:
        print("Session is already running.")
        return
    
    print("Started session...")
    is_session_running = True
    stop_event.clear()
    t = threading.Thread(target=read_from_arduino, daemon=True)
    t.start()

def stop_session():
    # Close the arduino connection
    global stop_event, is_session_running, session_data, session_file_path

    if not is_session_running:
        print("No session is currently running.")
        return

    print("Stopping session...")
    stop_event.set()
    is_session_running = False
    print("Stop signal sent, waiting for reading thread to close the port...")

    session_data["end_time"] = datetime.now().isoformat()
    start_time = datetime.fromisoformat(session_data["start_time"])
    end_time = datetime.fromisoformat(session_data["end_time"])
    session_data["duration_seconds"] = (end_time-start_time).seconds
    session_data["total_breaks"] = len(session_data["bad_posture_segments"])

    if session_file_path:
        with open(session_file_path, "w") as f:
            json.dump(session_data, f, indent=2)
        print(f"Session data saved to {session_file_path}")
    else:
        print("Warning: Session file path was not set!")

def calibrate_sensor():
    global offset
    readings = []
    start_time = time.time()
    while time.time() - start_time < 6:
        try:
            value = int(arduino.readline().decode().strip())
            readings.append(value)
        except ValueError:
            continue
        time.sleep(0.1)
    if readings:
        offset = sum(readings)/len(readings)
        print(f"Calibration complete. Offset={offset}")
    else:
        print("No sensor data for calibration")


def broadcast_posture_status(is_good):
    for client in clients:
        try:
            client.put(is_good)
        except:
            pass

def get_last_session_data():
    log_dir = "session_logs"
    if not os.path.exists(log_dir):
        return jsonify({"error":"No sessions found"}), 404
    
    session_files = sorted(glob.glob(os.path.join(log_dir, "session_*.json")), reverse=True)

    if not session_files:
        return jsonify({"error": "No sessions found"}), 404
    
    latest_file = session_files[0]
    with open(latest_file, "r") as f:
        session = json.load(f)
    
    return jsonify(session), 200