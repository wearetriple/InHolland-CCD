"""
https://stackoverflow.com/questions/43142716/how-to-verify-jwt-id-token-produced-by-ms-azure-ad

"""
import os
import random

import jwt
import requests

from cryptography.x509 import load_pem_x509_certificate
from cryptography.hazmat.backends import default_backend
from dotenv import load_dotenv
from flask import Flask, redirect, request, render_template_string

load_dotenv()

TENANT = os.getenv("TENANT")
CLIENT_ID = os.getenv("CLIENT_ID")
REDIRECT_URL = os.getenv("REDIRECT_URL")

def get_azure_public_keys():
    """
    This step should normally be cached
    """
    url = f"https://login.microsoftonline.com/{TENANT}/discovery/v2.0/keys"
    return requests.get(url).json()

def get_public_key_for_acces_token(public_key_data: dict, access_token_kid: str):
    value_x5c = [x['x5c'][0] for x in public_key_data['keys'] if x['kid'] == access_token_kid][0]
    return bytes(f"-----BEGIN CERTIFICATE-----\n{value_x5c}\n-----END CERTIFICATE-----", "utf-8")

def get_token_kid(access_token: str):
    token_header = jwt.get_unverified_header(access_token)
    return token_header['kid']

def validate_token(access_token: str):
    token_kid = get_token_kid(access_token)
    azure_keys = get_azure_public_keys()
    key = get_public_key_for_acces_token(azure_keys, token_kid)

    cert_obj = load_pem_x509_certificate(key, default_backend())
    public_key = cert_obj.public_key()

    try:
        decoded = jwt.decode(access_token, public_key, algorithms=['RS256'], audience=CLIENT_ID)
        return True, decoded
    except Exception as ex:
        return False, str(ex)

rand = random.Random()
app = Flask(__name__)

@app.route("/")
def route_index():
    return { "msg": "Welcome" }, 200

@app.route("/api")
def route_api():
    access_token = request.headers.get('Authorization')[7:]
    status, msg = validate_token(access_token)
    if status:
        return { "msg": "login succesful" }, 200
    return { "msg": msg }, 401

@app.route("/read-token")
def route_read_token():
    access_token = request.headers.get('Authorization')[7:]
    status, msg = validate_token(access_token)
    if status:
        return { "msg": msg }, 200
    return { "msg": msg }, 401

@app.route("/get-token")
def route_get_token():
    state = str(rand.randint(1000,9999))
    nonce = str(rand.randint(1000,9999))
    resource = CLIENT_ID

    return redirect(f"https://login.microsoftonline.com/{TENANT}/oauth2/v2.0/authorize?client_id={CLIENT_ID}&response_type=id_token&redirect_uri={REDIRECT_URL}&scope=openid&response_mode=fragment&nonce={nonce}&state={state}")

@app.route("/show-token")
def route_show_token():
    return render_template_string("""
<!DOCTYPE html>
<html>
<title>Auth</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">
<body>

<div class="w3-container">
    <div id="holder"></div>
</div>

<script type="text/javascript">

var data = window.location.hash.substring(1);
var holder = document.getElementById("holder");

var vars = data.split('&');
for (var i = 0; i < vars.length; i++) {
    var pair = vars[i].split('=');
    var key = decodeURIComponent(pair[0]);
    var value = decodeURIComponent(pair[1]);

    holder.innerHTML = holder.innerHTML +'<p><label class="w3-text-blue"><b>' + key + '</b></label><input class="w3-input w3-border" type="text" value="' + value + '"></p>';
}

</script>
</body>
</html> 
    """)

if __name__ == "__main__":
    app.run()