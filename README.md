## Overview

JBoss dependency viewer is a visual catalogue of JBoss modules and their dependencies on each other. It represents modules, highlighting extensions, of different versions of JBoss that depend on a particular (vulnerable) library or module, showing their dependencies on each other as a directed graph visualised on a web page.  

## Installation

 - Download the contents of the repository

 - Export the path where html files will be located to $FRONTEND_PATH environment variable

 - Download sigma.js framework to the same folder

## Usage

To add a JBoss version to the system, execute the add_product.sh script with two parameters:

1. Short name that you want to use in the drop-down list

2. Download path of the distribution zip file

To remove a version, execute the same script with product short name as a parameter.

## How to Run in Docker

- Use the Dockerfile in the 'install' directory to create a HTTPD image with the Sigma JS Framework installed

   `docker build -t dependency-viewer install/`

- Run the dependency-viewer image, exposing its HTTPD ports to the host

   `docker run -d -P --name dependency-viewer dependency-viewer`

- Use the provided Dockerfile to create an image called 'dependency-viewer-builder' which adds new products

   `docker build -t dependency-viewer-builder`

- Use the 'dependency-viewer-builder' container to add products to the 'dependency-viewer' container

   `docker run --volumes-from dependency-viewer dependency-viewer-builder EAP7 http://download.devel.redhat.com//devel/candidates/JBEAP/JBEAP-7.0.0/jboss-eap-7.0.0.zip`