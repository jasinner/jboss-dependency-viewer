#!/bin/bash

export DOCUMENT_ROOT=/opt/rh/httpd24/root/var/www/html

echo `docker ps $1`
docker cp framework $1:$DOCUMENT_ROOT
mkdir /tmp/frontend_path/
export FRONTEND_PATH
add_product.sh $2 $3 $4

