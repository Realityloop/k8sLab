# TARGETS

# Proxy service.
kubectl-proxy: kubectl-proxy-down
	$(call local_ip)
	@$(call title,Starting kubectl proxy daemon)
	@$(call exec,daemon -F $(shell pwd)/kubectl-proxy.pid -n kubectl-proxy -X kubectl proxy -- --port=8443 --address=$(LOCAL_IP) --accept-hosts="^*$$")

kubectl-proxy-down:
ifneq (,$(wildcard ./kubectl-proxy.pid))
	@$(call title,Stopping kubectl proxy)
	@$(call exec,kill -9 $(shell expr $$(cat kubectl-proxy.pid) + 1))
endif