#!/bin/bash

# script to run hdb-viewer

TANGO_LIBS=/opt/tango/share/java

classes="JTango ATKWidget ATKCore Jive jhdbviewer libhdbpp-java jcalendar jython"
for c in $classes; do
    PATH_TO_JAR=${TANGO_LIBS}/${c}.jar
    [ -e ${PATH_TO_JAR} ] || { echo "Error: $PATH_TO_JAR is missing!"; exit 1; }
    CLASSPATH=${CLASSPATH}:${PATH_TO_JAR}
done

export CLASSPATH
echo CLASSPATH $CLASSPATH

export TANGO_HOST=localhost:10000
export HDB_TYPE=mysql
export HDB_MYSQL_HOST=localhost
export HDB_USER=hdbpp
export HDB_PASSWORD=hdbpppassword
export HDB_NAME=hdbpp

java HDBViewer.MainPanel
