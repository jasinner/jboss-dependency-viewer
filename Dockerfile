FROM registry.access.redhat.com/rhscl/httpd-24-rhel7
MAINTAINER jshepher@redhat.com
ENV FRONTEND_PATH /opt/rh/httpd24/root/var/www/html
RUN yum install -y unzip wget curl
RUN yum -y update
WORKDIR $FRONTEND_PATH
COPY framework ./framework/sigma/
WORKDIR /opt/rh/
ADD add_dependency.sh add_module.sh add_product.sh ./
ADD indextemplate*.txt ./
ADD graph.html ./
ADD shared.js ./
RUN /opt/rh/add_product.sh EAP7 http://download.englab.bne.redhat.com/released/JBEAP-7/7.0.0/jboss-eap-7.0.0.zip
