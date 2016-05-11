FROM registry.access.redhat.com/rhscl/httpd-24-rhel7
MAINTAINER jshepher@redhat.com
ENV FRONTEND_PATH /opt/rh/httpd24/root/var/www/html 
#RUN yum -y update
WORKDIR $FRONTEND_PATH
COPY . ./ 
