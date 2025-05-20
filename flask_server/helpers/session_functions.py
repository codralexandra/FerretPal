import serial
import time
import threading

arduino = None
stop_event = threading.Event()
offset = None
clients = []

# Open the connection on COM5 and read & print each line from the serial terminal
def read_from_arduino():
    global arduino
    port = 'COM5'
    baud = 9600

    try: 
        arduino = serial.Serial(port, baud, timeout=1)
        time.sleep(2)
        arduino.flushInput()
        print("Connection established! Reading sensor values...")

        calibrate_sensor()

        while not stop_event.is_set():
            print("Waiting for data...")
            if arduino.in_waiting:
                try:
                    value = int(arduino.readline().decode().strip())
                    print(f"Flex value: {value}")
                    if offset is not None:
                        is_good = value >= offset - 10
                        print(f"Posture check: value={value}, threshold={offset - 10}, is_good={is_good}")
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
    print("Started session...")
    stop_event.clear()
    t = threading.Thread(target=read_from_arduino, daemon=True)
    t.start()

def stop_session():
    # Close the arduino connection
    global stop_event
    print("Stopping session...")
    stop_event.set()
    print("Stop signal sent, waiting for reading thread to close the port...")

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