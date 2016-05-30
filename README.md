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

	./deploy.sh EAP6 http://download.bne.redhat.com/released/JBEAP-6/6.4.8/jboss-eap-6.4.8-full-build.zip

 - Creates a Docker container with the name 'jboss-dependency-viewer'. 
 - The container uses a Docker volume 
 - Get the port for the container using 'docker inspect jboss-dependency-viewer'
 - View the application at http://locahost:<port>/
