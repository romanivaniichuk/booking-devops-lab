SHELL := /bin/bash

CHART := ./helm/booking
DEV_VALUES := ./helm/booking/values-dev.yaml
PROD_VALUES := ./helm/booking/values-prod.yaml

DEV_CLUSTER := booking-dev
NAMESPACE := booking

PROD_KUBECONFIG ?= $(HOME)/.kube/booking-k3s.yaml
IMAGE_TAG ?= $(shell git rev-parse origin/main)
TLS_ISSUER ?= booking-letsencrypt-staging

.PHONY: dev test build deploy destroy

dev:
	@k3d cluster list | awk 'NR > 1 {print $$1}' | grep -qx "$(DEV_CLUSTER)" || \
		k3d cluster create $(DEV_CLUSTER) --port "8080:80@loadbalancer"
	docker build -t booking-devops-lab:dev .
	k3d image import booking-devops-lab:dev -c $(DEV_CLUSTER)
	helm upgrade --install booking $(CHART) \
		-f $(DEV_VALUES) \
		-n $(NAMESPACE) \
		--create-namespace \
		--wait
	kubectl rollout restart deployment/booking-app -n $(NAMESPACE)
	kubectl rollout status deployment/booking-app -n $(NAMESPACE)

test:
	pytest -q
	helm lint $(CHART) -f $(DEV_VALUES)
	helm template booking $(CHART) -f $(DEV_VALUES) > /dev/null

build:
	docker build -t booking-devops-lab:dev .

deploy:
	@test -f .env || (echo ".env is missing"; exit 1)
	@test -f "$(PROD_KUBECONFIG)" || (echo "Production kubeconfig is missing"; exit 1)
	@set -a; source .env; set +a; \
		test -n "$$POSTGRES_DB"; \
		test -n "$$POSTGRES_USER"; \
		test -n "$$POSTGRES_PASSWORD"; \
		test -n "$$ACME_EMAIL"; \
		SERVER_IP=$$(cd infra/terraform && terraform output -raw server_public_ip); \
		BOOKING_HOST=$$(echo "$$SERVER_IP" | tr '.' '-').sslip.io; \
		KUBECONFIG="$(PROD_KUBECONFIG)" helm upgrade --install booking $(CHART) \
			-f $(PROD_VALUES) \
			-n $(NAMESPACE) \
			--create-namespace \
			--set-string image.tag="$(IMAGE_TAG)" \
			--set-string ingress.host="$$BOOKING_HOST" \
			--set-string tls.clusterIssuer="$(TLS_ISSUER)" \
			--set-string tls.email="$$ACME_EMAIL" \
			--set-string postgres.database="$$POSTGRES_DB" \
			--set-string postgres.user="$$POSTGRES_USER" \
			--set-string postgres.password="$$POSTGRES_PASSWORD" \
			--wait \
			--timeout 5m

destroy:
	@read -p "Type destroy to uninstall booking from Hetzner: " answer; \
		test "$$answer" = "destroy"
	KUBECONFIG="$(PROD_KUBECONFIG)" helm uninstall booking -n $(NAMESPACE)
