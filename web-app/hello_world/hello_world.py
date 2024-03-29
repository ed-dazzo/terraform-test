from flask import Flask
import dynamodb
app = Flask(__name__)

@app.route("/")
def hello():
    message = dynamodb.query()
    return f"<h1 style='color:blue'>{message}</h1>"

if __name__ == "__main__":
    app.run(host='0.0.0.0')
