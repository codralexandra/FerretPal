import serial
import time
import threading

arduino = None
stop_event = threading.Event()

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
        while not stop_event.is_set():
            print("Waiting for data...")
            if arduino.in_waiting:
                line_bytes = arduino.readline()
                print(f"Raw bytes: {line_bytes}")
                line = line_bytes.decode('utf-8').strip()
                print(f"Flex value: {line}")
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

def save_sensor_values():
    print("Saving sensor readings...")

def save_session():
    print("Saving session...")