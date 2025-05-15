import subprocess
from azure.cosmos import CosmosClient
import json
import re
from datetime import datetime, timezone

#REGION = os.environ['REGION']
#URL = os.environ['ACCOUNT_URI']
#KEY = os.environ['ACCOUNT_KEY']
#DATABASE_NAME = os.environ['DATABASE_NAME']
#CONTAINER_NAME = os.environ['CONTAINER_NAME']
#
#client = CosmosClient(URL, credential=KEY)
#database = client.get_database_client(DATABASE_NAME)
#container = database.get_container_client(CONTAINER_NAME)

regex = re.compile(r"\s{2,}", re.MULTILINE)

def main():
    timestamp = datetime.now(timezone.utc).isoformat()
    #result = subprocess.run(["mtr", "-jzb", "-o", "LDRSNBAWVGJMXI", "-c", "20", "1.1.1.1", "8.8.8.8", "34.36.217.158", "104.129.164.157", "52.223.34.110", "167.82.47.247", "23.11.39.92"], stdout=subprocess.PIPE)
    result = subprocess.run(["mtr", "-jzb", "-o", "LDRSNBAWVGJMXI", "-c", "1", "1.1.1.1", "8.8.8.8"], stdout=subprocess.PIPE)
    json_arr = json.loads('[' + re.sub(regex, ' ', result.stdout.decode('utf-8')).replace('\n', '').replace('}{', '},{')+']')
    for obj in json_arr:
        obj["report"]["mtr"]["timestamp"] = timestamp
        obj["report"]["mtr"]["region"] = "us-east-1"
    print(json.dumps(json_arr, indent=4))