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

echo "Deleting Kubernetes secret for stocktrader to access MQ"
kubectl delete secret mq -n ${STOCKTRADER_NAMESPACE}

# set up search label to find MQ chart
LABEL="chart=${MQ_CHART}"
if [ "$MQ_RELEASE_NAME" != "" ]; then
  LABEL="${LABEL},release=${MQ_RELEASE_NAME}"
fi

# fetch MQ service namespace if not set
if [ "$MQ_NAMESPACE" = "" ]; then
  echo "Retrieving MQ namespace"
  MQ_NAMESPACE=$(kubectl get service -l ${LABEL} --all-namespaces -o jsonpath="{.items[0].metadata.namespace}")
  echo "Retrieved MQ namespace: $MQ_NAMESPACE"
fi

echo "Finding MQ pod"
MQ_POD=$(kubectl get pods -l ${LABEL} -n ${MQ_NAMESPACE} -o jsonpath="{.items[0].metadata.name}")

echo "Sending MQ command file to MQ pod $MQ_POD"
SCRIPTDIR=`dirname ${BASH_SOURCE[0]}`
kubectl cp ${SCRIPTDIR}/deleteStocktraderQueue.in $MQ_NAMESPACE/$MQ_POD:deleteStocktraderQueue.in

# fix file permission
kubectl exec -it $MQ_POD -n ${MQ_NAMESPACE} -- chmod 644 /deleteStocktraderQueue.in

# delete queue (this will work only if the stocktrader messaging app, which has an active connection to the queue, is stopped/deleted)
echo "Deleting MQ queue"
kubectl exec -it $MQ_POD -n ${MQ_NAMESPACE} -- su - -c "runmqsc <deleteStocktraderQueue.in" admin