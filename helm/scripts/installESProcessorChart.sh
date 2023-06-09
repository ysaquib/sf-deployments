#!/bin/bash
#
# Copyright (C) 2020 IBM Corporation.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [ "$#" -ne 4 ]; then
    echo "Required arguments missing!"
    echo "Usage : ./installAgent <es_addresses> <es_index> <es_username> <es_password>"
    exit 1
fi

NAMESPACE=sysflow
ES_ADDRESSES=$1
ES_INDEX=$2
ES_USERNAME=$3
ES_PASSWORD=$4

# Don't run if any of the prerequisites are not installed.
PREQ=( "kubectl" "helm" )
for i in "${PREQ[@]}"
do
  IS_EXIST=$(command -v $i)
  if [ -z "$IS_EXIST" ]
  then
    echo "$i not installed. Please install the required pre-requisites first (kubectl, helm)"
    exit 1
  fi
done

NS_CREATE=$(kubectl create namespace $NAMESPACE 2>&1)
if [[ "$NS_CREATE" =~ "already exists" ]]; then
    echo "Warning: Namespace '$NAMESPACE' already exists. Proceeding with existing namespace."
else
    echo "Namespace '$NAMESPACE' created successfully"
fi

# sf-deployments/helm/scripts/
REALPATH=$(dirname $(realpath $0))
cd charts


helm install sysflowagent ./sf-chart -f sf-chart/values.yaml --namespace $NAMESPACE --set sfprocessor.export=es --set sfprocessor.esAddresses=$ES_ADDRESSES --set sfprocessor.esIndex=$ES_INDEX --set sfprocessor.esUsername=$ES_USERNAME --set sfprocessor.esPassword=$ES_PASSWORD --debug
