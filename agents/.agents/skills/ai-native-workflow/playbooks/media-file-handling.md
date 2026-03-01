# Playbook: Media & File Handling

**Goal:** Test application endpoints that accept file uploads (images, documents) using *real, valid binary files*. Do not pass string URLs or corrupted mock bytes, as strict parsers (Sharp, Pillow, FFmpeg) will fail.

---

## 1. Sourcing Valid Image/Video Fixtures

Use the `pexels-media` skill to download royalty-free, high-quality, valid binary assets.

### Action: Downloading a Fixture

1. Load the `pexels-media` skill.
2. Request a specific asset for testing:
   *"Use pexels-media to search for a portrait photo and download the medium resolution version to `tests/fixtures/avatar.jpg`."*
3. The skill handles the download and automatically generates a `.meta.json` sidecar file for attribution.

---

## 2. Generating Document Fixtures

For non-visual files (PDF, CSV, TXT), use universal bash/node tools to generate valid files on the fly. Always ensure the output directory exists first.

### Action: Generating File Sizes

**Generate a 1MB raw binary file:**
```bash
set -euo pipefail
mkdir -p tests/fixtures
head -c 1048576 </dev/urandom > tests/fixtures/large_file.bin
```

**Generate a simple 100-row CSV file via standard bash tools:**
```bash
set -euo pipefail
mkdir -p tests/fixtures
echo "id,name,value" > tests/fixtures/data.csv
for i in {0..99}; do echo "$i,Test$i,$RANDOM" >> tests/fixtures/data.csv; done
```

---

## 3. Testing Upload Endpoints

Once you have a valid fixture, use `curl` to submit the `multipart/form-data`.

### Action: Form-Data Upload
```bash
curl -sSf -X POST http://localhost:8000/api/users/1/avatar \
  -F "avatar=@tests/fixtures/avatar.jpg" \
  -H "Authorization: Bearer <token>"
```

---

## 4. Mocking Cloud Storage (MinIO S3)

If your application uploads files to AWS S3, verify the actual upload bypasses the app layer. 

### Action: Simulating S3 Locally

1. Add MinIO to your `docker-compose.yml` (Following YAGNI, only if the current task requires S3 testing):
   ```yaml
   services:
     minio:
       image: minio/minio
       command: server /data --console-address ":9001"
       environment:
         - MINIO_ROOT_USER=local_admin
         - MINIO_ROOT_PASSWORD=local_password
       ports:
         - "9000:9000"
         - "9001:9001"
   ```

2. Wait for MinIO to boot, create the target bucket, and execute the verification:
   ```bash
   set -euo pipefail
   
   # Wait for MinIO to be ready
   curl --retry 10 --retry-all-errors --retry-delay 1 --retry-max-time 30 -sSf http://localhost:9000/minio/health/live

   # Set AWS credentials for the Dockerized CLI
   export AWS_ENV="-e AWS_ACCESS_KEY_ID=local_admin -e AWS_SECRET_ACCESS_KEY=local_password -e AWS_REGION=us-east-1"
   export AWS_CMD="docker run --rm --network host $AWS_ENV amazon/aws-cli"

   # Create the test bucket (do this before testing your app!)
   $AWS_CMD --endpoint-url http://localhost:9000 s3 mb s3://my-app-bucket
   
   # ... RUN YOUR APP UPLOAD TEST HERE ...
   
   # Verify the upload succeeded directly in S3
   $AWS_CMD --endpoint-url http://localhost:9000 s3 ls s3://my-app-bucket/avatars/
   ```
