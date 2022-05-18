.PHONY: yaml-lint

yaml-lint:
	@echo "---------yamllint----------"
	yamllint flaskapi-secrets.yml
	

docker-lint:
	@echo "---------docker lint----------"
	docker run --rm -i hadolint/hadolint < Dockerfile

test: docker-lint yaml-lint


native:
	@echo "---------kubectl yaml check -----------"
	kubectl --dry-run=server apply -f yamls/

helm:
	@echo "---------helm yaml check -----------"
	helm install --dry-run --debug test helm
	helm template helm | kubectl apply --dry-run=server -f -

kustomize:
	@echo "---------kustomize yaml check -----------"
	@echo "--------- base -----------"
	kubectl --dry-run=server apply -k kustomize/base/
	@echo "--------- production -----------"
	kubectl --dry-run=server apply -k kustomize/overlays/production/
	@echo "--------- staging -----------"
	kubectl --dry-run=server apply -k kustomize/overlays/staging/

k8s-yaml: native helm kustomize

bats:
	@echo "---------bats check-----------"
	sudo TYPE=${TYPE} bats -t tests/test.bats

k8s-test: k8s-yaml  bats
