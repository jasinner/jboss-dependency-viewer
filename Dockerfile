FROM registry.access.redhat.com/rhel7
MAINTAINER jshepher@redhat.com
ADD add_dependency.sh add_module.sh add_product.sh /opt/rh/
ADD indextemplate*.txt /opt/rh/
ADD graph.html /opt/rh/
ADD visualcatalogue.cfg /opt/rh/
WORKDIR /opt/rh/
ENTRYPOINT ["add_product.sh"] 
