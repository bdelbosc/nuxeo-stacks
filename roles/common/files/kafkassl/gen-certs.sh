#!/bin/bash

set -e
# set -x
# Adapted from https://github.com/trastle/docker-kafka-ssl/blob/master/generate-docker-kafka-ssl-certs.sh

PASSWORD="kafkadocker"
SERVER_KEYSTORE_JKS="docker.kafka.server.keystore.jks"
SERVER_KEYSTORE_P12="docker.kafka.server.keystore.p12"
SERVER_KEYSTORE_PEM="docker.kafka.server.keystore.pem"
SERVER_TRUSTSTORE_JKS="docker.kafka.server.truststore.jks"
CLIENT_TRUSTSTORE_JKS="docker.kafka.client.truststore.jks"
VALIDITY_DAYS=3650

if [[ -e certs ]]; then
  echo "ERROR: certs directory already exists"
  exit 1
fi
mkdir certs

echo "Generating new Kafka SSL certs..."
cd certs
# Generate a CA that is intended to sign other certificates
openssl req -new -x509 -keyout ca-key -out ca-cert -days ${VALIDITY_DAYS} -passout pass:${PASSWORD} \
 -subj "/C=FR/ST=Paris/L=Paris/O=None/OU=None/CN=kafka.docker.test"

# Add the generated CA to the client and server truststore so that they trust this CA
keytool -keystore ${SERVER_TRUSTSTORE_JKS} -alias CARoot -import -file ca-cert -storepass ${PASSWORD} -noprompt
keytool -keystore ${CLIENT_TRUSTSTORE_JKS} -alias CARoot -import -file ca-cert -storepass ${PASSWORD} -noprompt

# Create a server keystore for the server
keytool -keystore ${SERVER_KEYSTORE_JKS} -alias localhost -validity ${VALIDITY_DAYS} -genkey -storepass ${PASSWORD} -keypass ${PASSWORD} \
 -dname "CN=kafka.docker.test, OU=None, O=None, L=Paris, ST=Paris, C=FR"
# The client does not need a keystore because client authentication is done via SASL/PLAIN

# Sign the certificate
## Export the certificate from the keystore
keytool -keystore ${SERVER_KEYSTORE_JKS} -alias localhost -certreq -file cert-file -storepass ${PASSWORD} -noprompt
## Sign it with the CA
openssl x509 -req -CA ca-cert -CAkey ca-key -in cert-file -out cert-signed -days ${VALIDITY_DAYS} -CAcreateserial -passin pass:${PASSWORD}

# Import both the certificate of the CA and the signed certificate into the broker keystore:
keytool -keystore ${SERVER_KEYSTORE_JKS} -alias CARoot -import -file ca-cert -storepass ${PASSWORD} -noprompt
keytool -keystore ${SERVER_KEYSTORE_JKS} -alias localhost -import -file cert-signed -storepass ${PASSWORD} -noprompt

# not needed ?
keytool -keystore ${SERVER_TRUSTSTORE_JKS} -alias localhost -import -file cert-signed -storepass ${PASSWORD} -noprompt

# keystore in PKCS12 format
keytool -importkeystore -srckeystore ${SERVER_KEYSTORE_JKS} -destkeystore ${SERVER_KEYSTORE_P12} -srcstoretype JKS -deststoretype PKCS12 -srcstorepass ${PASSWORD} -deststorepass ${PASSWORD} -noprompt

# PEM for KafkaCat
openssl pkcs12 -in ${SERVER_KEYSTORE_P12} -out ${SERVER_KEYSTORE_PEM} -nodes -passin pass:${PASSWORD}
chmod +rx *

