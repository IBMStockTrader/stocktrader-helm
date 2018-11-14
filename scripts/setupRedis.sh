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

source variables.sh

# set up search label to find Redis chart
LABEL="chart=${REDIS_CHART}-${REDIS_CHART_VERSION}"
if [ "$REDIS_RELEASE_NAME" != "" ]; then
  LABEL="${LABEL},release=${REDIS_RELEASE_NAME}"
fi

# fetch REDIS service namespace if not set
if [ "$REDIS_NAMESPACE" = "" ]; then
  echo "Retrieving Redis namespace"
  REDIS_NAMESPACE=$(kubectl get service -l ${LABEL} --all-namespaces -o jsonpath="{.items[0].metadata.namespace}")
  echo "Retrieved REDIS namespace: $REDIS_NAMESPACE"
fi

# fetch REDIS service name if not set
if [ "$REDIS_SERVICE_NAME" = "" ]; then
  echo "Retrieving Redis service name"
  REDIS_SERVICES=$(kubectl get service -l ${LABEL} -n ${REDIS_NAMESPACE} -o jsonpath="{.items[*].metadata.name}")
  for REDIS_SERVICE_NAME in $REDIS_SERVICES; do
    case $REDIS_SERVICE_NAME in
     *master*) break;;
     * ) ;;
    esac
  done
  echo "Retrieved REDIS service name: $REDIS_SERVICE_NAME" 
fi

# form REDIS DNS service name
REDIS_DNS_HOST=${REDIS_SERVICE_NAME}.${REDIS_NAMESPACE}

echo "Creating Kubernetes secret for stocktrader to access Redis"
kubectl create secret generic redis --from-literal=url=redis://$REDIS_DNS_HOST:6379 --namespace $STOCKTRADER_NAMESPACE
