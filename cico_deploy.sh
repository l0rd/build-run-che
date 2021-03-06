#!/bin/bash
set -eu

# Source build variables
cat jenkins-env | grep -e ^CHE_ > inherit-env
. inherit-env
. config 

# Install oc client
yum install -y centos-release-openshift-origin
yum install -y origin-clients

# Login
oc login "${CHE_OPENSHIFT_ENDPOINT}" -u "${CHE_OPENSHIFT_USERNAME}" -p "${CHE_OPENSHIFT_PASSWORD}" --insecure-skip-tls-verify

# Ensure we're in the che project
oc project ${CHE_OPENSHIFT_PROJECT}

# Create or update template
oc -n ${CHE_OPENSHIFT_PROJECT} create -f che.json >/dev/null 2>&1 || oc -n ${CHE_OPENSHIFT_PROJECT} replace -f che.json >/dev/null 2>&1

# Check if deploymentConfig is already present
OUT=$(oc -n ${CHE_OPENSHIFT_PROJECT} get dc ${CHE_APPLICATION_NAME} 2> /dev/null || true)
if [[ $OUT != "" ]]; then
    # Cleanup the project
    oc -n ${CHE_OPENSHIFT_PROJECT} delete dc,route,svc,po --all
    sleep 30
fi

# Deploy che from the template
oc -n ${CHE_OPENSHIFT_PROJECT} new-app --template=eclipse-che \
    --param=APPLICATION_NAME=${CHE_APPLICATION_NAME} \
    --param=CHE_SERVER_DOCKER_IMAGE=${CHE_OPENSHIFT_IMAGE} \
    --param=CHE_OPENSHIFT_ENDPOINT=${CHE_OPENSHIFT_ENDPOINT} \
    --param=CHE_OPENSHIFT_USERNAME=${CHE_OPENSHIFT_USERNAME} \
    --param=CHE_OPENSHIFT_PASSWORD=${CHE_OPENSHIFT_PASSWORD} \
    --param=CHE_OPENSHIFT_SERVICEACCOUNTNAME=${CHE_OPENSHIFT_SERVICEACCOUNTNAME} \
    --param=HOSTNAME_HTTP=${CHE_OPENSHIFT_HOSTNAME} \
    --param=CHE_LOG_LEVEL=INFO