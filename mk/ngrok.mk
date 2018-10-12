# TARGETS

ngrok-up:
	$(call local_ip)
	@$(call title,Starting ngrok daemon)
	@$(call exec,daemon -F $(shell pwd)/ngrok.pid -n ngrok -X ngrok http $(LOCAL_IP):8443)

	$(call local_ip)
	@while [[ "$$(curl -s localhost:4040/api/tunnels | jq '.tunnels[] | select(.config.addr == "$(LOCAL_IP):8443")')" == "" ]]; do \
		sleep 1; \
	done

ngrok-down:
ifeq (,$(wildcard ./ngrok.pid))
	@$(call title,Stopping ngrok dameon)
	@$(call exec,killall ngrok | true)
endif



# FUNCTIONS

define ngrok_http
	$(call local_ip)
	$(eval NGROK_HTTP := $(shell curl -s localhost:4040/api/tunnels | jq '.tunnels[] | select(.config.addr == "$(LOCAL_IP):8443") | select(.proto == "http") | .public_url'))
endef
