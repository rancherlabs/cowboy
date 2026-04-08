MACHINE := rancher

DEFAULT_PLATFORMS := linux/amd64,linux/arm64,darwin/arm64,darwin/amd64

TAG ?= dev
REPO ?= ghcr.io/rancherlabs
IMAGE ?= cowboy
IMAGE_NAME ?= $(REPO)/$(IMAGE):$(TAG)

BUILDX_ARGS ?=

.PHONY: buildx-machine
buildx-machine:
	@docker buildx ls | grep $(MACHINE) || \
	 docker buildx create --name=$(MACHINE) --platform=$(DEFAULT_PLATFORMS)

.PHONY: push-image
push-image: buildx-machine
	docker buildx build \
	 $(IID_FILE_FLAG) \
	 $(BUILDX_ARGS) \
	 --platform=$(TARGET_PLATFORMS) \
	 --tag $(IMAGE_NAME) \
	 --push \
	 .

.PHONY: push-prime-image
push-prime-image:
	BUILDX_ARGS="--sbom=true --attest type=provenance,mode=max" \
	$(MAKE) push-image
