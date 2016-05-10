FROM registry.access.redhat.com/rhel7
MAINTAINER jshepher@redhat.com
ENV FRONTEND_PATH /opt/rh/httpd24/root/var/www/html 
RUN yum -y update && yum -y install wget unzip
WORKDIR /opt/rh/
ADD add_dependency.sh add_module.sh add_product.sh ./
ADD indextemplate*.txt ./
ADD graph.html ./
ADD shared.js ./
ENTRYPOINT ["/opt/rh/add_product.sh"] 
