# k8sLab

k8sLab is a local Kubernetes cluster using Minikube and tailored for GitLab
Auto-DevOps based development.

## Installation

> `make install`

The above command will ensure that all the following dependenices are present
or prompt to install them otherwise:

- [Homebrew](https://brew.sh)
- [daemon](http://libslack.org/daemon/)
- [docker](https://www.docker.com/)
- [hyperkit driver](https://github.com/machine-drivers/docker-machine-driver-hyperkit)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [Minikube](https://kubernetes.io/docs/setup/minikube/)
- [ngrok](https://ngrok.com/)
- [jq](https://stedolan.github.io/jq/)

## Running

Once everything is installed, simply run the following command to start the
services:

> `make up`

Remember to stop the services once you are done with the following command:

> `make down`
