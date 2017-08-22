#!/bin/bash

# Functions
ok() { echo -e '\e[32m'$1'\e[m'; } # Green

EXPECTED_ARGS=3
E_BADARGS=65
MYSQL=`which mysql`
CREATE_TABLES_FILE=`dirname $0`"/create_hdb++_mysql.sql"

if [ $# -ne $EXPECTED_ARGS ]
then
	if [ $# -ne 0 ]
	then
		echo "Usage: $0 dbname dbuser dbpass"
		echo "Or using defaults dbname=hdbpp dbuser=hdbpp, dbpassword=hdbpppassword: $0"
		exit $E_BADARGS
	else
		echo "Assuming defaults: dbname=hdbpp dbuser=hdbpp, dbpassword=hdbpppassword"
		DB_NAME=hdbpp
		DB_USER=hdbpp
		DB_PASSWORD=hdbpppassword
	fi
else
	DB_NAME=$1
	DB_USER=$2
	DB_PASSWORD=$3
fi

Q0="DROP DATABASE IF EXISTS ${DB_NAME};"
Q1="CREATE DATABASE ${DB_NAME} COLLATE='latin1_bin';"
Q2="GRANT ALL ON *.* TO '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';"
Q3="FLUSH PRIVILEGES;"
SQL="${Q0}${Q1}${Q2}${Q3};"

echo "Create database '${DB_NAME}' and user '${DB_USER}'"
$MYSQL -uroot -e "$SQL"
