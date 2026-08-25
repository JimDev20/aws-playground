
from flask import Flask
import os

app = Flask(__name__)
COUNTER_FILE = "/data/counter.txt"

def read_count():
    try:
        with open(COUNTER_FILE) as f:
            return int(f.read().strip() or 0)
    except FileNotFoundError:
        return 0

@app.route("/")
def home():
    n = read_count()
    return f"ShopFast orders served: {n}"

@app.route("/order")
def new_order():
    os.makedirs("/data", exist_ok=True)
    n = read_count() + 1
    with open(COUNTER_FILE, "w") as f:
        f.write(str(n))
    return f"Order #{n} received!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
