# =============================================================================
# TYPO3 Docker Images — Makefile
# =============================================================================

PHP_VERSION ?= 8.3
TYPO3_VERSION ?= 13
REGISTRY ?= ghcr.io/dkd-dobberkau
HTTP_PORT ?= 8080
HTTP_PORT_CONTRIB ?= 28080

.PHONY: help build-base build-base-fpm build-demo build-contrib build-all demo up down contrib-up contrib-down contrib-enter contrib-db-enter clean test test-fpm

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ---------------------------------------------------------------------------
# Build
# ---------------------------------------------------------------------------

build-base: ## Build the base image (nginx variant)
	docker build -f Dockerfile.base \
		--target nginx \
		-t $(REGISTRY)/base:$(PHP_VERSION)-nginx \
		--build-arg PHP_VERSION=$(PHP_VERSION) \
		.

build-base-fpm: ## Build the base image (fpm-only variant)
	docker build -f Dockerfile.base \
		--target fpm \
		-t $(REGISTRY)/base:$(PHP_VERSION)-fpm \
		--build-arg PHP_VERSION=$(PHP_VERSION) \
		.

build-demo: ## Build the demo image (requires base)
	docker build -f Dockerfile.demo \
		-t $(REGISTRY)/demo:$(TYPO3_VERSION)-php$(PHP_VERSION) \
		-t $(REGISTRY)/demo:$(TYPO3_VERSION) \
		--build-arg PHP_VERSION=$(PHP_VERSION) \
		--build-arg TYPO3_VERSION=$(TYPO3_VERSION) \
		.

build-contrib: build-base-fpm ## Build the contrib image (requires base fpm)
	docker build -f Dockerfile.contrib \
		-t $(REGISTRY)/contrib:$(PHP_VERSION) \
		--build-arg PHP_VERSION=$(PHP_VERSION) \
		.

build-all: build-base build-base-fpm build-demo build-contrib ## Build all images

# ---------------------------------------------------------------------------
# Build Matrix (all combinations)
# ---------------------------------------------------------------------------

matrix: ## Build the full matrix (all PHP + TYPO3 versions, both variants)
	@echo "=== Building Base Images (nginx) ==="
	$(MAKE) build-base PHP_VERSION=8.2
	$(MAKE) build-base PHP_VERSION=8.3
	$(MAKE) build-base PHP_VERSION=8.4
	@echo "=== Building Base Images (fpm) ==="
	$(MAKE) build-base-fpm PHP_VERSION=8.2
	$(MAKE) build-base-fpm PHP_VERSION=8.3
	$(MAKE) build-base-fpm PHP_VERSION=8.4
	@echo "=== Building Demo Images ==="
	$(MAKE) build-demo PHP_VERSION=8.2 TYPO3_VERSION=13
	$(MAKE) build-demo PHP_VERSION=8.3 TYPO3_VERSION=13
	$(MAKE) build-demo PHP_VERSION=8.4 TYPO3_VERSION=13
	$(MAKE) build-demo PHP_VERSION=8.3 TYPO3_VERSION=14
	$(MAKE) build-demo PHP_VERSION=8.4 TYPO3_VERSION=14
	@echo "=== Building Contrib Images ==="
	$(MAKE) build-contrib PHP_VERSION=8.2
	$(MAKE) build-contrib PHP_VERSION=8.3
	$(MAKE) build-contrib PHP_VERSION=8.4

# ---------------------------------------------------------------------------
# Run
# ---------------------------------------------------------------------------

demo: build-all ## Build and start the demo
	PHP_VERSION=$(PHP_VERSION) TYPO3_VERSION=$(TYPO3_VERSION) HTTP_PORT=$(HTTP_PORT) \
		docker compose -f docker-compose.demo.yml up --build

contrib: build-contrib ## Build and start contrib environment
	PHP_VERSION=$(PHP_VERSION) HTTP_PORT=$(HTTP_PORT) \
		docker compose -f docker-compose.contrib.yml up --build

up: ## Start demo (without rebuild)
	HTTP_PORT=$(HTTP_PORT) docker compose -f docker-compose.demo.yml up -d

down: ## Stop demo
	docker compose -f docker-compose.demo.yml down

contrib-up: ## Start contribution setup
	HTTP_PORT=$(HTTP_PORT_CONTRIB) docker compose -f docker-compose.contrib.yml up --build

contrib-enter: ## Enter contribution setup
	docker compose -f docker-compose.contrib.yml exec web sh

contrib-db-enter: ## Enter contribution setup
	docker compose -f docker-compose.contrib.yml exec db sh

contrib-down: ## Stop contribution setup
	docker compose -f docker-compose.contrib.yml down

# ---------------------------------------------------------------------------
# Test
# ---------------------------------------------------------------------------

test: build-base ## Run smoke tests on base image (nginx variant)
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
	docker run --rm --entrypoint sh $(REGISTRY)/base:$(PHP_VERSION)-nginx -c 'sed -i "s|\$$TYPO3_CONTEXT|Production|g" /etc/nginx/conf.d/default.conf && nginx -t'
	@echo "=== Testing GraphicsMagick ==="
	docker run --rm --entrypoint gm $(REGISTRY)/base:$(PHP_VERSION)-nginx version | head -1
	@echo "=== All nginx variant tests passed ==="

test-fpm: build-base-fpm ## Run smoke tests on base image (fpm-only variant)
	@echo "=== Testing PHP extensions ==="
	docker run --rm --entrypoint php $(REGISTRY)/base:$(PHP_VERSION)-fpm -m | grep -q gd && echo "✓ gd"
	docker run --rm --entrypoint php $(REGISTRY)/base:$(PHP_VERSION)-fpm -m | grep -q intl && echo "✓ intl"
	docker run --rm --entrypoint php $(REGISTRY)/base:$(PHP_VERSION)-fpm -m | grep -qi opcache && echo "✓ opcache"
	docker run --rm --entrypoint php $(REGISTRY)/base:$(PHP_VERSION)-fpm -m | grep -q mysqli && echo "✓ mysqli"
	docker run --rm --entrypoint php $(REGISTRY)/base:$(PHP_VERSION)-fpm -m | grep -q pdo_mysql && echo "✓ pdo_mysql"
	docker run --rm --entrypoint php $(REGISTRY)/base:$(PHP_VERSION)-fpm -m | grep -q pdo_pgsql && echo "✓ pdo_pgsql"
	docker run --rm --entrypoint php $(REGISTRY)/base:$(PHP_VERSION)-fpm -m | grep -q redis && echo "✓ redis"
	docker run --rm --entrypoint php $(REGISTRY)/base:$(PHP_VERSION)-fpm -m | grep -q apcu && echo "✓ apcu"
	docker run --rm --entrypoint php $(REGISTRY)/base:$(PHP_VERSION)-fpm -m | grep -q zip && echo "✓ zip"
	@echo "=== Testing Composer ==="
	docker run --rm --entrypoint composer $(REGISTRY)/base:$(PHP_VERSION)-fpm --version
	@echo "=== Testing GraphicsMagick ==="
	docker run --rm --entrypoint gm $(REGISTRY)/base:$(PHP_VERSION)-fpm version | head -1
	@echo "=== All fpm variant tests passed ==="

# ---------------------------------------------------------------------------
# Cleanup
# ---------------------------------------------------------------------------

clean: ## Remove all built images and volumes
	docker compose -f docker-compose.demo.yml down -v --rmi local 2>/dev/null || true
	docker compose -f docker-compose.contrib.yml down -v --rmi local 2>/dev/null || true
	docker rmi $(REGISTRY)/base:$(PHP_VERSION)-nginx 2>/dev/null || true
	docker rmi $(REGISTRY)/base:$(PHP_VERSION)-fpm 2>/dev/null || true
	docker rmi $(REGISTRY)/demo:$(TYPO3_VERSION)-php$(PHP_VERSION) 2>/dev/null || true
	docker rmi $(REGISTRY)/demo:$(TYPO3_VERSION) 2>/dev/null || true
	docker rmi $(REGISTRY)/contrib:$(PHP_VERSION) 2>/dev/null || true
