#!/bin/bash

# ==================================================
# Record Creation with Certbot in ConoHa Multi-version
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

CONOHAV3_DNS_DOMAIN=${CERTBOT_DOMAIN}'.'
if [ "$CONOHAV3_DOMAIN_NAME_FIX" = true ]; then
  CONOHAV3_DNS_DOMAIN_ROOT=`echo ${CONOHAV3_DNS_DOMAIN} | sed -r 's/^.*?\.([a-zA-Z0-9]+\.[a-zA-Z0-9]+)/\1/g'`
else
  CONOHAV3_DNS_DOMAIN_ROOT="${CONOHAV3_DNS_DOMAIN}"
fi
CONOHAV3_DNS_NAME='_acme-challenge.'${CONOHAV3_DNS_DOMAIN}
CONOHAV3_DNS_TYPE="TXT"
CONOHAV3_DNS_DATA=${CERTBOT_VALIDATION}

# function
source ${SCRIPT_PATH}/dns_api.sh


# -- Create DNS Record -------------------

create_conohav2_dns_record
create_conohav3_dns_record


# -- Waiting time for DNS propagation ----

# This script is compatible with both V2 and V3, 
# but it uses the propagation time settings of V3.

sleep ${CONOHAV3_DNS_WAITTIME}
