#!/usr/bin/env bash
# bootstrap/create-state-bucket.sh

set -euo pipefail

USERNAME="noura"
REGION="eu-west-3"
BUCKET="${USERNAME}-tf-state-formation"

echo "Création du bucket : ${BUCKET} en ${REGION}"

# 1. Créer le bucket
aws s3api create-bucket \
  --bucket "${BUCKET}" \
  --region "${REGION}" \
  --create-bucket-configuration "LocationConstraint=${REGION}"

# 2. Versioning
aws s3api put-bucket-versioning \
  --bucket "${BUCKET}" \
  --versioning-configuration Status=Enabled

# 3. Chiffrement SSE-S3
aws s3api put-bucket-encryption \
  --bucket "${BUCKET}" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# 4. Block Public Access
aws s3api put-public-access-block \
  --bucket "${BUCKET}" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# 5. Bucket policy : refuser HTTP
aws s3api put-bucket-policy \
  --bucket "${BUCKET}" \
  --policy "$(cat <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "DenyInsecureTransport",
    "Effect": "Deny",
    "Principal": "*",
    "Action": "s3:*",
    "Resource": [
      "arn:aws:s3:::${BUCKET}",
      "arn:aws:s3:::${BUCKET}/*"
    ],
    "Condition": {
      "Bool": { "aws:SecureTransport": "false" }
    }
  }]
}
POLICY
)"

echo ""
echo "Bucket ${BUCKET} créé avec succès."
echo "Nom à utiliser dans backend.tf : ${BUCKET}"
