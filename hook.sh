#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

TTL=${TTL-14400}
USE_TEST=${USE_TEST-0}
VERSIO_ENDPOINT=https://www.secure.versio.nl/api/api_server.php

case "$1" in
  "clean_challenge")
    DOMAIN=$(echo -n "$2" | rev | cut -d '.' -f 2 | rev)
    SUBDOMAIN=$(echo -n "$2" | rev | cut -d '.' -f 3- | rev)
    TLD=$(echo -n "$2" | rev | cut -d '.' -f 1 | rev)

    echo -e "\nEnter the ID of the challenge '$4' for domain '$2' to immediately remove it."
    echo -e "It should have been reported by the previous stage."
    echo -e "You can also opt to remove it at a later time using your control panel.\n"
    echo -n "Enter the challenge record's ID: "
    read -r RECORD_ID
    RESPONSE=$(curl -X POST -H 'Connection: close' --silent \
                    --data "klantId=${CUSTOMER_ID}&klantPw=${CUSTOMER_PW}&sandBox=${USE_TEST}&command=DomainsDNSDeleteRecord&domain=${DOMAIN}&tld=${TLD}&id=${RECORD_ID}" \
                    ${VERSIO_ENDPOINT})

    SUCCESS=$(echo -en "$RESPONSE" | head -n 1 | cut -d ' ' -f 1 | cut -d '=' -f 2)
    [[ $SUCCESS == 1 ]] && echo -e "\nThe challenge was successfully removed\n"
    [[ $SUCCESS == 0 ]] && echo -e "\nThe challenge could not be removed\n"
  ;;
  "deploy_challenge")
    DOMAIN=$(echo -n "$2" | rev | cut -d '.' -f 2 | rev)
    SUBDOMAIN=$(echo -n "$2" | rev | cut -d '.' -f 3- | rev)
    TLD=$(echo -n "$2" | rev | cut -d '.' -f 1 | rev)

    RESPONSE=$(curl -X POST -H 'Connection: close' --silent \
                    --data "klantId=${CUSTOMER_ID}&klantPw=${CUSTOMER_PW}&sandBox=${USE_TEST}&command=DomainsDNSAddRecord&domain=${DOMAIN}&tld=${TLD}&ttl=${TTL}&name=_acme-challenge.${SUBDOMAIN}&type=TXT&value=$4" \
                    ${VERSIO_ENDPOINT})

    SUCCESS=$(echo -en "$RESPONSE" | head -n 1 |  cut -d ' ' -f 1 | cut -d '=' -f 2)
    RECORD_ID=$(echo -en "$RESPONSE" | tail -n 1 | cut -d ' ' -f 1 | cut -d '=' -f 2)

    [[ $SUCCESS == 1 ]] && echo -e "\nThe challenge record was added with ID: $RECORD_ID\n"
    [[ $SUCCESS == 0 ]] && echo -e "\nAn error occurred:\n${RESPONSE}\n"

    echo 'Press enter to continue when the challenge has been deployed...'
    read -r
  ;;
  "deploy_cert")
    # do nothing for now
  ;;
  "exit_hook")
    # do nothing for now
  ;;
  "invalid_challenge")
    echo "An invalid challenge response was provided for $2"
    exit 1
  ;;
  "unchanged_cert")
    # do nothing for now
  ;;
  *)
    echo Unknown hook "${1}"
    exit 1
  ;;
esac

exit 0
