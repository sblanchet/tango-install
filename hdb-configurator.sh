#!/bin/bash

# script to run hdb-configurator

TANGO_LIBS=/opt/tango/share/java

classes="JTango ATKWidget ATKCore Jive hdbpp-configurator"
for c in $classes; do
    PATH_TO_JAR=${TANGO_LIBS}/${c}.jar
    [ -e ${PATH_TO_JAR} ] || { echo "Error: $PATH_TO_JAR is missing!"; exit 1; }
    CLASSPATH=${CLASSPATH}:${PATH_TO_JAR}
done

export CLASSPATH
echo CLASSPATH $CLASSPATH

export TANGO_HOST=localhost.localdomain:10000
export HdbManager=archiving/hdb++/confmanager.01

java org.tango.hdb_configurator.configurator.HdbConfigurator $@
