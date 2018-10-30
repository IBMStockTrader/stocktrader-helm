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

echo "Deleting Kubernetes secret for stocktrader to access ODM"
kubectl delete secret odm -n $STOCKTRADER_NAMESPACE

# Get a node
NODE_IP=$(kubectl get nodes --output=jsonpath="{.items[0].metadata.name}")

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

# Get ODM node port for REST API calls
if [ "$ODM_NODEPORT" = "" ]; then
  echo "Retrieving ODM nodeport"
  ODM_NODEPORT=$(kubectl get services ${ODM_SERVICE_NAME} -n ${ODM_NAMESPACE} -o jsonpath="{.spec.ports[0].nodePort}")
  echo "Retrieved ODM nodeport: $ODM_NODEPORT"
fi

echo " "
echo "The ODM REST API does not support deleting a decision service.  You will need to remove it manually via the Decision Center Business Console."
echo "  http://${NODE_IP}:$ODM_NODEPORT/decisioncenter"
echo "Log in as odmadmin/odmadmin"
echo "Click the delete option in the action menu on the stock-trader-loyalty-decision-service tile."
