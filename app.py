from flask import Flask
app = Flask(__name__)

healthy = True

@app.route("/")
def home():
    return "App is running 🚀"

@app.route("/health")
def health():
    if healthy:
        return "OK", 200
    else:
        return "NOT OK", 500

@app.route("/break")
def break_app():
    global healthy
    healthy = False
    return "App is now unhealthy 💥"

@app.route("/fix")
def fix_app():
    global healthy
    healthy = True
    return "App fixed ✅"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)