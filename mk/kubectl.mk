# TARGETS

# Proxy service.
kubectl-proxy:
	$(call local_ip)
	@$(call title,Starting kubectl proxy)
	@$(call exec,kubectl proxy --port=8443 --address=$(LOCAL_IP) --accept-hosts="^*$$")
