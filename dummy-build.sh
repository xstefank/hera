#!/bin/bash
readonly BUILD_JOB_TIMEOUT=${BUILD_JOB_TIMEOUT:-'60'}
export BUILD_JOB_TIMEOUT

export MAVEN_HOME=/opt/tools/apache-maven-3.6.3/
export PATH=${MAVEN_HOME}/bin:${PATH}


mvn -version
cd /var/jenkins_home/jobs/sqfsqfqdf/workspace/
echo "Current dir: $(pwd)."
mvn clean install

#"${HERA_HOME}/wait.sh"
