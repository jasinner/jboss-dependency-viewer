#!/bin/bash

if [ -z $1 ] || [ -z $2 ] ; then
	echo 'Usage deploy.sh <PRODUCT_ALIAS> <DOWNLOAD_URL>'
	exit 1
fi

DOCUMENT_ROOT=/opt/rh/httpd24/root/var/www/html

docker run -Pd --name jboss-dependency-viewer registry.access.redhat.com/rhscl/httpd-24-rhel7 
docker cp framework jboss-dependency-viewer:$DOCUMENT_ROOT
mkdir /tmp/frontend_path
sh add_product.sh $1 $2 /tmp/frontend_path
docker cp /tmp/frontend_path/. jboss-dependency-viewer:$DOCUMENT_ROOT

