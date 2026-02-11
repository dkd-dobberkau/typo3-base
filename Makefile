# =============================================================================
# TYPO3 Docker Images — Makefile
# =============================================================================

PHP_VERSION ?= 8.3
TYPO3_VERSION ?= 13
REGISTRY ?= ghcr.io/dkd-dobberkau
HTTP_PORT ?= 8080

.PHONY: help build-base build-demo build-all demo up down clean test

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ---------------------------------------------------------------------------
# Build
# ---------------------------------------------------------------------------

build-base: ## Build the base image
	docker build -f Dockerfile.base \
		-t $(REGISTRY)/base:$(PHP_VERSION)-nginx \
		--build-arg PHP_VERSION=$(PHP_VERSION) \
		.

build-demo: ## Build the demo image (requires base)
	docker build -f Dockerfile.demo \
		-t $(REGISTRY)/demo:$(TYPO3_VERSION)-php$(PHP_VERSION) \
		-t $(REGISTRY)/demo:$(TYPO3_VERSION) \
		--build-arg PHP_VERSION=$(PHP_VERSION) \
		--build-arg TYPO3_VERSION=$(TYPO3_VERSION) \
		.

build-all: build-base build-demo ## Build both images

# ---------------------------------------------------------------------------
# Build Matrix (all combinations)
# ---------------------------------------------------------------------------

matrix: ## Build the full matrix (all PHP + TYPO3 versions)
	@echo "=== Building Base Images ==="
	$(MAKE) build-base PHP_VERSION=8.2
	$(MAKE) build-base PHP_VERSION=8.3
	$(MAKE) build-base PHP_VERSION=8.4
	@echo "=== Building Demo Images ==="
	$(MAKE) build-demo PHP_VERSION=8.2 TYPO3_VERSION=13
	$(MAKE) build-demo PHP_VERSION=8.3 TYPO3_VERSION=13
	$(MAKE) build-demo PHP_VERSION=8.4 TYPO3_VERSION=13
	$(MAKE) build-demo PHP_VERSION=8.3 TYPO3_VERSION=14
	$(MAKE) build-demo PHP_VERSION=8.4 TYPO3_VERSION=14

# ---------------------------------------------------------------------------
# Run
# ---------------------------------------------------------------------------

demo: build-all ## Build and start the demo
	PHP_VERSION=$(PHP_VERSION) TYPO3_VERSION=$(TYPO3_VERSION) HTTP_PORT=$(HTTP_PORT) \
		docker compose -f docker-compose.demo.yml up --build

up: ## Start demo (without rebuild)
	HTTP_PORT=$(HTTP_PORT) docker compose -f docker-compose.demo.yml up -d

down: ## Stop demo
	docker compose -f docker-compose.demo.yml down

# ---------------------------------------------------------------------------
# Test
# ---------------------------------------------------------------------------

test: build-base ## Run smoke tests on base image
	@echo "=== Testing PHP extensions ==="
	docker run --rm --entrypoint php $(REGISTRY)/base:$(PHP_VERSION)-nginx -m | grep -q gd && echo "✓ gd"
	docker run --rm --entrypoint php $(REGISTRY)/base:$(PHP_VERSION)-nginx -m | grep -q intl && echo "✓ intl"
	docker run --rm --entrypoint php $(REGISTRY)/base:$(PHP_VERSION)-nginx -m | grep -qi opcache && echo "✓ opcache"
	docker run --rm --entrypoint php $(REGISTRY)/base:$(PHP_VERSION)-nginx -m | grep -q mysqli && echo "✓ mysqli"
	docker run --rm --entrypoint php $(REGISTRY)/base:$(PHP_VERSION)-nginx -m | grep -q pdo_mysql && echo "✓ pdo_mysql"
	docker run --rm --entrypoint php $(REGISTRY)/base:$(PHP_VERSION)-nginx -m | grep -q pdo_pgsql && echo "✓ pdo_pgsql"
	docker run --rm --entrypoint php $(REGISTRY)/base:$(PHP_VERSION)-nginx -m | grep -q redis && echo "✓ redis"
	docker run --rm --entrypoint php $(REGISTRY)/base:$(PHP_VERSION)-nginx -m | grep -q apcu && echo "✓ apcu"
	docker run --rm --entrypoint php $(REGISTRY)/base:$(PHP_VERSION)-nginx -m | grep -q zip && echo "✓ zip"
	@echo "=== Testing Composer ==="
	docker run --rm --entrypoint composer $(REGISTRY)/base:$(PHP_VERSION)-nginx --version
	@echo "=== Testing Nginx ==="
	docker run --rm --entrypoint sh $(REGISTRY)/base:$(PHP_VERSION)-nginx -c 'sed -i "s|\$$TYPO3_CONTEXT|Production|g" /etc/nginx/http.d/default.conf && nginx -t'
	@echo "=== Testing GraphicsMagick ==="
	docker run --rm --entrypoint gm $(REGISTRY)/base:$(PHP_VERSION)-nginx version | head -1
	@echo "=== All tests passed ==="

# ---------------------------------------------------------------------------
# Cleanup
# ---------------------------------------------------------------------------

clean: ## Remove all built images and volumes
	docker compose -f docker-compose.demo.yml down -v --rmi local 2>/dev/null || true
	docker rmi $(REGISTRY)/base:$(PHP_VERSION)-nginx 2>/dev/null || true
	docker rmi $(REGISTRY)/demo:$(TYPO3_VERSION)-php$(PHP_VERSION) 2>/dev/null || true
	docker rmi $(REGISTRY)/demo:$(TYPO3_VERSION) 2>/dev/null || true
