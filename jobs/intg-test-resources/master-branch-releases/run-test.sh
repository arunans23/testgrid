#!/bin/bash
#----------------------------------------------------------------------------
#  Copyright (c) 2020 WSO2, Inc. http://www.wso2.org
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#----------------------------------------------------------------------------

set -o xtrace

INPUTS_DIR=$2

# SCRIPT_LOCATION=""
PROP_FILE="${INPUTS_DIR}/deployment.properties"
PRODUCT_GIT_URL=$(grep -w "PRODUCT_GIT_URL" ${PROP_FILE} | cut -d'=' -f2 | cut -d'/' -f3-)
PRODUCT_GIT_BRANCH=$(grep -w "PRODUCT_GIT_BRANCH" ${PROP_FILE} | cut -d'=' -f2)
keyFileLocation=$(grep -w "keyFileLocation" ${PROP_FILE} | cut -d'=' -f2)
WSO2InstanceName=$(grep -w "WSO2InstanceName" ${PROP_FILE} | cut -d'=' -f2 | cut -d"/" -f3)
OperatingSystem=$(grep -w "OS" ${PROP_FILE} | cut -d'=' -f2)
PRODUCT_NAME=$(grep -w "WSO2_PRODUCT" ${PROP_FILE}| cut -d'=' -f2 | cut -d'-' -f1)
PRODUCRT_VERSION=$(grep -w "WSO2_PRODUCT" ${PROP_FILE}| cut -d'=' -f2 | cut -d'-' -f2)

TEST_SCRIPT_URL=$(grep -w "TEST_SCRIPT_URL" ${PROP_FILE} | cut -d'=' -f2)
TEST_SCRIPT_NAME=$(echo $TEST_SCRIPT_URL | rev | cut -d'/' -f1 | rev)

GIT_USER=$(grep -w "GIT_WUM_USERNAME" ${PROP_FILE} | cut -d'=' -f2)
GIT_PASS=$(grep -w "GIT_WUM_PASSWORD" ${PROP_FILE} | cut -d'=' -f2)

function log_info(){
    echo "[INFO][$(date '+%Y-%m-%d %H:%M:%S')]: $1"
}

wget -q $TEST_SCRIPT_URL
INFRA_JSON=$INPUTS_DIR/../workspace/InfraRepository/jobs/intg-test-resources/infra.json

log_info "Copying ${TEST_SCRIPT_NAME} to remote ec2 instance"

if [ ${OperatingSystem} = "Ubuntu" ]; then
    instanceUser="ubuntu"
elif [ ${OperatingSystem} = "CentOS" ]; then
    instanceUser="centos"
else
    instanceUser="ec2-user"
fi

scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${keyFileLocation} ${TEST_SCRIPT_NAME} $instanceUser@${WSO2InstanceName}:/opt/testgrid/workspace/${TEST_SCRIPT_NAME}
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${keyFileLocation} ${INFRA_JSON} $instanceUser@${WSO2InstanceName}:/opt/testgrid/workspace/infra.json
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${keyFileLocation} $instanceUser@${WSO2InstanceName} "cd /opt/testgrid/workspace && sudo bash ${TEST_SCRIPT_NAME} ${PRODUCT_GIT_URL} ${PRODUCT_GIT_BRANCH} ${PRODUCT_NAME} ${PRODUCRT_VERSION}"