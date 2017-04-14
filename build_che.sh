#!/bin/bash

# this script downloads the src and runs the build
# to create the che binaries

. config 

git clone -b ${RH_CHE_GIT_BRANCH} ${RH_CHE_GIT_REPO}

cd rh-che
mkdir $NPM_CONFIG_PREFIX
scl enable rh-maven33 rh-nodejs4 'mvn -D -B clean install -U'
cp target/export/che-dependencies/che/assembly/assembly-main/target/eclipse-ide-*.tar.gz ${HomeDir}
cp assembly/assembly-main/target/eclipse-ide-*.tar.gz ${HomeDir}
scl enable rh-maven33 rh-nodejs4 'mvn -D -B mvn --activate-profiles=-checkout-base-che -DwithoutDashboard clean install -U'
cp assembly/assembly-main/target/eclipse-ide-*.tar.gz ${HomeDir}
