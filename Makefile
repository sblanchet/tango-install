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

TANGO_SRC_URL:=ftp://ftp.esrf.eu/pub/cs/tango/${TANGO_VERSION}.tar.gz

# Release tag for libhdbpp
LIB_HDBPP_TAG:=tags/v1.0.0

# Release tag for HDB++ mysql backend
LIB_HDBPP_MYSQL_TAG:=tags/v1.1.0

# Release tag for HDB++ Configuration Manager
HDBPP_CM_TAG:=tags/v1.0.0

# Release tag for HDB++ Event Subscriber
HDBPP_ES_TAG:=tags/v1.0.1

# Release tag for HDB++ Configurator
HDBPP_CONFIGURATOR_TAG:=tags/hdbpp-configurator-3.5

# Release tag for Java HDB++ Extraction Library
LIB_HDBPP_EXTRACTION_JAVA_TAG:=tags/libhdbpp-java-1.21

# Release tag for HDB++ Viewer
HDBPP_VIEWER_TAG:=70d61cc38d0e844b196fecdb92db65fdf22f222f




################ END OF USER SETTINGS SECTION

## After this line there is no user settings you can edit

PATH:=/sbin:/usr/sbin:/usr/bin:/bin:${TANGO_DIR}/bin

TANGO_JAVA:=${TANGO_DIR}/share/java

# default target
default: help


.PHONY: \
    get_sources     \
    help            \
    install_prereq \
    install_tango   \
    install_itango  \
    install_hdbpp   \
    run             \




install_prereq:
# disable IPv6 version of localhost
# remove line ::1 localhost in /etc/hosts, because it creates trouble
	sed -i -e 's/^::1 /#::1 /' /etc/hosts

# install debian prerequesites
	apt-get -q update
	apt-get -yq install git wget cmake make g++

# install prerequesites to compile Tango
	apt-get -yq install automake libtool \
            libmariadb-dev libmariadbclient-dev-compat mariadb-server \
            libcos4-dev libomniorb4-dev libzmq3-dev omniidl omniorb openjdk-8-jdk \
            zlib1g-dev \
            maven      \
# install dependencies for hdbpp-viewer
	apt-get -yq install libjcalendar-java jython

	@echo

	# start mariadbserver, 'root' can login with 'mysql' without password
	systemctl enable mariadb
	systemctl start mariadb



help:
	@echo "Automatic TANGO/HDB++ installation"
	@echo
	@echo "make install_prereq: install prerequesites"
	@echo "make get_sources   : download source code without compiling"
	@echo "make help          : display this help message"
	@echo "make install_tango : install TANGO"
	@echo "make install_libhdbpp : install LibHDB++"
	@echo "make install_hdbpp : install HDB++"
	@echo "make install       : install TANGO and HDB++"
	@echo "make run           : run Tango and its applications"



install: install_tango install_itango install_hdbpp
	make run


install_libhdbpp:
	# switch to release tag
	cd libhdbpp && git checkout ${LIB_HDBPP_TAG}
	mkdir -p libhdbpp/build
	cd libhdbpp/build && cmake ..                       \
            -DCMAKE_INSTALL_PREFIX=${TANGO_DIR}             \
            -DCMAKE_INCLUDE_PATH=${TANGO_DIR}/include/tango \
            -DHDBPP_DEV_INSTALL=ON                          \

	make -C libhdbpp/build
	make -C libhdbpp/build install

install_hdbpp: get_sources  install_libhdbpp
	# Compile HDB++ MySQL backend
	# switch to release tag
	cd libhdbpp-mysql && git checkout ${LIB_HDBPP_MYSQL_TAG}
	# compile libhdbpp-mysql
	export LIBHDBPP_INC=${TANGO_DIR}/include && \
           export TANGO_INC=${TANGO_DIR}/include/tango && \
           make -C libhdbpp-mysql


	# install library
	install -m644 -oroot -groot libhdbpp-mysql/lib/* ${TANGO_DIR}/lib/


	# Create SQL databases

	# Create database and user for HDB++
	./create_hdb++_db_user.sh
	# Create tables

	# execute SQL scripts: 'root' is expected to be able to connect to mysql without password
	cat libhdbpp-mysql/etc/*.sql | mysql -uroot hdbpp
	@echo

	# Compile HDB++ Configuration Manager
	# switch to release tag
	cd hdbpp-cm && git checkout ${HDBPP_CM_TAG}
	export TANGO_DIR=${TANGO_DIR} && \
          export TANGO_INC=${TANGO_DIR}/include/tango && \
          export TANGO_LIB=${TANGO_DIR}/lib && \
          export LIBHDBPP_INC=${TANGO_DIR}/include && \
          make -C hdbpp-cm
	install -m755 -oroot -groot hdbpp-cm/bin/* ${TANGO_DIR}/bin/


	# Compile HDB++ Event Subscriber
	# switch to release tag
	cd hdbpp-es && git checkout ${HDBPP_ES_TAG}
	export TANGO_DIR=${TANGO_DIR} && \
          export TANGO_INC=${TANGO_DIR}/include/tango && \
          export TANGO_LIB=${TANGO_DIR}/lib && \
          export LIBHDBPP_INC=${TANGO_DIR}/include && \
          make -C hdbpp-es
	install -m755 -oroot -groot hdbpp-es/bin/* ${TANGO_DIR}/bin/
	@echo


	# Compilation of hdbpp-configurator
	# switch to release tag
	cd hdbpp-configurator && git checkout ${HDBPP_CONFIGURATOR_TAG}
	# Compile HDB++ Configurator GUI with maven
	cd hdbpp-configurator && mvn package
	install -m755 -oroot -groot -d ${TANGO_JAVA}
	install -m644 -oroot -groot \
            hdbpp-configurator/target/hdbpp-configurator*.jar \
            ${TANGO_JAVA}/hdbpp-configurator.jar
	install -m755 -oroot -groot hdb-configurator.sh ${TANGO_DIR}/bin


	# Compile Java HDB++ Extraction Library
	# switch to release tag
	cd libhdbpp-extraction-java && git checkout ${LIB_HDBPP_EXTRACTION_JAVA_TAG}
	# Compile Java HDB++ Extraction Library with maven
	cd libhdbpp-extraction-java && mvn package
	install -m644 -oroot -groot \
            libhdbpp-extraction-java/target/libhdbpp-java*.jar \
            ${TANGO_JAVA}/libhdbpp-java.jar


	# Compile HDB Viewer
	# switch to release tag
	cd hdbpp-viewer && git checkout ${HDBPP_VIEWER_TAG}
	cd hdbpp-viewer && mvn package
	install -m644 -oroot -groot hdbpp-viewer/target/jhdbviewer*.jar ${TANGO_JAVA}/jhdbviewer.jar
	install -m755 -oroot -groot hdb-viewer.sh ${TANGO_DIR}/bin

	# Link libraries for HDB Viewer
	ln -sf /usr/share/java/jcalendar.jar ${TANGO_JAVA}/jcalendar.jar
	ln -sf /usr/share/java/jython.jar ${TANGO_JAVA}/jython.jar


	# Start tango server to use tango_admin later
	${TANGO_DIR}/bin/tango start
	# wait DataBaseds is up
	sleep 5

	# Declare TANGO device server: hdb++cm-srv and its properties
	TANGO_HOST=${TANGO_HOST}  tango_admin --add-server hdb++cm-srv/01 HdbConfigurationManager archiving/hdb++/confmanager.01
	# use 127.0.0.1 to force IPv4 version of localhost,
	# because hdb++cm-srv dislikes resolving IPv6 address "::1"
	TANGO_HOST=${TANGO_HOST}  tango_admin --add-property archiving/hdb++/confmanager.01 ArchiverList tango://${TANGO_HOST}/archiving/hdb++/eventsubscriber.01
	TANGO_HOST=${TANGO_HOST}  tango_admin --add-property archiving/hdb++/confmanager.01 LibConfiguration "host=127.0.0.1,user=hdbpp,password=hdbpppassword,dbname=hdbpp,port=3306,libname=libhdb++mysql.so"
	@echo

	# Declare TANGO device server: hdb++cm-srv and its properties
	TANGO_HOST=${TANGO_HOST}  tango_admin --add-server hdb++es-srv/01 HdbEventSubscriber archiving/hdb++/eventsubscriber.01
	TANGO_HOST=${TANGO_HOST}  tango_admin --add-property archiving/hdb++/eventsubscriber.01 LibConfiguration "host=127.0.0.1,user=hdbpp,password=hdbpppassword,dbname=hdbpp,port=3306,libname=libhdb++mysql.so"
	@echo

	# List TANGO device servers
	TANGO_HOST=${TANGO_HOST}  tango_admin --server-list
	@echo



install_tango: install_prereq
#	Git repository for Tango does not compile. Download .tar.gz from ftp.esrf.fr instead
	[ -e ${TANGO_VERSION}.tar.gz ] || wget -q ftp://ftp.esrf.eu/pub/cs/tango/${TANGO_VERSION}.tar.gz -O ${TANGO_VERSION}.tar.gz
	@echo

	# extract the archive
	tar xf ${TANGO_VERSION}.tar.gz

	# Create Tango Makefile
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
