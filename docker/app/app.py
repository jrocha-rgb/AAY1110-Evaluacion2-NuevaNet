import os
import socket
from flask import Flask, jsonify
app = Flask(__name__)
@app.route('/')
def inicio():
    return jsonify({
        "sistema": "API NuevaNet",
        "estado": "Operativo",
        "entorno": os.environ.get("ENTORNO", "Desconocido"),
        "host": socket.gethostname()
    })
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
