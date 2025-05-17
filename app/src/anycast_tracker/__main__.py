import json, re, os, subprocess, uuid
from datetime import datetime, timezone
from azure.cosmos import CosmosClient

REGION = os.environ['REGION']
URL = os.environ['URL']
KEY = os.environ['KEY']
DATABASE_NAME = os.environ['DATABASE_NAME']
CONTAINER_NAME_V4 = os.environ['CONTAINER_NAME_V4']
CONTAINER_NAME_V6 = os.environ['CONTAINER_NAME_V6']

client = CosmosClient(url=URL, credential=KEY)
database = client.get_database_client(DATABASE_NAME)
container_v4 = database.get_container_client(CONTAINER_NAME_V4)
container_v6 = database.get_container_client(CONTAINER_NAME_V6)
print(client)
print(database)
print(container_v4)
print(container_v6)
print("Connected to Cosmos DB")

regex = re.compile(r"\s{2,}", re.MULTILINE)

#def start():
timestamp = datetime.now(timezone.utc).isoformat()
result_v4 = subprocess.run(["mtr", "-jzb", "-o", "LDRSNBAWVGJMXI", "-c", "1", "1.1.1.1", "8.8.8.8"], stdout=subprocess.PIPE)
print("Retrieved IPv4 data")
result_v6 = subprocess.run(["mtr", "-jzb", "-o", "LDRSNBAWVGJMXI", "-c", "1", "2606:4700:4700::1111", "2001:4860:4860::8888"], stdout=subprocess.PIPE)
print("Retrieved IPv6 data")
json_arr_v4 = json.loads('[' + re.sub(regex, ' ', result_v4.stdout.decode('utf-8')).replace('\n', '').replace('}{', '},{')+']')
print("Parsed IPv4 data")
json_arr_v6 = json.loads('[' + re.sub(regex, ' ', result_v6.stdout.decode('utf-8')).replace('\n', '').replace('}{', '},{')+']')
print("Parsed IPv6 data")
for obj in json_arr_v4:
    out = obj["report"]["mtr"]
    out["utctime"] = timestamp
    out["region"] = REGION
    out["hubs"] = obj["report"]["hubs"]
    print("enriched ipv4 data")
    print(out)
    container_v4.create_item(out, enable_automatic_id_generation=True)
    print("Inserted ipv4 data into Cosmos DB")
for obj in json_arr_v6:
    out = obj["report"]["mtr"]
    out["utctime"] = timestamp
    out["region"] = REGION
    out["hubs"] = obj["report"]["hubs"]
    print("enriched ipv6 data")
    print(out)
    container_v6.create_item(out, enable_automatic_id_generation=True)
    print("Inserted ipv6 data into Cosmos DB")

def main():
    pass