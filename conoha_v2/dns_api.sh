#!/bin/bash

# ==================================================
# Utilizing Certbot with DNS API in ConoHa V2
#
# Copyright: Yūtenji <yuta@59RY.jp>
# Licensed under: MIT License
# Inspired by: k2snow <github.com/k2snow/letsencrypt-dns-conoha>
# ==================================================


# -- Script Path -------------------------

SCRIPT_PATH=$(dirname $(readlink -f $0))
source ${SCRIPT_PATH}/../.env


# -- Function ----------------------------

get_conohav2_token(){
	curl -sS https://identity.${CONOHAV2_REGION}.conoha.io/v2.0/tokens \
	-X POST \
	-H "Accept: application/json" \
	-d '{ "auth": { "passwordCredentials": { "username": "'${CONOHAV2_USERNAME}'", "password": "'${CONOHAV2_PASSWORD}'" }, "tenantId": "'${CONOHAV2_TENANT_ID}'" } }' \
	| jq -r ".access.token.id"
}

get_conohav2_domain_id(){
  curl -sS https://dns-service.${CONOHAV2_REGION}.conoha.io/v1/domains \
  -X GET \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-Auth-Token: ${CONOHAV2_TOKEN}" \
  | jq -r '.domains[] | select(.name == "'${CONOHAV2_DNS_DOMAIN_ROOT}'") | .id'
}

create_conohav2_dns_record(){
  curl -sS https://dns-service.${CONOHAV2_REGION}.conoha.io/v1/domains/${CONOHAV2_DOMAIN_ID}/records \
  -X POST \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-Auth-Token: ${CONOHAV2_TOKEN}" \
  -d '{ "name": "'${CONOHAV2_DNS_NAME}'", "type": "'${CONOHAV2_DNS_TYPE}'", "data": "'${CONOHAV2_DNS_DATA}'", "ttl": 60 }'
}

get_conohav2_dns_record_id(){
  curl -sS https://dns-service.${CONOHAV2_REGION}.conoha.io/v1/domains/${CONOHAV2_DOMAIN_ID}/records \
  -X GET \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-Auth-Token: ${CONOHAV2_TOKEN}" \
  | jq -r '.records[] | select(.name == "'${CONOHAV2_DNS_NAME}'" and .data == "'${CONOHAV2_DNS_DATA}'") | .id'
}

delete_conohav2_dns_record(){
  local delete_id=$1
  curl -sS https://dns-service.${CONOHAV2_REGION}.conoha.io/v1/domains/${CONOHAV2_DOMAIN_ID}/records/${delete_id} \
  -X DELETE \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-Auth-Token: ${CONOHAV2_TOKEN}"
}


# -- Get a Token -------------------------

CONOHAV2_TOKEN=$(get_conohav2_token)


# -- Get the Domain ID -------------------

CONOHAV2_DOMAIN_ID=$(get_conohav2_domain_id)
