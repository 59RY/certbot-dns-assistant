#!/bin/bash

# ==================================================
# Record Deletion with Certbot in ConoHa V2
#
# Copyright: Yūtenji <yuta@59RY.jp>
# Licensed under: MIT License
# Inspired by: k2snow <github.com/k2snow/letsencrypt-dns-conoha>
# ==================================================


# -- Script Path -------------------------

SCRIPT_NAME=$(basename $0)
SCRIPT_PATH=$(dirname $(readlink -f $0))


# -- DNS API -----------------------------

CONOHAV2_DNS_DOMAIN=${CERTBOT_DOMAIN}'.'
if [ "$CONOHAV2_DOMAIN_NAME_FIX" = true ]; then
  CONOHAV2_DNS_DOMAIN_ROOT=`echo ${CONOHAV2_DNS_DOMAIN} | sed -r 's/^.*?\.([a-zA-Z0-9]+\.[a-zA-Z0-9]+)/\1/g'`
else
  CONOHAV2_DNS_DOMAIN_ROOT="${CONOHAV2_DNS_DOMAIN}"
fi
CONOHAV2_DNS_NAME='_acme-challenge.'${CONOHAV2_DNS_DOMAIN}
CONOHAV2_DNS_TYPE="TXT"
CONOHAV2_DNS_DATA=${CERTBOT_VALIDATION}

# function
source ${SCRIPT_PATH}/dns_api.sh


# -- Get Record ID -----------------------

CONOHAV2_RECORD_ID=$(get_conohav2_dns_record_id)


# -- Delete DNS Record -------------------

delete_conohav2_dns_record ${CONOHAV2_RECORD_ID}
