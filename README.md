## How to Run in Docker

- Run a HTTPD container called 'dependency-viewer', eg.

  docker run -d -P --name dependency-viewer registry.access.redhat.com/rhscl/httpd-24-rhel7

- Copy the Sigma Framework into the 'dependency-viewer' container:

  docker cp framework/ dependency-viewer:/opt/rh/httpd24/root/var/www/html/

- Use the provided Dockerfile to create an image called 'dependency-viewer-builder' which adds new products

   docker build -t dependency-viewer-builder .

- Use the 'dependency-viewer-builder' container to add products to the 'dependency-viewer' container

   docker run --volumes-from dependency-viewer dependency-viewer-builder EAP7 http://download.devel.redhat.com//devel/candidates/JBEAP/JBEAP-7.0.0/jboss-eap-7.0.0.zip
