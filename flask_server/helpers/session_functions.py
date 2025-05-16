import serial
import time
import threading

# Open the connection on COM3 and read & print each line from the serial terminal
def read_from_arduino():
    port = 'COM5'
    baud = 9600

    try: 
        with serial.Serial(port, baud, timeout=1) as arduino:
            time.sleep(2)
            arduino.flushInput()
            print("Connection established! Reading sensor values...")
            while True:
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


def start_session():
    # Open the arduino connection on a separate thread and send the flex values to flutter
    print("Started session...")
    t = threading.Thread(target=read_from_arduino, daemon=True)
    t.start()

def stop_session():
    # Close the arduino connection
    print ("Stopped session...")

def save_sensor_values():
    print("Saving sensor readings...")

def save_session():
    print("Saving session...")