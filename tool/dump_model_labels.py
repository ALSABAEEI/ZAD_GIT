from pathlib import Path
import re

MODEL_PATH = Path('assets/models/food_classifier.tflite')

def main() -> None:
    data = MODEL_PATH.read_bytes()
    print(f'model size: {MODEL_PATH.stat().st_size} bytes')
    seen = set()
    for match in re.finditer(rb'([A-Za-z][A-Za-z \-]{2,30})', data):
        text = match.group(1).decode('ascii', errors='ignore').strip()
        if not text or text in seen:
            continue
        if any(keyword in text for keyword in ('Burger', 'Pizza', 'Donut', 'Chicken', 'club', 'sand', 'food')):
            seen.add(text)
            print(f'{match.start():>8}: {text}')

if __name__ == '__main__':
    main()
