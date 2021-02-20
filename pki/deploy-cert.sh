#!/usr/bin/env bash

# Utilize curl + pan-python library to import certificate, for example as a
# scheduled cron job for updating LE certificates
# Best practice is to create a dedicated user with a role that has all elements
# in "Web UI" and "REST API" disabled, "Command Line" is set to "None", where
# only "Commit" and "Import" is enabled under "XML API".

# It is expected that you have created the .panrc file beforehand;
#   panxapi.py -t 'foo' -h <fqdn or ip> -l api-cert -k >> ~/.panrc

# Copy "deploy-cert.dist.conf" to "deploy-cert.conf", and change accordingly

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${SCRIPT_DIR}/deploy-cert.conf"
PAN_HOST=$(grep "hostname%${PAN_TAG}" "${PAN_CONFIG}" | cut -d'=' -f2-)
PAN_APIKEY=$(grep "api_key%${PAN_TAG}" "${PAN_CONFIG}" | cut -d'=' -f2-)

# import cert
curl ${INSECURE} --silent --output /dev/null --form "file=@\"${CERT_FILE}\"" "https://${PAN_HOST}/api/?type=import&category=certificate&certificate-name=${CERT_NAME}&format=pem&key=${PAN_APIKEY}"

# import key
curl ${INSECURE} --silent --output /dev/null --form "file=@\"${CERT_KEY}\"" "https://${PAN_HOST}/api/?type=import&category=private-key&certificate-name=${CERT_NAME}&format=pem&passphrase=foobar&key=${PAN_APIKEY}"

# commit changes
panxapi.py -t ${PAN_TAG} -C '' --sync > /dev/null 2>&1
