#!/bin/bash

export TANGO_DIR=/opt/tango
export TANGO_HOST=localhost.localdomain:10000
export LD_LIBRARY_PATH=/opt/tango/lib
PATH=${TANGO_DIR}/bin:/sbin:/usr/sbin:/usr/bin:/bin

tango start
sleep 5
jive &
TangoTest test &
hdb++cm-srv 01 &
hdb++es-srv 01 &
astor &
