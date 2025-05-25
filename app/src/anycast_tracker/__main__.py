import json, re, os, subprocess, uuid
from datetime import datetime, timezone
import boto3
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table_v4 = dynamodb.Table(os.environ['DYNAMODB_TABLE_V4'])
table_v6 = dynamodb.Table(os.environ['DYNAMODB_TABLE_V6'])
REGION = os.environ['AWS_DEFAULT_REGION']

print("connected to DynamoDB")

regex = re.compile(r"\s{2,}", re.MULTILINE)

#def start():
timestamp = datetime.now(timezone.utc).isoformat()
# Cloudflare DNS, Google DNS, Quad9 DNS, Akamai CDN, Cloudflare CDN, Heise, ntp1.net.berkeley.edu
result_v4 = subprocess.run(["mtr", "-jzb", "-o", "LDRSNBAWVGJMXI", "-i", "1", "-c", "5", "1.1.1.1", "8.8.8.8", "9.9.9.9", "2.16.241.219", "104.16.123.96", "193.99.144.85", "169.229.128.134"], stdout=subprocess.PIPE)
print("Retrieved IPv4 data")
result_v6 = subprocess.run(["mtr", "-jzb", "-o", "LDRSNBAWVGJMXI", "-i", "1", "-c", "5", "2606:4700:4700::1111", "2001:4860:4860::8888", "2620:fe::fe:9", "2a02:26f0:3500:1b::1724:a393", "2606:4700::6810:7b60", "2a02:2e0:3fe:1001:7777:772e:2:85", "2607:f140:ffff:8000:0:8006:0:a"], stdout=subprocess.PIPE)
print("Retrieved IPv6 data")
json_arr_v4 = json.loads('[' + re.sub(regex, ' ', result_v4.stdout.decode('utf-8')).replace('\n', '').replace('}{', '},{')+']', parse_float=Decimal)
print("Parsed IPv4 data")
json_arr_v6 = json.loads('[' + re.sub(regex, ' ', result_v6.stdout.decode('utf-8')).replace('\n', '').replace('}{', '},{')+']', parse_float=Decimal)
print("Parsed IPv6 data")
for obj in json_arr_v4:
    out = obj["report"]["mtr"]
    out["utctime"] = timestamp
    out["region"] = REGION
    out["hubs"] = obj["report"]["hubs"]
    print("enriched ipv4 data")
    print(out)
    table_v4.put_item(Item=out)
    print("Inserted ipv4 data into Cosmos DB")
for obj in json_arr_v6:
    out = obj["report"]["mtr"]
    out["utctime"] = timestamp
    out["region"] = REGION
    out["hubs"] = obj["report"]["hubs"]
    print("enriched ipv6 data")
    print(out)
    table_v6.put_item(Item=out)
    print("Inserted ipv6 data into Cosmos DB")

def main():
    pass