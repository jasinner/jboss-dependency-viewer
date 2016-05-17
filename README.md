## How to Run in Docker

- Use the Dockerfile in the 'install' directory to create a HTTPD image with the Sigma JS Framework installed

   `docker build -t dependency-viewer install/`

- Run the dependency-viewer image, exposing its HTTPD ports to the host

   `docker run -d -P --name dependency-viewer dependency-viewer`

- Use the provided Dockerfile to create an image called 'dependency-viewer-builder' which adds new products

   `docker build -t dependency-viewer-builder`

- Use the 'dependency-viewer-builder' container to add products to the 'dependency-viewer' container

   `docker run --volumes-from dependency-viewer dependency-viewer-builder EAP7 http://download.devel.redhat.com//devel/candidates/JBEAP/JBEAP-7.0.0/jboss-eap-7.0.0.zip`