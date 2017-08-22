#
# Automatic installation of TANGO and HDB++
#
# Author: Sebastien BLANCHET
# Creation Date: 2017-08-22
#

################# BEGIN OF USER SETTINGS SECTION
# all the user settings are defined in this section


TANGO_VERSION:=tango-9.2.5a
# installation directory
TANGO_DIR:=/opt/tango
TANGO_HOST:=127.0.0.1:10000


# Download URLs
TANGO_GITHUB:=https://github.com/tango-controls

TANGO_SRC_URL:=ftp://ftp.esrf.eu/pub/cs/tango/${TANGO_VERSION}.tar.gz
HDBPP_CONFIGURATOR_URL=https://bintray.com/tango-controls/maven/download_file?file_path=org%2Ftango%2Fhdb%2Fhdbpp-configurator%2F2.2%2Fhdbpp-configurator-2.2.jar


# Git repository for HDB++ mysql backend
HDBPP_MYSQL_URL:=${TANGO_GITHUB}/libhdbpp-mysql.git
# Git repository for HDB++ Configuration manager
HDBPP_CM_URL:=${TANGO_GITHUB}/hdbpp-cm.git
# Git repository for HDB++ Event Subscriber
HDBPP_ES_URL:=${TANGO_GITHUB}/hdbpp-es.git
# Git repository for HDB++ Configurator GUI
HDBPP_CONF_GUI_URL:=${TANGO_GITHUB}/hdbpp-configurator.git
# Git repository for HDB++ Viewer
HDBPP_VIEWER_URL:=${TANGO_GITHUB}/hdbpp-viewer.git

# Git repository for TANGO
TANGO_URL:=${TANGO_GITHUB}/TangoSourceDistribution.git


################ END OF USER SETTINGS SECTION

## After this line there is no user settings you can edit

PATH:=/sbin:/usr/sbin:/usr/bin:/bin:${TANGO_DIR}/bin

# Local git repo after cloning remote git repositories
HDBPP_MYSQL_SRC:=libhdbpp-mysql
HDBPP_CM_SRC:=hdbpp-cm
HDBPP_ES_SRC:=hdbpp-es
HDBPP_CONF_GUI_SRC:=hdbpp-configurator
HDBPP_VIEWER_SRC:=hdbpp-viewer
HDBPP_CONF_JAR=hdbpp-configurator.jar
TANGO_SRC=tango

# default target
default: help


.PHONY: \
    get_sources     \
    help            \
    install_tango   \
    install_itango  \
    install_hdbpp   \
    run             \





get_sources:
	# Download sources without compiling
	# if the apt-get commands fail, run 'apt-get -q update' and try again
	apt-get -yq install git wget
	@echo


	# Download Tango source code
#	Git repository for Tango does not compile. Download .tar.gz from ftp.esrf.fr instead
#	[ -d ${TANGO_SRC} ] || git clone --recursive ${TANGO_URL} ${TANGO_SRC}
#	ln -sf ${TANGO_SRC} ${TANGO_VERSION}
	[ -e ${TANGO_VERSION}.tar.gz ] || wget -q ftp://ftp.esrf.eu/pub/cs/tango/${TANGO_VERSION}.tar.gz -O ${TANGO_VERSION}.tar.gz
	@echo


	# Download hdbpp-configurator
#	Git respository for hdbpp-configurator does not compile yet. Download precompiled .jar instead
#	[ -d ${HDBPP_CONF_GUI_SRC} ] || git clone --recursive ${HDBPP_CONF_GUI_URL} ${HDBPP_CONF_GUI_SRC}
#	@echo

#       A precompiled .jar is available on this webpage, but I do not know how to start it
#       http://www.tango-controls.org/community/project-docs/hdbplusplus/hdbplusplus-doc/configuration-gui/
#	# Download JAR file for hdbpp-configurator GUI
#	[ -e ${HDBPP_CONF_JAR} ] || wget -q ${HDBPP_CONFIGURATOR_URL} -O ${HDBPP_CONF_JAR}
#	@echo




help:
	@echo "Automatic TANGO/HDB++ installation"
	@echo
	@echo "make get_sources   : download source code without compiling"
	@echo "make help          : display this help message"
	@echo "make install_tango : install TANGO"
	@echo "make install_hdbpp : install HDB++"
	@echo "make install       : install TANGO and HDB++"
	@echo "make run           : run Tango and its applications"



install: install_tango install_itango install_hdbpp
	make run



install_hdbpp: get_sources
	# install prerequesites to compile hdbpp programs
	apt-get -yq install maven

	# Compile HDB++ MySQL backend
	export TANGO_DIR=${TANGO_DIR} && cd ${HDBPP_MYSQL_SRC} && make
	cd ${HDBPP_MYSQL_SRC} && install -m644 -oroot -groot lib/* ${TANGO_DIR}/lib/
	# Compile abstract database interface
	export TANGO_DIR=${TANGO_DIR} && cd ${HDBPP_MYSQL_SRC}/.libhdbpp && make
	cd ${HDBPP_MYSQL_SRC}/.libhdbpp && install -m644 -oroot -groot lib/* ${TANGO_DIR}/lib/

	# Create SQL database

	# Create database and userfor HDB++
	./create_hdb++_db_user.sh
	# Create tables
	for sqlfile in ${HDBPP_MYSQL_SRC}/etc/*.sql ; do cat $$sqlfile | mysql hdbpp ; done
	@echo

	# Compile HDB++ Configuration Manager
	export TANGO_DIR=${TANGO_DIR} && cd ${HDBPP_CM_SRC} && make && install -m755 -oroot -groot bin/* ${TANGO_DIR}/bin/
	# Compile HDB++ Event Subscriber
	export TANGO_DIR=${TANGO_DIR} && cd ${HDBPP_ES_SRC} && make && install -m755 -oroot -groot bin/* ${TANGO_DIR}/bin/
	@echo

#       Compilation of hdbpp-configurator does not work yet, so download .jar instead
#	# Compile HDB++ Configurator GUI with maven
#	cd ${HDBPP_CONF_GUI_SRC} && mvn compile

#       hdbpp-configurator-2.2.jar from http://www.tango-controls.org/community/project-docs/hdbplusplus/hdbplusplus-doc/configuration-gui/
#       does not work yet
#       use jhdbcpp-2.2.jar from TangoVM instead
#       ftp://ftp.esrf.fr/pub/cs/tango/tango92-vm_RC1.zip
#	# Install HDB++ Configurator GUI JAR file
#	install -m644 -oroot -groot ${HDBPP_CONF_JAR} ${TANGO_DIR}/share/java/${HDBPP_CONF_JAR}
	# Install HDB++ Configurator launcher script
	install -m644 -oroot -groot jhdbcpp-2.2.jar ${TANGO_DIR}/share/java/
	cd ${TANGO_DIR}/share/java/ && ln -sf jhdbcpp-2.2.jar jhdbcpp.jar
	install -m755 -oroot -groot jhdbcpp.sh ${TANGO_DIR}/bin
	@echo

	# Compile HDB Viewer
	cd ${HDBPP_VIEWER_SRC} && mvn install
	install -m644 -oroot -groot ${HDBPP_VIEWER_SRC}/target/jhdbviewer*.jar ${TANGO_DIR}/share/java/jhdbviewer.jar


	# Start tango server to use tango_admin later
	${TANGO_DIR}/bin/tango start
	# wait DataBaseds is up
	sleep 5

	# Declare TANGO device server: hdb++cm-srv and its properties
	TANGO_HOST=${TANGO_HOST}  tango_admin --add-server hdb++cm-srv/01 HdbConfigurationManager archiving/hdb++/confmanager.01
	# use 127.0.0.1 to force IPv4 version of localhost,
	# because hdb++cm-srv dislikes resolving IPv6 address "::1"
	TANGO_HOST=${TANGO_HOST}  tango_admin --add-property archiving/hdb++/confmanager.01 ArchiverList tango://${TANGO_HOST}/archiving/hdb++/eventsubscriber.01
	TANGO_HOST=${TANGO_HOST}  tango_admin --add-property archiving/hdb++/confmanager.01 LibConfiguration "host=localhost,user=hdbpp,password=hdbpppassword,dbname=hdbpp,port=3306,libname=libhdb++mysql.so"
	@echo

	# Declare TANGO device server: hdb++cm-srv and its properties
	TANGO_HOST=${TANGO_HOST}  tango_admin --add-server hdb++es-srv/01 HdbEventSubscriber archiving/hdb++/eventsubscriber.01
	TANGO_HOST=${TANGO_HOST}  tango_admin --add-property archiving/hdb++/eventsubscriber.01 LibConfiguration "host=localhost,user=hdbpp,password=hdbpppassword,dbname=hdbpp,port=3306,libname=libhdb++mysql.so"
	@echo

	# List TANGO device servers
	TANGO_HOST=${TANGO_HOST}  tango_admin --server-list
	@echo



install_tango: get_sources
	# install prerequesites to compile Tango
	apt-get -yq install g++ libcos4-dev libmariadb-dev libmariadbclient-dev-compat libomniorb4-dev libzmq3-dev omniidl omniorb openjdk-8-jdk mariadb-server zlib1g-dev
	@echo

	# start mariadbserver, 'root' can login with 'mysql' without password
	systemctl enable mariadb
	systemctl start mariadb

	# extract the archive
	tar xf ${TANGO_VERSION}.tar.gz

	# Create Tango Makfile
	cd ${TANGO_VERSION} && ./configure --prefix=${TANGO_DIR} --enable-mariadb

	# Compile Tango
	cd ${TANGO_VERSION} && make
	@echo

	# Install Tango
	cd ${TANGO_VERSION} && make install
	@echo



run:
	./run.sh

#install_itango:
#	# install itango (ipython console) from distribution packages
#	apt-get -yq install python3-itango python-itango



uninstall:
	rm -fr ${TANGO_DIR}
