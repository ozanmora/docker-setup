#!/bin/bash

# generate-ssl.sh - Generate self-signed wildcard SSL certificate for development

mkdir -p certs

echo "🔐 Generating self-signed SSL certificate..."

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout certs/server.key \
    -out certs/server.crt \
    -subj "/C=TR/ST=Istanbul/L=Istanbul/O=Development/OU=Development/CN=*.test" \
    -addext "subjectAltName=DNS:*.test,DNS:localhost"

echo "✅ Certificate generated in ./certs/"
echo "   - certs/server.crt"
echo "   - certs/server.key"
echo "ℹ️  This certificate is valid for '*.test' and 'localhost'."
