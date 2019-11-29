#!/bin/bash
# Generates a test CA for implementation test
set -e
set -u

mkdir certs 2>/dev/null || true

# Generate RSA private key for CA
# The key size is 2048; the exponent is 65537
openssl genpkey -algorithm rsa -pkeyopt rsa_keygen_bits:2048 -pkeyopt rsa_keygen_pubexp:65537 -out certs/ca.key

# Generate self-signed RSA CA
openssl req -x509 -new -days 365 -key certs/ca.key -subj "/CN=CA" -sha256 -out certs/ca.crt

# Generate RSA private key for EE
openssl genpkey -algorithm rsa -pkeyopt rsa_keygen_bits:2048 -pkeyopt rsa_keygen_pubexp:65537 -out certs/test.key

# Generate certificate signing request for RSA EE
openssl req -new -key certs/test.key -subj "/CN=test" -sha256 -out certs/test.csr

# Generate RSA EE based on the above CSR, and sign it with the above RSA CA
openssl x509 -req -CAcreateserial -days 365 -in certs/test.csr -sha256 -CA certs/ca.crt -CAkey certs/ca.key -out certs/test.crt

cat certs/test.crt certs/ca.crt > certs/ca.test.bundle.pem
cp certs/ca.crt ../certs/
exit 0
