#!/bin/bash
apt update -y
apt install -y docker.io
systemctl start docker
docker run -d \
  -e AWS_REGION=us-east-1 \
  -e BUCKET_NAME=${bucket_name} \
  python:3.9-slim bash -c "\
    pip install boto3 && \
    echo \"import boto3,time; seen=set(); \
    s3=boto3.client('s3',region_name='us-east-1'); \
    while True: \
      resp=s3.list_objects_v2(Bucket='$bucket_name'); \
      for o in resp.get('Contents',[]): \
        if o['Key'] not in seen: \
          print(f'New file: {o[\"Key\"]}'); seen.add(o['Key']); \
      time.sleep(60)\" > main.py && python main.py"
