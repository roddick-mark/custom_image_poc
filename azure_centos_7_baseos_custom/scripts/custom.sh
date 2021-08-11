#!/usr/bin/env bash

az login --service-principal -u $spn_client_id -p $spn_client_secret --tenant $spn_tenant_id
az account list