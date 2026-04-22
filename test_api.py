
import requests
import json

url = "http://localhost:5001/api/v1/production/equipment"
payload = {
    "name": "TEST EQUIP",
    "nature": "MAQUINARIA",
    "serial_number": "TEST-SN-999",
    "dynamic_specs": {}
}

try:
    response = requests.post(url, json=payload)
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.text}")
except Exception as e:
    print(f"Error: {e}")
