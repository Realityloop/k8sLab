# TARGETS

minikube-clean: minikube-down
	@$(call title,Minikube: Deleting cluster)
	@$(call exec,minikube delete)

minikube-down:
	@$(call title,Stopping Minikube service)
	@$(if $(shell minikube status | grep -o 'minikube: Running'), \
		@$(call exec,minikube stop), \
		@$(call print,Minikube is not running.) \
	)

minikube-start:
	@$(call title,Starting Minikube service)
	@$(if $(shell minikube status | grep -o 'minikube: Running'), \
		@$(call print,Minikube is already running.), \
		@$(call exec,minikube start --memory 8192 --vm-driver hyperkit) \
	)

minikube-ready:
	@$(call title,Waiting for Minikube to get ready)
	@while [[ "$$(kubectl get serviceaccounts | grep 'default')" == "" ]]; do \
		sleep 1; \
	done
	@$(call print,Minikube is ready.)

minikube-reset: minikube-clean minikube-up

minikube-up: minikube-start minikube-ready
