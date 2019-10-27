#!/bin/bash

set -e
set -u

source credentials

PORTAINER_CREDENTIALS="$(docker run --rm httpd:2.4-alpine htpasswd -nbB admin ${PORTAINER_PASS} | cut -d ":" -f 2)"

REGISTRY_CREDENTIALS="$(docker run --rm httpd:2.4-alpine htpasswd -nbB admin ${REGISTRY_PASS} | cut -d ":" -f 2)"
REGISTRY_CREDENTIALS="${REGISTRY_USER}:${REGISTRY_CREDENTIALS}"

DASHBOARD_CREDENTIALS="$(docker run --rm httpd:2.4-alpine htpasswd -nbB admin ${DASHBOARD_PASS} | cut -d ":" -f 2)"
DASHBOARD_CREDENTIALS="${DASHBOARD_USER}:${DASHBOARD_CREDENTIALS}"

export PORTAINER_CREDENTIALS
export REGISTRY_CREDENTIALS
export DASHBOARD_CREDENTIALS
export EMAIL
export DOMAIN

docker-compose build
docker-compose up -d
