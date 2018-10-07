.DEFAULT_GOAL := help
.PHONY: help install info up dashboard brew-install jq-install kubectl-install kubectl-proxy minikube-start minikube-install virtualbox-install

# TARGETS

## Display this help message.
help:
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

## k8sLab: Install
install: brew-install virtualbox-install kubectl-install minikube-install minikube-start jq-install

## k8sLab: Info for GitLab
info:
	@$(call title,k8sLab details for GitLab)

	@$(call print,${YELLOW}Kubernetes cluster name:${RESET} k8sLab)
	@$(call print,${YELLOW}Environment scope:${RESET} *)
	@$(call print,${YELLOW}API URL:${RESET} [See README.md])

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
up: minikube-start info kubectl-proxy

## k8sLab: Open k8s dashboard in default browser.
dashboard:
	@$(call title,Launching k8s dashboard)
	@$(call exec,minikube dashboard)

brew-install:
	@$(call install,Homebrew,brew,curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install | ruby)

	@$(call title,Installing Homebrew Cask)
	@$(call exec,brew tap caskroom/cask)

jq-install:
	@$(call install,jq,jq,brew install jq)

kubectl-install:
	@$(call install,kubectl,kubectl,brew install kubectl)

## kubectl: Proxy
kubectl-proxy:
	$(call local_ip)
	@$(call title,Starting kubectl proxy)
	@$(call exec,kubectl proxy --port=8443 --address=$(LOCAL_IP) --accept-hosts="^*$$")

## Minikube: Start service
minikube-start:
	@$(call title,Starting Minikube service)
	@$(if $(shell minikube status | grep -o 'minikube: Running'), \
		@$(call print,Minikube is already running.), \
		@$(call exec,minikube start --extra-config=apiserver.admission-control="") \
	)

minikube-install:
	@$(call install,Minikube,minikube,brew cask install minikube)

	@$(call title,Minikube: Enable ingress)
	@$(call exec,minikube addons enable ingress)

virtualbox-install:
	@$(call install,VirtualBox,virtualbox,brew cask install virtualbox)



# VARIABLES.

TARGET_MAX_CHAR_NUM := 32

## Colors for output text.

GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)



# FUNCTIONS.

define api_token
	@$(eval SECRET := $(shell kubectl get serviceaccount default -o json | jq -r '.secrets[].name'))
	@$(eval TOKEN := $(shell kubectl get secret $(SECRET) -o yaml | grep "token:" | awk {'print $$2'} | base64 -D))
endef

define confirm
	echo "${1} [y/N] " && read ans && [ $${ans:-N} == y ]
endef

## Print a line break to screen.
define break
	printf "\n"
endef

## Print a command to screen.
define command
	printf "> ${YELLOW}${subst ",',${1}}${RESET}\n\n"
endef

## Execute command and print to screen.
define exec
	printf "$$ ${YELLOW}${subst ",',${1}}${RESET}\n\n" && $1
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

define local_ip
	$(eval LOCAL_IP := $(shell ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $$2; exit}'))
endef

## Print text to screen.
define print
	printf "${1}\n\n"
endef

## Print a title/heading to screen.
define title
	printf "\n\n${GREEN}>>> ${1}...${RESET}\n\n\n"
endef


# https://stackoverflow.com/a/6273809/1826109
%:
	@:
