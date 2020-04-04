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

# fetch MQ service name if not set
# MQ creates multiple services with identical labels so we have to search for the one representing the qmgr
if [ "$MQ_SERVICE_NAME" = "" ]; then
  echo "Retrieving MQ service name"
  MQ_SERVICES=$(kubectl get service -l ${LABEL} -n ${MQ_NAMESPACE} -o jsonpath="{.items[*].metadata.name}")
  for MQ_SERVICE_NAME in $MQ_SERVICES; do
    QMGR=$(kubectl get service ${MQ_SERVICE_NAME} -n ${MQ_NAMESPACE} -o jsonpath="{.spec.ports[?(@.port==1414)].name}")
    if [ "$QMGR" != "" ]; then
      break
    fi
  done
  echo "Retrieved MQ service name: $MQ_SERVICE_NAME" 
fi

# form MQ DNS service name
MQ_DNS_HOST=${MQ_SERVICE_NAME}.${MQ_NAMESPACE}

# find MQ queue manager
if [ "$MQ_QMGR" = "" ]; then
  echo "Retrieving MQ qmgr name"
  MQ_QMGR=$(kubectl get statefulset -l ${LABEL} -n ${MQ_NAMESPACE} -o jsonpath="{.items[0].spec.template.spec.containers[0].env[?(@.name==\"MQ_QMGR_NAME\")].value}")
  echo "Retrieved MQ qmgr name" $MQ_QMGR
fi

# fetch mq app password if not set
if [ "$MQ_APP_PASSWORD" = "" ]; then
  echo "Retrieving MQ app password"
  MQ_APP_PASSWORD=$(kubectl get secret -l ${LABEL} -n ${MQ_NAMESPACE} -o jsonpath="{.items[0].data.appPassword}")
  if [ "$MQ_APP_PASSWORD" != "" ]; then
      MQ_APP_PASSWORD=`echo "$MQ_APP_PASSWORD" | base64 -d`
  fi
  echo "Retrieved MQ app password"
fi

echo "Creating Kubernetes secret for stocktrader to access MQ"
kubectl create secret generic mq --from-literal=id=app --from-literal=pwd=$MQ_APP_PASSWORD --from-literal=host=$MQ_DNS_HOST --from-literal=port=$MQ_PORT --from-literal=channel=DEV.APP.SVRCONN --from-literal=queue-manager=$MQ_QMGR --from-literal=queue=NotificationQ -n ${STOCKTRADER_NAMESPACE}

echo "Finding MQ pod"
MQ_POD=$(kubectl get pods -l ${LABEL} -n ${MQ_NAMESPACE} -o jsonpath="{.items[0].metadata.name}")

echo "Sending MQ command file to MQ pod $MQ_POD"
SCRIPTDIR=`dirname ${BASH_SOURCE[0]}`
kubectl cp ${SCRIPTDIR}/defineStocktraderQueue.in $MQ_NAMESPACE/$MQ_POD:/tmp/defineStocktraderQueue.in

# fix file permission
kubectl exec -it $MQ_POD -n ${MQ_NAMESPACE} -- chmod 644 /tmp/defineStocktraderQueue.in

# create queue
echo "Creating MQ queue"
kubectl exec -it $MQ_POD -n ${MQ_NAMESPACE} -- su - -c "runmqsc < /tmp/defineStocktraderQueue.in" admin
