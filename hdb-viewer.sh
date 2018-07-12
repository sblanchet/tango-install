#!/bin/bash

# script to run hdb-viewer

TANGO_LIBS=/opt/tango/share/java

classes="JTango ATKWidget ATKCore Jive jhdbviewer"
for c in $classes; do
    PATH_TO_JAR=${TANGO_LIBS}/${c}.jar
    [ -e ${PATH_TO_JAR} ] || { echo "Error: $PATH_TO_JAR is missing!"; exit 1; }
    CLASSPATH=${CLASSPATH}:${PATH_TO_JAR}
done

export CLASSPATH
echo CLASSPATH $CLASSPATH

export TANGO_HOST=127.0.0.1:10000

java HDBViewer.MainPanel
