import requests
import json
import time
from threading import Thread
from flask import Flask, jsonify

app = Flask(__name__)

# Configurações de autenticação e endereço da API
CLIENT_ID = 'V8YjaN9Ob9eTUAEMYzSdi6NnhogLYlyz'
CLIENT_SECRET = '2ZQH1Z7lg56d9IOntFATQieg8LTy275wa5m4VUTdrwWkD36kecBDMnOKDjNUhqwm'
THING_ID = '488d0b17-fa7a-41e1-bcdc-2424e06110b9'
TOKEN_URL = 'https://api2.arduino.cc/iot/v1/clients/token'
DATA_URL = f'https://api2.arduino.cc/iot/v2/things/{THING_ID}/properties'
HEADERS = {'Content-Type': 'application/x-www-form-urlencoded'}
ACCESS_TOKEN = None
DATA_CACHE = None

def get_access_token():
    """Obtém o token de acesso da API do Arduino usando as credenciais do cliente."""
    global ACCESS_TOKEN
    response = requests.post(
        TOKEN_URL,
        data={
            'grant_type': 'client_credentials',
            'client_id': CLIENT_ID,
            'client_secret': CLIENT_SECRET,
            'audience': 'https://api2.arduino.cc/iot'
        },
        headers=HEADERS
    )
    if response.status_code == 200:
        ACCESS_TOKEN = response.json()['access_token']
        print(f"Token obtained: {ACCESS_TOKEN}")
    else:
        print(f"Failed to get access token. Status code: {response.status_code}")
        print(f"Response: {response.text}")

def fetch_data():
    """Busca os dados atualizados do Arduino Cloud."""
    global DATA_CACHE
    if ACCESS_TOKEN:
        headers = {"Authorization": f"Bearer {ACCESS_TOKEN}"}
        response = requests.get(DATA_URL, headers=headers)
        if response.status_code == 200:
            DATA_CACHE = response.json()
        else:
            print(f"Failed to fetch data. Status code: {response.status_code}")
            print(f"Response: {response.text}")

def refresh_token():
    """Atualiza o token de acesso periodicamente."""
    while True:
        get_access_token()
        time.sleep(280)  # Refresca o token a cada 280 segundos

def update_data():
    """Atualiza os dados de forma periódica e envia para o servidor Rails."""
    while True:
        fetch_data()
        if DATA_CACHE:
            send_data_to_rails(DATA_CACHE)
        time.sleep(1)

def send_data_to_rails(data):
    """Envia dados para o servidor Rails."""
    url = 'http://localhost:3001/arduino_cloud_data/receive_data'
    headers = {
        'Content-Type': 'application/json',
        'Authorization': 'TokenSecret'  # Token de API
    }
    response = requests.post(url, data=json.dumps({'data': data}), headers=headers)
    if response.status_code == 200:
        print("Data sent successfully")
    else:
        print(f"Failed to send data: {response.status_code}, {response.text}")

@app.route('/', methods=['GET'])
def home():
    return "API Arduino Cloud está funcionando! Acesse /arduino-data para os dados."

@app.route('/arduino-data', methods=['GET'])
def get_arduino_data():
    """Endpoint que fornece os dados coletados."""
    if DATA_CACHE:
        return jsonify(DATA_CACHE)
    else:
        return jsonify({"error": "Data not available"}), 500

if __name__ == '__main__':
    # Iniciar threads para atualizar o token e buscar dados periodicamente
    token_thread = Thread(target=refresh_token)
    data_thread = Thread(target=update_data)

    token_thread.daemon = True
    data_thread.daemon = True

    token_thread.start()
    data_thread.start()

    app.run(debug=True, port=5000)
