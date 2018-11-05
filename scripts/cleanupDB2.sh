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

echo "Deleting Kubernetes secret for stocktrader to access DB2"
kubectl delete secret db2 -n ${STOCKTRADER_NAMESPACE}

# set up search label to find db2 chart
LABEL="chart=${DB2_CHART}-${DB2_CHART_VERSION}"
if [ "$DB2_RELEASE_NAME" != "" ]; then
  LABEL="${LABEL},release=${DB2_RELEASE_NAME}"
fi

# fetch DB2 service namespace if not set
if [ "$DB2_NAMESPACE" = "" ]; then
  echo "Retrieving DB2 namespace"
  DB2_NAMESPACE=$(kubectl get service -l ${LABEL} --all-namespaces -o jsonpath="{.items[0].metadata.namespace}")
  echo "Retrieved DB2 namespace: $DB2_NAMESPACE"
fi

# set up search label to find db2 pod (statefulset doesn't use chart version in its chart label)
LABEL2="chart=${DB2_CHART}"
if [ "$DB2_RELEASE_NAME" != "" ]; then
  LABEL2="${LABEL2},release=${DB2_RELEASE_NAME}"
fi

echo "Finding DB2 pod"
DB2_POD=$(kubectl get pods -l ${LABEL2} -n ${DB2_NAMESPACE} -o jsonpath="{.items[0].metadata.name}")

echo "Sending ddl file to DB2 pod $DB2_POD"
SCRIPTDIR=`dirname ${BASH_SOURCE[0]}`
kubectl cp ${SCRIPTDIR}/dropStocktraderTables.ddl $DB2_NAMESPACE/$DB2_POD:dropStocktraderTables.ddl

# fix file permission
kubectl exec -it $DB2_POD -n ${DB2_NAMESPACE} -- chmod 644 /dropStocktraderTables.ddl

# delete schema
echo "Deleting DB2 tables"
kubectl exec -it $DB2_POD -n ${DB2_NAMESPACE} -- su - -c "db2 connect to $STOCKTRADER_DB && db2 -tf /dropStocktraderTables.ddl" $DB2_USER
