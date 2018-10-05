# k8sLab

k8sLab is a local Kubernetes cluster using Minikube and tailored for GitLab
based development.

## Installation

> `make install`

The above command will ensure that all the following dependenices are present
or prompt to install them otherwise:

- [Homebrew](https://brew.sh)
- [VirtualBox](https://www.virtualbox.org)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [Minikube](https://kubernetes.io/docs/setup/minikube/)
- [jq](https://stedolan.github.io/jq/)

Once all dependencies are installed and configured, the services will begin
and your access details will be output to the terminal.

`kubectl proxy` will stay active until you manually terminate the command
(CTRL-C).

### API URL / Port forwarding

For GitLab to connect to k8sLab you will need to setup portforwarding of your
external IP to your local machine IP on TCP Port 8443.


## Issues

- Installing Helm Tiller:

  > Error: error installing: deployments.extensions is forbidden: User "system:serviceaccount:gitlab-managed-apps:default" cannot create deployments.extensions in the namespace "gitlab-managed-apps"
