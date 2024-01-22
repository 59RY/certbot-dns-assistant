#!/bin/bash

# ==================================================
# Utilizing Certbot with DNS API in ConoHa V3
#
# Copyright: Yūtenji <yuta@59RY.jp>
# Licensed under: MIT License
# Inspired by: k2snow <github.com/k2snow/letsencrypt-dns-conoha>
# ==================================================


# -- Script Path -------------------------

SCRIPT_PATH=$(dirname $(readlink -f $0))
source ${SCRIPT_PATH}/../.env


# -- Function ----------------------------

get_conohav3_token(){
	curl -sS -i https://identity.${CONOHAV3_REGION}.conoha.io/v3/auth/tokens \
	-X POST \
	-H "Accept: application/json" \
	-H "Content-Type: application/json" \
	-d '{ "auth": { "identity": { "methods": [ "password" ], "password": { "user": { "id": "'${CONOHAV3_USER_ID}'", "password": "'${CONOHAV3_PASSWORD}'" } } }, "scope": { "project": { "id": "'${CONOHAV3_TENANT_ID}'" } } } }' \
	| grep -i '^x-subject-token:' | tr -d '\r' | awk '{print $2}'
}

get_conohav3_domain_id(){
  curl -sS https://dns-service.${CONOHAV3_REGION}.conoha.io/v1/domains \
  -X GET \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-Auth-Token: ${CONOHAV3_TOKEN}" \
  | jq -r '.domains[] | select(.name == "'${CONOHAV3_DNS_DOMAIN_ROOT}'") | .uuid'
}

create_conohav3_dns_record(){
  curl -sS https://dns-service.${CONOHAV3_REGION}.conoha.io/v1/domains/${CONOHAV3_DOMAIN_ID}/records \
  -X POST \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-Auth-Token: ${CONOHAV3_TOKEN}" \
  -d '{ "name": "'${CONOHAV3_DNS_NAME}'", "type": "'${CONOHAV3_DNS_TYPE}'", "data": "'${CONOHAV3_DNS_DATA}'", "ttl": 60 }'
}

get_conohav3_dns_record_id(){
  curl -sS https://dns-service.${CONOHAV3_REGION}.conoha.io/v1/domains/${CONOHAV3_DOMAIN_ID}/records \
  -X GET \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-Auth-Token: ${CONOHAV3_TOKEN}" \
  | jq -r '.records[] | select(.name == "'${CONOHAV3_DNS_NAME}'" and .data == "'${CONOHAV3_DNS_DATA}'") | .uuid'
}

delete_conohav3_dns_record(){
  local delete_id=$1
  curl -sS https://dns-service.${CONOHAV3_REGION}.conoha.io/v1/domains/${CONOHAV3_DOMAIN_ID}/records/${delete_id} \
  -X DELETE \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-Auth-Token: ${CONOHAV3_TOKEN}"
}


# -- Get a Token -------------------------

CONOHAV3_TOKEN=$(get_conohav3_token)


# -- Get the Domain ID -------------------

CONOHAV3_DOMAIN_ID=$(get_conohav3_domain_id)
