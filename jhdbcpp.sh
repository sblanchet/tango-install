#!/bin/bash
TANGO_HOME=/opt/tango/share/java/
TANGO_LIBS=$TANGO_HOME
TANGO_APP=$TANGO_HOME

Appli=${TANGO_HOME}/jhdbcpp.jar

CLASSPATH=$TANGO_LIBS/JTango.jar:$TANGO_LIBS/ATKWidget.jar:$TANGO_LIBS/ATKCore.jar
CLASSPATH=$CLASSPATH:$TANGO_APP/Jive.jar:$Appli
export CLASSPATH
echo CLASSPATH $CLASSPATH

export TANGO_HOST=127.0.0.1:10000
export HdbManager=archiving/hdb++/confmanager.01
export JNIPATH=-Djava.library.path=/usr/lib/x86_64-linux-gnu/

if [ "$#" -lt 1 ]
then
    java  $JNIPATH org.tango.hdbcpp.configurator.HdbConfigurator
else
    if [ $1 = "-diag" ]
    then
        java  $JNIPATHorg.tango.hdbcpp.diagnostics.HdbDiagnostics
    else
        java  $JNIPATH org.tango.hdbcpp.configurator.HdbConfigurator
    fi
fi
