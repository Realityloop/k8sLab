include mk/*.mk

.DEFAULT_GOAL := help
.PHONY: help install info up dashboard brew-install jq-install kubectl-install kubectl-proxy virtualbox-install

# TARGETS

## k8sLab: Install
install: dependencies-install minikube-up
	@$(call title,Welcome to k8sLab)
	@$(call print,To start using run the following command:)
	@$(call command,make up)

dependencies-install:
	@$(call install,Homebrew,brew,curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install | ruby)

	@$(call install,Daemon,daemon,brew install daemon)

	@$(call install,Docker,docker,brew cask install docker)

	@$(call install,Hyperkit,docker-machine-driver-hyperkit,brew cask install docker-machine-driver-hyperkit)

	@$(call install,kubectl,kubectl,brew install kubectl)

	@$(call install,Minikube,minikube,brew cask install minikube)

	@$(call install,ngrok,ngrok,brew install ngrok)

	@$(call install,jq,jq,brew install jq)

## k8sLab: Info for GitLab
info:
	@$(call title,k8sLab details for GitLab)

	@$(call print,${YELLOW}Kubernetes cluster name:${RESET} k8sLab)
	@$(call print,${YELLOW}Environment scope:${RESET} *)

	@$(call ngrok_http)
	@$(call print,${YELLOW}API URL:${RESET} $(NGROK_HTTP))

	@$(call print,${YELLOW}CA Certificate:${RESET})
	@cat $(HOME)/.minikube/ca.crt
	@$(call break)

	@$(call api_token)
	@$(call print,${YELLOW}Token:${RESET})
	@$(call print,$(TOKEN))

	@$(call print,${YELLOW}Project namespace:${RESET} default)

## k8sLab: Prints k8s CA Certificate to screen
info-crt:
	@cat $(HOME)/.minikube/ca.crt

## k8sLab: Prints k8s access token to screen
info-token:
	@$(call api_token)
	@echo $(TOKEN)

## k8sLab: Start services
up: minikube-up kubectl-proxy ngrok-up info

## k8sLab: Stop services
down: ngrok-down kubectl-proxy-down minikube-down

## k8sLab: Reset minikube and start services
reset: clean up

## k8sLab: Delete minikube cluster.
clean: down minikube-clean

## k8sLab: Open k8s dashboard in default browser.
dashboard:
	@$(call title,Launching k8s dashboard)
	@$(call exec,minikube dashboard)


# FUNCTIONS.

define api_token
	@$(eval SECRET := $(shell kubectl get serviceaccount default -o json | jq -r '.secrets[].name'))
	@$(eval TOKEN := $(shell kubectl get secret $(SECRET) -o yaml | grep "token:" | awk {'print $$2'} | base64 -D))
endef

define local_ip
	$(eval LOCAL_IP := $(shell ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $$2; exit}'))
endef

## Checks for dependency, and prompts to install if missing.
define install
	$(call title,Dependency check: $1)
	$(if $(shell which $2), \
		$(call print,$1 is installed.), \
		@$(call print,$1 is not installed.) && \
		$(call print,The following command will be used to install it:) && \
		$(call command,$3) && \
		$(call break) && \
		$(call confirm,Would you like you proceed?) && \
		$(call title,Installing $1) && \
		$(call exec,$3)
	)
endef



# https://stackoverflow.com/a/6273809/1826109
%:
	@:
