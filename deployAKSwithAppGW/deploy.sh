#!/bin/bash

PREFIX="aksbicep"
LOC="koreacentral"
RG="${PREFIX}-rg"
az group create -n $RG -l $LOC
# az deployment group what-if -g $RG --template-file 00-main.bicep -p prefix=$PREFIX
# echo "check the state using the what if ... " && read 
az deployment group create -g $RG --template-file 00-main.bicep -p prefix=$PREFIX
