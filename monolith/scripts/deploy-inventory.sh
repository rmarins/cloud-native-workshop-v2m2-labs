#!/bin/bash

USERXX=$1
DELAY=$2

if [ -z $USERXX ]
  then
    echo "Usage: Input your username like deploy-inventory.sh user1"
    exit;
fi

echo Your username is $USERXX

echo Deploy Inventory service........

oc project $USERXX-inventory

mvn clean package -DskipTests -f $CHE_PROJECTS_ROOT/cloud-native-workshop-v2m2-labs/inventory/

oc new-app -e POSTGRESQL_USER=inventory \
  -e POSTGRESQL_PASSWORD=mysecretpassword \
  -e POSTGRESQL_DATABASE=inventory openshift/postgresql:latest \
  --name=inventory-database

oc new-build java:8 --binary --name=inventory-quarkus -l app=inventory-quarkus

if [ ! -z $DELAY ]
  then
    echo Delay is $DELAY
    sleep $DELAY
fi

oc start-build inventory-quarkus --from-file $CHE_PROJECTS_ROOT/cloud-native-workshop-v2m2-labs/inventory/target/*-runner.jar --follow
oc new-app inventory-quarkus -e QUARKUS_PROFILE=prod
oc expose service inventory-quarkus
