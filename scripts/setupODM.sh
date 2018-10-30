#!/bin/bash
# Copyright [2018] IBM Corp. All Rights Reserved.
# 
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
# 
#        http://www.apache.org/licenses/LICENSE-2.0
# 
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

# User must have curl and jq installed on local system.

source variables.sh

# Location of decision service zip
STOCKTRADER_DECISION_SERVICE=../../portfolio/stock-trader-loyalty-decision-service.zip

if [ ! -f "$STOCKTRADER_DECISION_SERVICE" ]; then
    echo "File '${STOCKTRADER_DECISION_SERVICE}' not found.  Make sure you have cloned the portfolio project."
    exit
fi

# set up search label to find ODM chart
LABEL="chart=${ODM_CHART}-${ODM_CHART_VERSION}"
if [ "$ODM_RELEASE_NAME" != "" ]; then
  LABEL="${LABEL},release=${ODM_RELEASE_NAME}"
fi

# fetch ODM service namespace if not set
if [ "$ODM_NAMESPACE" = "" ]; then
  echo "Retrieving ODM namespace"
  ODM_NAMESPACE=$(kubectl get service -l ${LABEL} --all-namespaces -o jsonpath="{.items[0].metadata.namespace}")
  echo "Retrieved ODM namespace: $ODM_NAMESPACE"
fi

# fetch ODM service name if not set
if [ "$ODM_SERVICE_NAME" = "" ]; then
  echo "Retrieving ODM service name"
  ODM_SERVICE_NAME=$(kubectl get service -l ${LABEL} -n ${ODM_NAMESPACE} -o jsonpath="{.items[0].metadata.name}")
  echo "Retrieved ODM service name: $ODM_SERVICE_NAME" 
fi

# form ODM DNS service name
ODM_DNS_HOST=${ODM_SERVICE_NAME}.${ODM_NAMESPACE}

echo "Creating Kubernetes secret for stocktrader to access ODM"
kubectl create secret generic odm --from-literal=url=http://${ODM_DNS_HOST}:9060/DecisionService/rest/v1/ICP_Trader_Dev_1/determineLoyalty  --from-literal=id=$ODM_USER --from-literal=pwd=$ODM_PASSWORD -n $STOCKTRADER_NAMESPACE

# Get a node for REST API calls
NODE_IP=$(kubectl get nodes --output=jsonpath="{.items[0].metadata.name}")

# Get ODM node port for REST API calls
if [ "$ODM_NODEPORT" = "" ]; then
  echo "Retrieving ODM nodeport"
  ODM_NODEPORT=$(kubectl get services ${ODM_SERVICE_NAME} -n ${ODM_NAMESPACE} -o jsonpath="{.spec.ports[0].nodePort}")
  echo "Retrieved ODM nodeport: $ODM_NODEPORT"
fi

# Import stocktrader decision service
echo "Importing stocktrader decision service"
STATUS=$(curl \
 -X POST -H "Content-Type: multipart/form-data" \
 -F "file=@${STOCKTRADER_DECISION_SERVICE};type=application/x-zip-compressed" \
 -w %{http_code} \
 -o import.out \
 http://${NODE_IP}:$ODM_NODEPORT/decisioncenter-api/v1/decisionservices/import --user $ODM_USER:$ODM_PASSWORD)

if [ "$STATUS" != "200" ]; then
  echo "Importing stocktrader decision service failed"
  cat import.out
  exit
fi

DECISION_ID=$( cat import.out | jq -r ".decisionService.id" )
echo "Imported stocktrader decision service.  Decision service id is " $DECISION_ID

# Deploy stocktrader ruleapp to execution server
echo "Finding deployment id"
STATUS=$(curl \
 -w %{http_code} \
 -o find.out \
 http://${NODE_IP}:$ODM_NODEPORT/decisioncenter-api/v1/decisionservices/${DECISION_ID}/deployments --user $ODM_USER:$ODM_PASSWORD)

if [ "$STATUS" != "200" ]; then
  echo "Finding deployment id failed"
  cat find.out
  exit
fi

DEPLOYMENT_ID=$( cat find.out | jq -r ".elements[0].id" )

echo "Found deployment ID" $DEPLOYMENT_ID ". Deploying it."
STATUS=$(curl \
 -X POST \
 -w %{http_code} \
 -o deploy.out \
 http://${NODE_IP}:$ODM_NODEPORT/decisioncenter-api/v1/deployments/${DEPLOYMENT_ID}/deploy --user $ODM_USER:$ODM_PASSWORD)

if [ "$STATUS" != "200" ]; then
  echo "Deployment failed"
  cat deploy.out
  exit
fi

echo "Deployment successful"
