#!/bin/bash

PREFIX="aksbicep"
LOC="koreacentral"
RG="${PREFIX}-rg"
az deployment group create -g $RG --template-file 00-main.bicep -p prefix=$PREFIX --mode Complete
