import argparse
import json
import random
from datetime import datetime, timedelta
from pathlib import Path


def generate_session_data(start_time: datetime, session_duration_seconds: int):
    posture_events = []
    bad_segments = []
    duration = timedelta(seconds=session_duration_seconds)
    end_time = start_time + duration

    current_time = start_time
    good_time = 0
    bad_breaks = 0

    while current_time < end_time:
        is_good = random.random() > 0.3
        value = random.randint(200, 300) if is_good else random.randint(180, 240)
        posture_events.append({
            "timestamp": current_time.isoformat(),
            "value": value,
            "is_good": is_good
        })

        if not is_good:
            segment_duration = timedelta(seconds=random.randint(1, 3))
            bad_segments.append({
                "start": current_time.isoformat(),
                "end": (current_time + segment_duration).isoformat(),
                "duration": int(segment_duration.total_seconds())
            })
            current_time += segment_duration
            bad_breaks += 1
        else:
            good_time += 1
            current_time += timedelta(seconds=1)

    offset = round((start_time - start_time.replace(hour=0, minute=0, second=0)).total_seconds(), 2)

    return {
        "start_time": start_time.isoformat(),
        "offset": offset,
        "posture_events": posture_events,
        "bad_posture_segments": bad_segments,
        "end_time": end_time.isoformat(),
        "duration_seconds": int(duration.total_seconds()),
        "total_breaks": bad_breaks,
        "total_good_posture_time": good_time
    }


def main():
    parser = argparse.ArgumentParser(description="Generate mock posture sessions.")
    parser.add_argument('--day', type=int, required=True, help="Ziua din luna curentă")
    parser.add_argument('--count', type=int, default=1, help="Numărul de sesiuni generate")
    parser.add_argument('--start-hour', type=int, default=9, help="Ora de start pentru prima sesiune")
    parser.add_argument('--duration', type=int, default=60, help="Durata fiecărei sesiuni (secunde)")
    parser.add_argument('--output', type=str, default="data/ako/session_logs", help="Folder de output")

    args = parser.parse_args()

    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)

    today = datetime.today()
    base_date = datetime(today.year, today.month, args.day, args.start_hour, 0, 0)

    for i in range(args.count):
        # fiecare sesiune e despărțită de minim 30 de minute
        session_start = base_date + timedelta(minutes=i * 30, seconds=random.randint(0, 300))
        session_start += timedelta(microseconds=random.randint(0, 999999))

        session_data = generate_session_data(session_start, args.duration)

        iso_time = session_start.isoformat().replace(":", "-")
        filename = output_dir / f"session_{iso_time}.json"

        with open(filename, "w") as f:
            json.dump(session_data, f, indent=2)

        print(f"✅ Sesiune generată: {filename.name}")


if __name__ == "__main__":
    main()
